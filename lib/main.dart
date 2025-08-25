import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:karaoke_text/karaoke_text.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karaoke Audio Contents Test',
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
  final TextEditingController _urlController = TextEditingController();
  late KaraokeLyricsController _controller;
  late AudioPlayer _audioPlayer;

  String? _jsonData;
  bool _isPlaying = false;
  String? _selectedAudioPath;
  String? _audioFileName;
  bool _isAudioLoaded = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = KaraokeLyricsController();
    _audioPlayer = AudioPlayer();

    // Set initial JSON data
    _jsonController.text = _getSampleLyrics();
    _parseJson();
  }

  String _getSampleLyrics() {
    return '''[
  {
    "type": "span",
    "spans": [
      {
        "text": "안녕하세요",
        "offset": 0.0,
        "dur": 2.0,
        "style": {
          "color": "#FF6B6B",
          "size": 56.0
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
        "text": "카라오케",
        "offset": 2.5,
        "dur": 1.5,
        "style": {
          "color": "#4ECDC4",
          "size": 56.0
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
        "text": "텍스트",
        "offset": 4.5,
        "dur": 1.5,
        "style": {
          "color": "#45B7D1",
          "size": 56.0
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
        "text": "애니메이션",
        "offset": 6.5,
        "dur": 2.0,
        "style": {
          "color": "#96CEB4",
          "size": 56.0
        }
      }
    ]
  }
]''';
  }

  void _parseJson() {
    try {
      final jsonString = _jsonController.text.trim();
      if (jsonString.isNotEmpty) {
        final parsed = json.decode(jsonString);
        setState(() {
          _jsonData = jsonString;
        });
        _controller.stop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON 파싱 오류: $e'),
          duration: const Duration(seconds: 10),
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

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedAudioPath = file.path;
          _audioFileName = file.name;
          _isAudioLoaded = true;
        });

        if (file.path != null) {
          await _audioPlayer.setSource(DeviceFileSource(file.path!));
        } else if (file.bytes != null) {
          await _audioPlayer.setSource(BytesSource(file.bytes!));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오디오 파일이 로드되었습니다: ${file.name}'),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: '닫기',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오디오 파일 로드 오류: $e'),
          duration: const Duration(seconds: 10),
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

  Future<void> _loadAudioFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL을 입력해주세요'),
          duration: Duration(seconds: 10),
        ),
      );
      return;
    }

    try {
      await _audioPlayer.setSource(UrlSource(url));
      setState(() {
        _selectedAudioPath = url;
        _audioFileName =
            'URL 오디오: ${url.length > 20 ? '${url.substring(0, 20)}...' : url}';
        _isAudioLoaded = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('URL에서 오디오가 로드되었습니다'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: '닫기',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('URL 오디오 로드 오류: $e'),
          duration: const Duration(seconds: 10),
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

  Future<void> _startKaraokeWithAudio() async {
    if (_isAudioLoaded) {
      await _audioPlayer.resume();
      _controller.start();
    }
  }

  Future<void> _pauseKaraokeWithAudio() async {
    if (_isAudioLoaded) {
      await _audioPlayer.pause();
      _controller.pause();
    }
  }

  Future<void> _resumeKaraokeWithAudio() async {
    if (_isAudioLoaded) {
      await _audioPlayer.resume();
      _controller.resume();
    }
  }

  Future<void> _stopKaraokeWithAudio() async {
    if (_isAudioLoaded) {
      await _audioPlayer.stop();
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karaoke Audio Contents Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Audio file picker section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickAudioFile,
                    icon: const Icon(Icons.audio_file),
                    label: Text(
                      _audioFileName ?? '오디오 파일 선택',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: '오디오 URL 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _loadAudioFromUrl,
                  child: const Text('URL 로드'),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Row(
              children: [
                // JSON Editor (Left side)
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
                        Text(
                          'JSON Editor',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: TextField(
                            controller: _jsonController,
                            maxLines: null,
                            expands: true,
                            decoration: const InputDecoration(
                              hintText: 'JSON 데이터를 입력하세요...',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _debounceTimer?.cancel();
                              _debounceTimer = Timer(
                                const Duration(milliseconds: 100),
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

                // UI Preview (Right side)
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
                          child: _jsonData != null
                              ? SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // Phone frame containing only KaraokeLyricsWidget
                                      Center(
                                        child: Container(
                                          width: 360,
                                          height: 716,
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
                                                color: Colors.black.withOpacity(
                                                  0.3,
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
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Center(
                                                  child: KaraokeLyricsWidget(
                                                    key: ValueKey(_jsonData),
                                                    jsonString: _jsonData!,
                                                    controller: _controller,
                                                    baseTextStyle:
                                                        const TextStyle(
                                                          fontSize: 28,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily:
                                                              'Noto Sans KR',
                                                        ),
                                                    highlightTextStyle:
                                                        const TextStyle(
                                                          fontSize: 28,
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily:
                                                              'Noto Sans KR',
                                                        ),
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
                                                            '가사 애니메이션이 완료되었습니다!',
                                                          ),
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
                                      ),

                                      const SizedBox(height: 20),

                                      // Control buttons outside the phone frame
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                '컨트롤',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed:
                                                        _isAudioLoaded &&
                                                            !_isPlaying
                                                        ? _startKaraokeWithAudio
                                                        : null,
                                                    child: const Icon(
                                                      Icons.play_arrow,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: _isPlaying
                                                        ? _pauseKaraokeWithAudio
                                                        : null,
                                                    child: const Icon(
                                                      Icons.pause,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed:
                                                        _isAudioLoaded &&
                                                            !_isPlaying
                                                        ? _resumeKaraokeWithAudio
                                                        : null,
                                                    child: const Icon(
                                                      Icons.play_circle,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: _isAudioLoaded
                                                        ? _stopKaraokeWithAudio
                                                        : null,
                                                    child: const Icon(
                                                      Icons.stop,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          ),
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _jsonController.dispose();
    _urlController.dispose();
    _controller.dispose();
    _audioPlayer.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
