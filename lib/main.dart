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
  LyricController? _lyricController;
  VideoController? _videoController;
  InteractiveMediaMetadata? _metadata;
  bool _isPlaying = false;
  Timer? _debounceTimer;
  Key _widgetKey = UniqueKey();
  String _selectedTemplate = 'lyric'; // 기본값은 lyric

  @override
  void initState() {
    super.initState();
    _jsonController.text = _getSampleJson();
    _parseJson();
  }

  String _getSampleJson() {
    return '''
    {
  "template": "lyric",
  "renderingOptions": {
    "transitionDelay": 500,
    "fadeInDuration": 800,
    "fadeOutDuration": 600
  },
  "background": {
    "type": "gradient",
    "value": "linear-gradient(90deg, #FFD078 0%, #FEF4D1 25%, #FFF 50%, #A4C1FF 100%)",
    "opacity": 0.15
  },
  "styleOptions": {
    "padding": 20
  },
  "contents": [
    {
      "contentType": "lyric",
      "media": {
        "type": "audio",
        "source": {
          "type": "url",
          "value":  "https://sarcofit-test.s3.ap-northeast-2.amazonaws.com/sample.mp3",
          "format": "mp3"
        }
      },
      "textAlign": "left",
      "lyricItems": [
        {
          "type": "line",
          "spans": [
            {
              "text": "길동님께",
              "offset": 0,
              "duration": 1100,
              "style": {
                "color": "#FF6B6B",
                "fontSize": 56.0,
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
          "type": "line",
          "spans": [
            {
              "text": "딱맞는",
              "offset": 1900,
              "duration": 800,
              "style": {
                "color": "#4ECDC4",
                "fontSize": 56.0,
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
          "type": "line",
          "spans": [
            {
              "text": "운동을",
              "offset": 3800,
              "duration": 700,
              "style": {
                "color": "#45B7D1",
                "fontSize": 56.0,
                "fontWeight": "w900"
              }
            },
            {
              "text": " ",
              "offset": 4500,
              "duration": 0
            },
            {
              "text": "준비했어요",
              "offset": 4500,
              "duration": 1000,
              "style": {
                "color": "#45B7D1",
                "fontSize": 56.0,
                "fontWeight": "w900"
              }
            }
          ]
        }
      ]
    },
    {
      "contentType": "lyric",
      "media": {
        "type": "audio",
        "source": {
          "type": "url",
          "value": "https://sarcofit-test.s3.ap-northeast-2.amazonaws.com/sample2.mp3",
          "format": "mp3"
        }
      },
      "textAlign": "left",
      "lyricItems": [
        {
          "type": "line",
          "spans": [
            {
              "text": "근감소증은",
              "offset": 0,
              "duration": 1040,
              "style": {
                "color": "#FF6B6B",
                "fontSize": 56.0,
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
          "type": "line",
          "spans": [
            {
              "text": "운동으로",
              "offset": 2100,
              "duration": 1600,
              "style": {
                "color": "#4ECDC4",
                "fontSize": 56.0,
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
          "type": "line",
          "spans": [
            {
              "text": "치료해요",
              "offset": 3700,
              "duration": 1300,
              "style": {
                "color": "#45B7D1",
                "fontSize": 56.0,
                "fontWeight": "w900"
              }
            }
          ]
        }
      ]
    }
  ]
}
    ''';
  }

  String _getVideoJson() {
    return '''{
  "template": "video",
  "renderingOptions": {
    "transitionDelay": 500,
    "fadeInDuration": 800,
    "fadeOutDuration": 600
  },
  "contents": [
    {
      "contentType": "video",
      "media": {
        "type": "video",
        "source": {
          "type": "url",
          "value": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
          "format": "mp4",
          "duration": 12.0
        }
      },
      "displayOptions": {
        "fit": "fill",
        "alignment": "center",
        "showControls": false,
        "autoPlay": true,
        "loop": false,
        "muted": false
      },
      "endOverlay": {
        "text": "첫 번째 영상이 끝났습니다",
        "buttonText": "다음 영상 보기",
        "showOnEnd": true
      }
    },
    {
      "contentType": "video",
      "media": {
        "type": "video",
        "source": {
          "type": "url",
          "value": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
          "format": "mp4",
          "duration": 596.0
        }
      },
      "displayOptions": {
        "fit": "contain",
        "alignment": "center",
        "showControls": false,
        "autoPlay": true,
        "loop": false,
        "muted": false,
        "backgroundColor": "#1a1a1a"
      },
      "endOverlay": {
        "text": "모든 영상을 시청하셨습니다",
        "buttonText": "완료",
        "showOnEnd": true
      }
    }
  ],
  "styleOptions": {
    "paddingTop": 20,
    "paddingBottom": 20,
    "paddingLeft": 16,
    "paddingRight": 16
  }
}''';
  }

  void _onTemplateChanged(String? value) {
    if (value != null && value != _selectedTemplate) {
      setState(() {
        _selectedTemplate = value;
      });

      // JSON 내용을 선택된 템플릿에 따라 변경
      if (value == 'lyric') {
        _jsonController.text = _getSampleJson();
      } else if (value == 'video') {
        _jsonController.text = _getVideoJson();
      }

      // JSON 파싱 실행
      _parseJson();
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

        // Dispose old controllers if exist
        _lyricController?.dispose();
        _videoController?.dispose();
        _lyricController = null;
        _videoController = null;

        // Parse metadata
        final metadata = InteractiveMediaMetadata.fromJson(parsed);

        // Debug logging for metadata
        debugPrint('Metadata template: ${metadata.template}');
        debugPrint('Metadata contents length: ${metadata.contents.length}');
        debugPrint('Metadata contents: ${metadata.contents}');

        // Initialize controller based on template type
        if (metadata.template == TemplateType.lyric) {
          _lyricController = LyricController();
          debugPrint('Created LyricController');
        } else if (metadata.template == TemplateType.video) {
          _videoController = VideoController();
          debugPrint('Created VideoController');
        }

        setState(() {
          _metadata = metadata;
          _widgetKey = UniqueKey(); // Force widget rebuild
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

  void _updateJsonField(String path, dynamic value) {
    try {
      final json = jsonDecode(_jsonController.text);
      final pathParts = path.split('.');
      dynamic current = json;

      for (int i = 0; i < pathParts.length - 1; i++) {
        final key = pathParts[i];
        if (key.contains('[') && key.contains(']')) {
          final arrayKey = key.substring(0, key.indexOf('['));
          final index = int.parse(
            key.substring(key.indexOf('[') + 1, key.indexOf(']')),
          );
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
      debugPrint('JSON update error: $e');
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

                  // Template Selection Radio Buttons
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Template Type',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'lyric',
                              groupValue: _selectedTemplate,
                              onChanged: _onTemplateChanged,
                            ),
                            const Text('Lyric'),
                            const SizedBox(width: 24),
                            Radio<String>(
                              value: 'video',
                              groupValue: _selectedTemplate,
                              onChanged: _onTemplateChanged,
                            ),
                            const Text('Video'),
                          ],
                        ),
                      ],
                    ),
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
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
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
                                          controller:
                                              _metadata!.template ==
                                                  TemplateType.lyric
                                              ? _lyricController
                                              : _videoController,
                                          onStart: () {
                                            setState(() {
                                              _isPlaying = true;
                                            });
                                          },
                                          onComplete: () {
                                            setState(() {
                                              _isPlaying = false;
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  '미디어 재생이 완료되었습니다!',
                                                ),
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
                              if (_metadata!.template == TemplateType.lyric &&
                                  _lyricController != null)
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: _isPlaying
                                            ? null
                                            : () => _lyricController!.start(),
                                        icon: const Icon(Icons.play_arrow),
                                        iconSize: 32,
                                        tooltip: 'Play',
                                      ),
                                      IconButton(
                                        onPressed: !_isPlaying
                                            ? null
                                            : () => _lyricController!.pause(),
                                        icon: const Icon(Icons.pause),
                                        iconSize: 32,
                                        tooltip: 'Pause',
                                      ),
                                      IconButton(
                                        onPressed: !_isPlaying
                                            ? null
                                            : () => _lyricController!.resume(),
                                        icon: const Icon(Icons.play_circle),
                                        iconSize: 32,
                                        tooltip: 'Resume',
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _lyricController!.stop(),
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
    _lyricController?.dispose();
    _videoController?.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
