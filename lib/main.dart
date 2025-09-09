import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
      ],
    "endOverlay": {
        "showOnEnd": true,
        "heightReductionRatio": 0.5,
        "buttons": [
          {
            "text": "시작하기",
            "arguments": "primary",
            "action": {
              "type": "callback",
              "data": {
                "exerciseType": "cardio",
                "duration": 30
              }
            }
          },
          {
            "text": "나중에",
            "arguments": "secondary",
            "action": {
              "type": "navigate",
              "route": "/lyric"
            }
          },
          {
            "text": "히든",
            "arguments": "ghost",
            "action": {
              "type": "hideOverlay"
            }
          },
          {
            "text": "뒤로가기",
            "arguments": "outline",
            "action": {
              "type": "pop"
            }
          }
        ]
      }
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
                                        child: _selectedTemplate == 'lyric'
                                            ? _buildLyricWidget()
                                            : _buildVideoWidget(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Controls for lyric template
                              if (_selectedTemplate == 'lyric' &&
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

                              // Controls for video template
                              if (_selectedTemplate == 'video' &&
                                  _videoController != null)
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: _isPlaying
                                            ? null
                                            : () => _videoController!.start(),
                                        icon: const Icon(Icons.play_arrow),
                                        iconSize: 32,
                                        tooltip: 'Play',
                                      ),
                                      IconButton(
                                        onPressed: !_isPlaying
                                            ? null
                                            : () => _videoController!.pause(),
                                        icon: const Icon(Icons.pause),
                                        iconSize: 32,
                                        tooltip: 'Pause',
                                      ),
                                      IconButton(
                                        onPressed: !_isPlaying
                                            ? null
                                            : () => _videoController!.resume(),
                                        icon: const Icon(Icons.play_circle),
                                        iconSize: 32,
                                        tooltip: 'Resume',
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _videoController!.stop(),
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

  Widget _buildLyricWidget() {
    if (_metadata == null || _lyricController == null) {
      return const Center(
        child: Text('가사 데이터를 불러올 수 없습니다', style: TextStyle(color: Colors.grey)),
      );
    }

    return InteractiveMediaWidget(
      key: _widgetKey,
      metadata: _metadata!,
      controller: _lyricController,
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
            content: Text('가사 재생이 완료되었습니다!'),
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
    );
  }

  Widget _buildVideoWidget() {
    if (_metadata == null || _videoController == null) {
      return const Center(
        child: Text(
          '비디오 데이터를 불러올 수 없습니다',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // 웹 환경에서는 비디오 플레이어가 제대로 작동하지 않을 수 있음
    if (kIsWeb) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              '비디오 미리보기',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '웹 환경에서는 비디오 재생이 제한됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '비디오 정보:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text('템플릿: ${_metadata!.template}'),
                  Text('콘텐츠 수: ${_metadata!.contents.length}개'),
                  if (_metadata!.contents.isNotEmpty)
                    Text('첫 번째 비디오: ${_metadata!.contents.first.contentType}'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 네이티브 환경에서는 InteractiveMediaWidget 사용
    return InteractiveMediaWidget(
      key: _widgetKey,
      metadata: _metadata!,
      controller: _videoController,
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
            content: Text('비디오 재생이 완료되었습니다!'),
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
