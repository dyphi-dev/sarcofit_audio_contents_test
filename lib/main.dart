import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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
  LyricController? _controller;
  InteractiveMediaMetadata? _metadata;
  bool _isPlaying = false;
  Timer? _debounceTimer;
  Key _widgetKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _jsonController.text = _getSampleJson();
    _parseJson();
  }

  String _getSampleJson() {
    return '''{
  "template": "lyric",
  "renderingOptions": {
    "transitionDelay": 500,
    "fadeInDuration": 800,
    "fadeOutDuration": 600
  },
  "background": {
    "type": "gradient",
    "value": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
    "opacity": 0.15
  },
  "styleOptions": {
    "padding": 20
  },
  "contents": [
    {
      "audioType": "url",
      "audioSource": "https://sarcofit-test.s3.ap-northeast-2.amazonaws.com/sample.mp3",
      "textAlign": "left",
      "lyrics": [
        {
          "type": "span",
          "spans": [
            {
              "text": "길동님께",
              "offset": 0.0,
              "dur": 1.1,
              "style": {
                "color": "#FF6B6B",
                "size": 56.0,
                "fontWeight": "w900"
              }
            }
          ]
        },
        {
          "type": "spacer",
          "height": 20.0
        },
        {
          "type": "span",
          "spans": [
            {
              "text": "딱맞는",
              "offset": 1.9,
              "dur": 0.8,
              "style": {
                "color": "#4ECDC4",
                "size": 56.0,
                "fontWeight": "w900"
              }
            }
          ]
        },
        {
          "type": "spacer",
          "height": 20.0
        },
        {
          "type": "span",
          "spans": [
            {
              "text": "운동을",
              "offset": 3.8,
              "dur": 0.7,
              "style": {
                "color": "#45B7D1",
                "size": 56.0,
                "fontWeight": "w900"
              }
            }
          ]
        },
        {
          "type": "span",
          "spans": [
            {
              "text": "준비했어요",
              "offset": 4.5,
              "dur": 1.0,
              "style": {
                "color": "#45B7D1",
                "size": 56.0,
                "fontWeight": "w900"
              }
            }
          ]
        }
      ]
    },
    {
      "audioType": "url",
      "audioSource": "https://sarcofit-test.s3.ap-northeast-2.amazonaws.com/sample2.mp3",
      "textAlign": "left",
      "lyrics": [
        {
          "type": "span",
          "spans": [
            {
              "text": "근감소증은",
              "offset": 0.0,
              "dur": 1.04,
              "style": {
                "color": "#FF6B6B",
                "size": 56.0,
                "fontWeight": "w900"
              }
            }
          ]
        },
        {
          "type": "spacer",
          "height": 20.0
        },
        {
          "type": "span",
          "spans": [
            {
              "text": "운동으로",
              "offset": 2.1,
              "dur": 1.6,
              "style": {
                "color": "#4ECDC4",
                "size": 56.0,
                "fontWeight": "w900"
              }
            }
          ]
        },
        {
          "type": "spacer",
          "height": 20.0
        },
        {
          "type": "span",
          "spans": [
            {
              "text": "치료해요",
              "offset": 3.7,
              "dur": 1.3,
              "style": {
                "color": "#45B7D1",
                "size": 56.0,
                "fontWeight": "w900"
              }
            }
          ]
        }
      ]
    }
  ]
}''';
  }

  void _parseJson() {
    try {
      final jsonString = _jsonController.text.trim();
      if (jsonString.isNotEmpty) {
        final parsed = json.decode(jsonString);
        
        // Dispose old controller if exists
        _controller?.dispose();
        _controller = null;
        
        // Parse metadata
        final metadata = InteractiveMediaMetadata.fromJson(parsed);
        
        // Initialize controller if it's a lyric template
        LyricController? controller;
        if (metadata.template == TemplateType.lyric) {
          controller = LyricController();
        }
        
        setState(() {
          _metadata = metadata;
          _controller = controller;
          _widgetKey = UniqueKey(); // Force widget rebuild
        });
      }
    } catch (e) {
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

  void _updateJsonField(String path, dynamic value) {
    try {
      final json = jsonDecode(_jsonController.text);
      final pathParts = path.split('.');
      dynamic current = json;
      
      for (int i = 0; i < pathParts.length - 1; i++) {
        final key = pathParts[i];
        if (key.contains('[') && key.contains(']')) {
          final arrayKey = key.substring(0, key.indexOf('['));
          final index = int.parse(key.substring(key.indexOf('[') + 1, key.indexOf(']')));
          current = current[arrayKey][index];
        } else {
          current[key] ??= {};
          current = current[key];
        }
      }
      
      current[pathParts.last] = value;
      _jsonController.text = const JsonEncoder.withIndent('  ').convert(json);
      _parseJson();
    } catch (e) {
      debugPrint('JSON 업데이트 오류: $e');
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
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
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
                          _jsonController.text = const JsonEncoder.withIndent('  ')
                              .convert(jsonDecode(_jsonController.text));
                        },
                        icon: const Icon(Icons.format_align_left, size: 16),
                        label: const Text('Format'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // JSON Text Editor
                  Expanded(
                    child: TextField(
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
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _metadata != null
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
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 6,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        color: Colors.white,
                                        child: InteractiveMediaWidget(
                                          key: _widgetKey,
                                          metadata: _metadata!,
                                          controller: _controller,
                                          onStart: () {
                                            setState(() {
                                              _isPlaying = true;
                                            });
                                          },
                                          onComplete: () {
                                            setState(() {
                                              _isPlaying = false;
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('미디어 재생이 완료되었습니다!'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          onPause: () {
                                            setState(() {
                                              _isPlaying = false;
                                            });
                                          },
                                          onResume: () {
                                            setState(() {
                                              _isPlaying = true;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Controls (only for lyric template)
                              if (_metadata!.template == TemplateType.lyric && _controller != null)
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: _isPlaying ? null : () => _controller!.start(),
                                        icon: const Icon(Icons.play_arrow),
                                        iconSize: 32,
                                        tooltip: 'Play',
                                      ),
                                      IconButton(
                                        onPressed: !_isPlaying ? null : () => _controller!.pause(),
                                        icon: const Icon(Icons.pause),
                                        iconSize: 32,
                                        tooltip: 'Pause',
                                      ),
                                      IconButton(
                                        onPressed: !_isPlaying ? null : () => _controller!.resume(),
                                        icon: const Icon(Icons.play_circle),
                                        iconSize: 32,
                                        tooltip: 'Resume',
                                      ),
                                      IconButton(
                                        onPressed: () => _controller!.stop(),
                                        icon: const Icon(Icons.stop),
                                        iconSize: 32,
                                        tooltip: 'Stop',
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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

  @override
  void dispose() {
    _jsonController.dispose();
    _controller?.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}