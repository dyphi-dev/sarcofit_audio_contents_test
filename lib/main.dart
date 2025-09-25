import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:interactive_media/interactive_media.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Media Test',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _jsonController = TextEditingController();
  InteractiveMediaMetadata? _metadata;
  Timer? _debounceTimer;
  Key _widgetKey = UniqueKey();
  bool _isPreviewStarted = false;
  bool _isLoadingJson = true;

  @override
  void initState() {
    super.initState();
    _loadSampleJson();
  }

  Future<void> _loadSampleJson([String? url]) async {
    try {
      setState(() {
        _isLoadingJson = true;
      });

      String jsonString;
      
      if (url != null && url.isNotEmpty) {
        // URL에서 JSON 다운로드
        debugPrint('Loading JSON from URL: $url');
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          jsonString = response.body;
          debugPrint('Successfully loaded JSON from URL');
        } else {
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      } else {
        // 로컬 파일에서 로드
        jsonString = await rootBundle.loadString('sample.json');
        debugPrint('Successfully loaded local sample.json');
      }

      if (mounted) {
        setState(() {
          _jsonController.text = jsonString;
          _isLoadingJson = false;
        });
        _parseJson();
      }
    } catch (e) {
      debugPrint('Failed to load JSON: $e');
      if (mounted) {
        setState(() {
          _jsonController.text = '{}';
          _isLoadingJson = false;
        });
        
        String errorMessage = url != null 
            ? 'URL에서 JSON을 로드할 수 없습니다: $e'
            : 'sample.json 파일을 로드할 수 없습니다: $e';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '닫기',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  void _parseJson() {
    try {
      final jsonString = _jsonController.text.trim();
      if (jsonString.isNotEmpty) {
        final parsed = json.decode(jsonString);

        // Debug logging
        debugPrint('Parsed JSON: $parsed');
        debugPrint('Template: ${parsed['template']}');
        debugPrint('Contents length: ${parsed['contents']?.length ?? 0}');

        // Parse metadata
        final metadata = InteractiveMediaMetadata.fromJson(parsed);

        debugPrint('Metadata contents length: ${metadata.contents.length}');
        debugPrint('Metadata contents: ${metadata.contents}');

        setState(() {
          _metadata = metadata;
          _widgetKey = UniqueKey(); // Force widget rebuild
          _isPreviewStarted = false; // Reset preview when JSON changes
        });
      }
    } catch (e) {
      debugPrint('JSON parsing error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON 파싱 오류: $e'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '닫기',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Media Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _parseJson,
            tooltip: 'Reload JSON',
          ),
        ],
      ),
      body: Row(
        children: [
          // JSON Editor (Left Panel)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'JSON Editor',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _jsonController.text = const JsonEncoder.withIndent(
                            '  ',
                          ).convert(jsonDecode(_jsonController.text));
                        },
                        icon: const Icon(Icons.format_align_left, size: 16),
                        label: const Text('Format'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // JSON Text Editor
                  Expanded(
                    child: _isLoadingJson
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('JSON 파일을 로드하는 중...'),
                              ],
                            ),
                          )
                        : TextField(
                            controller: _jsonController,
                            maxLines: null,
                            expands: true,
                            decoration: const InputDecoration(
                              hintText: 'JSON 데이터를 입력하세요...',
                              border: OutlineInputBorder(),
                            ),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                            onChanged: (value) {
                              _debounceTimer?.cancel();
                              _debounceTimer = Timer(
                                const Duration(milliseconds: 500),
                                () {
                                  _parseJson();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Preview (Right Panel)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_metadata != null && !_isPreviewStarted)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isPreviewStarted = true;
                            });
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('미리보기 시작'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Expanded(
                    child: _metadata != null
                        ? _isPreviewStarted
                              ? Column(
                                  children: [
                                    // Phone Frame
                                    Expanded(
                                      child: Center(
                                        child: Container(
                                          width: 360,
                                          height: 640,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 6,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.3,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: Container(
                                              color: Colors.white,
                                              child: _buildInteractiveWidget(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '미리보기를 시작하려면\n위의 버튼을 클릭하세요',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                        : const Center(
                            child: Text(
                              '유효한 JSON 데이터를 입력하세요',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveWidget() {
    if (_metadata == null) {
      return const Center(
        child: Text(
          '미디어 데이터를 불러올 수 없습니다',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return InteractiveMediaWidget(
      key: _widgetKey,
      metadata: _metadata!,
      autoStart: true,
      onStart: () {
        debugPrint('미디어 재생 시작');
      },
      onComplete: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('미디어 재생이 완료되었습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onPause: () {
        debugPrint('미디어 재생 일시정지');
      },
      onResume: () {
        debugPrint('미디어 재생 재개');
      },
      onOverlayButtonAction: (action, data) {
        debugPrint('Overlay button action: $action with data: $data');
        // Handle different action types based on the new JSON structure
        // Structure: action.actionConfig.type and action.actionConfig.data
        switch (action) {
          case ActionType.changeContent:
            if (data?['asset'] != null) {
              _loadSampleJson(data!['asset'] as String);
            }
            break;
          case ActionType.navigate:
            if (data?['route'] != null) {
              debugPrint('Navigating to route: ${data!['route']}');
              // For demo purposes, just show a snackbar instead of actual navigation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigate to: ${data['route']}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            break;
          case ActionType.hideOverlay:
            debugPrint('Hiding overlay');
            break;
          case ActionType.pop:
            debugPrint('Popping navigation');
            Navigator.pop(context);
            break;
        }
      },
      onCompleteAction: (action, data) {
        debugPrint('Complete action: $action with data: $data');

        // Handle different direct action types (same logic as onOverlayButtonAction)
        switch (action) {
          case ActionType.changeContent:
            if (data?['asset'] != null) {
              _loadSampleJson(data!['asset'] as String);
            }
            break;
          case ActionType.navigate:
            if (data?['route'] != null) {
              debugPrint('Navigating to route: ${data!['route']}');
              // For demo purposes, just show a snackbar instead of actual navigation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigate to: ${data['route']}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            break;
          case ActionType.pop:
            debugPrint('Popping navigation');
            Navigator.pop(context);
            break;
          case ActionType.hideOverlay:
            // This shouldn't happen for complete actions, but handle gracefully
            debugPrint('Hide overlay action on complete');
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _jsonController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
