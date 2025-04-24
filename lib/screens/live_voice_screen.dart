import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/chat_provider.dart';
import '../widgets/voice-settings.dart';

// Custom painter for sound wave animation
class SoundWavePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  SoundWavePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw multiple circles with varying opacity
    for (int i = 0; i < 4; i++) {
      final waveRadius = radius * (0.5 + (i * 0.15)) * (1 + 0.2 * sin(animationValue * 2 * pi + i * pi / 2));
      final paint = Paint()
        ..color = color.withAlpha(150 - (i * 30))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, waveRadius, paint);
    }
  }

  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class LiveVoiceScreen extends StatefulWidget {
  const LiveVoiceScreen({super.key});

  @override
  State<LiveVoiceScreen> createState() => _LiveVoiceScreenState();
}

class _LiveVoiceScreenState extends State<LiveVoiceScreen> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isSpeaking = false;
  int _step = 0; // 0: idle, 1: loading, 2: speaking
  Timer? _speechTimer;
  String _currentText = '';
  String _currentLanguage = 'en-US';
  String _currentVoice = '';
  double _speechRate = 0.80;
  double _pitch = 1.50;
  late AnimationController _animationController;
  bool _showVoiceSettings = false;

  final List<Map<String, String>> _languages = [
    {'name': 'English (US)', 'code': 'en-US'},
    {'name': 'Spanish', 'code': 'es-ES'},
    {'name': 'French', 'code': 'fr-FR'},
    {'name': 'German', 'code': 'de-DE'},
    {'name': 'Italian', 'code': 'it-IT'},
    {'name': 'Japanese', 'code': 'ja-JP'},
    {'name': 'Korean', 'code': 'ko-KR'},
    {'name': 'Chinese (Mandarin)', 'code': 'zh-CN'},
    {'name': 'Russian', 'code': 'ru-RU'},
  ];

  List<dynamic> _availableVoices = [];
  Map<String, List<dynamic>> _voicesByLanguage = {};

  // Speech input settings
  double _positiveSpeechThreshold = 0.60;
  double _negativeSpeechThreshold = 0.33;
  int _redemptionFrames = 19;
  int _frameSamples = 1024;
  int _preSpeechPadFrames = 1;
  int _minimumSpeechFrames = 5;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
    _loadAvailableVoices();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _initializeSpeech() async {
    await _speechToText.initialize();
  }

  void _initializeTts() async {
    await _flutterTts.setSharedInstance(true);

    // Set iOS audio category for better audio handling
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      ],
      IosTextToSpeechAudioMode.defaultMode,
    );

    // Set initial voice parameters
    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(1.0); // Full volume

    _flutterTts.setStartHandler(() {
      setState(() {
        _step = 2;
        _isSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _step = 0;
        _isSpeaking = false;
        _currentText = '';
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _step = 0;
        _isSpeaking = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text-to-speech error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Future<void> _loadAvailableVoices() async {
    try {
      _availableVoices = await _flutterTts.getVoices;

      // Organize voices by language code
      _voicesByLanguage = {};
      for (var voice in _availableVoices) {
        String locale = voice['locale'] ?? '';
        if (locale.isEmpty) continue;

        // For some TTS engines, locale might be just 'en' instead of 'en-US'
        // So we'll check for partial matches too
        String languageCode = locale.split('-')[0].toLowerCase();

        // Find all languages that match this voice
        for (var language in _languages) {
          String langCode = language['code']!.split('-')[0].toLowerCase();
          if (locale == language['code'] || languageCode == langCode) {
            if (!_voicesByLanguage.containsKey(language['code'])) {
              _voicesByLanguage[language['code']!] = [];
            }
            _voicesByLanguage[language['code']!]!.add(voice);
          }
        }
      }

      // Sort voices by name for each language
      _voicesByLanguage.forEach((key, voices) {
        voices.sort((a, b) =>
          (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
      });

      // Set initial voice if available
      if (_voicesByLanguage.containsKey(_currentLanguage) &&
          _voicesByLanguage[_currentLanguage]!.isNotEmpty) {
        _currentVoice = _voicesByLanguage[_currentLanguage]![0]['name'];
        await _flutterTts.setVoice({"name": _currentVoice});
      }

      setState(() {});
    } catch (e) {
      debugPrint("Failed to load voices: $e");

      // Only show error if mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load voices. Some features may be limited.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    try {
      _currentLanguage = languageCode;
      await _flutterTts.setLanguage(languageCode);

      // Reset voice when language changes
      if (_voicesByLanguage.containsKey(languageCode) &&
          _voicesByLanguage[languageCode]!.isNotEmpty) {
        _currentVoice = _voicesByLanguage[languageCode]![0]['name'];
        await _flutterTts.setVoice({"name": _currentVoice});
      } else {
        _currentVoice = '';
      }

      setState(() {});
      await _playLanguageSample(languageCode);
    } catch (e) {
      debugPrint("Failed to change language: $e");

      // Only show error if mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change language. Please try another one.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeVoice(String voiceName) async {
    try {
      _currentVoice = voiceName;
      await _flutterTts.setVoice({"name": voiceName});
      setState(() {});
      await _playVoiceSample();
    } catch (e) {
      debugPrint("Failed to change voice: $e");

      // Only show error if mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change voice. Please try another one.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    final bool initialized = await _speechToText.initialize();

    // Check if widget is still mounted after async operation
    if (!mounted) return;

    if (initialized) {
      setState(() {
        _isListening = true;
        _step = 0;
      });

      // Apply custom speech recognition settings
      _speechToText.listen(
        onResult: (result) => _handleSpeechResult(result),
        listenFor: const Duration(minutes: 1),
        listenOptions: SpeechListenOptions(
          partialResults: false,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );

      // Show a subtle indicator that listening has started
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listening...'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error if speech recognition couldn't initialize
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _handleSpeechResult(result) {
    final text = result.recognizedWords.trim();
    if (text.isNotEmpty) {
      _processVoiceInput(text);
    }
  }

  Future<void> _processVoiceInput(String text) async {
    final chatProvider = context.read<ChatProvider>();
    setState(() => _step = 1);

    try {
      await chatProvider.sendMessage(text);
      final response = chatProvider.messages.last.text;
      _currentText = response;
      await _speakResponse(response);
    } catch (e) {
      await _speakResponse("Sorry, I encountered an error");
      setState(() => _step = 0);
    }
  }

  Future<void> _speakResponse(String text) async {
    await _flutterTts.speak(text);
  }

  void _cancelInteraction() async {
    await _flutterTts.stop();
    _stopListening();
    setState(() {
      _step = 0;
      _isSpeaking = false;
      _currentText = '';
    });
  }

  void _toggleVoiceSettings() {
    setState(() {
      _showVoiceSettings = !_showVoiceSettings;
      if (_showVoiceSettings) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    _speechToText.stop();
    _flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1A1F25) : Colors.white,
        elevation: 0,
        title: Text(
          'CF - Live Voice Assistant',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDarkMode ? Colors.white70 : theme.colorScheme.primary,
            ),
            onPressed: _toggleVoiceSettings,
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {/* Add info dialog */},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: isDarkMode
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0F1419), Color(0xFF121820)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF7F7F8), Color(0xFFEBEBF0)],
                    ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.9,
                              maxHeight: constraints.maxHeight * 0.8,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: _buildVisualFeedback(theme),
                                  ),
                                ),
                                if (_currentText.isNotEmpty && _step == 2)
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 16 : 32,
                                      vertical: isSmallScreen ? 16 : 24,
                                    ),
                                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                        ? const Color(0xFF1E2530)
                                        : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(13), // 0.05 opacity
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: theme.colorScheme.primary,
                                              radius: 16,
                                              child: const Text(
                                                'CF',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'CF Assistant',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _currentText,
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white : Colors.black87,
                                            fontSize: isSmallScreen ? 15 : 16,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: isSmallScreen ? 12.0 : 24.0,
                                    bottom: isSmallScreen ? 16.0 : 24.0,
                                  ),
                                  child: _buildStatusText(theme),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          bottom: isSmallScreen ? 16.0 : 24.0,
                        ),
                        child: _buildVoiceControls(theme),
                      ),
                    ],
                  );
                }
              ),
            ),
            // Voice Settings Panel with Animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: size.width * 0.85 * _animationController.value,
                  child: Material(
                    elevation: 8,
                    color: theme.colorScheme.surface,
                    child: _animationController.value > 0
                      ? VoiceSettings(
                          currentLanguage: _currentLanguage,
                          currentVoice: _currentVoice,
                          languages: _languages,
                          voicesByLanguage: _voicesByLanguage,
                          speechRate: _speechRate,
                          pitch: _pitch,
                          positiveSpeechThreshold: _positiveSpeechThreshold,
                          negativeSpeechThreshold: _negativeSpeechThreshold,
                          redemptionFrames: _redemptionFrames,
                          frameSamples: _frameSamples,
                          preSpeechPadFrames: _preSpeechPadFrames,
                          minimumSpeechFrames: _minimumSpeechFrames,
                          onLanguageChanged: _changeLanguage,
                          onVoiceChanged: _changeVoice,
                          onSpeechRateChanged: (value) {
                            setState(() => _speechRate = value);
                            _flutterTts.setSpeechRate(_speechRate);
                          },
                          onPitchChanged: (value) {
                            setState(() => _pitch = value);
                            _flutterTts.setPitch(_pitch);
                          },
                          onPositiveSpeechThresholdChanged: (value) {
                            setState(() => _positiveSpeechThreshold = value);
                          },
                          onNegativeSpeechThresholdChanged: (value) {
                            setState(() => _negativeSpeechThreshold = value);
                          },
                          onRedemptionFramesChanged: (value) {
                            setState(() => _redemptionFrames = value);
                          },
                          onFrameSamplesChanged: (value) {
                            setState(() => _frameSamples = value);
                          },
                          onPreSpeechPadFramesChanged: (value) {
                            setState(() => _preSpeechPadFrames = value);
                          },
                          onMinimumSpeechFramesChanged: (value) {
                            setState(() => _minimumSpeechFrames = value);
                          },
                          onClose: _toggleVoiceSettings,
                        )
                      : Container(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualFeedback(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final avatarSize = isSmallScreen ? 180.0 : 250.0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_step == 1) {
      return Center(
        child: Container(
          width: isSmallScreen ? 150 : 200,
          height: isSmallScreen ? 150 : 200,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E2530) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Lottie.asset(
              'assets/loading.json',
              width: isSmallScreen ? 100 : 140,
              height: isSmallScreen ? 100 : 140,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _step == 2
          ? _buildAnimatedSoundBars(theme)
          : Hero(
              tag: 'cf-avatar',
              child: GestureDetector(
                onTap: _toggleListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isListening
                        ? [
                            theme.colorScheme.primary,
                            Color.alphaBlend(theme.colorScheme.primary.withAlpha(180), Colors.blue),
                          ]
                        : [
                            isDarkMode ? const Color(0xFF2C3E50) : Colors.white,
                            isDarkMode ? const Color(0xFF1A2530) : const Color(0xFFF0F0F0),
                          ],
                    ),
                    border: Border.all(
                      color: _isListening
                        ? theme.colorScheme.primary.withAlpha(204) // 0.8 opacity
                        : theme.colorScheme.primary,
                      width: _isListening ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isListening
                          ? theme.colorScheme.primary.withAlpha(153) // 0.6 opacity
                          : theme.colorScheme.primary.withAlpha(77), // 0.3 opacity
                        blurRadius: _isListening ? 25 : 20,
                        spreadRadius: _isListening ? 8 : 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: avatarSize * 0.7,
                          height: avatarSize * 0.7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/cf_logo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      if (_isListening) _buildPulsatingOverlay(theme),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPulsatingOverlay(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                theme.colorScheme.primary.withAlpha((127 * (1 - value)).toInt()), // 0.5 opacity at start
                Colors.transparent,
              ],
              stops: [0.0, value],
              radius: 1.0,
            ),
          ),
        );
      },
      onEnd: () {
        setState(() {});  // Force rebuild to restart animation
      },
    );
  }

  Widget _buildAnimatedSoundBars(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: isSmallScreen ? 180 : 250,
      height: isSmallScreen ? 180 : 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDarkMode ? const Color(0xFF2C3E50) : Colors.white,
            isDarkMode ? const Color(0xFF1A2530) : const Color(0xFFF0F0F0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              width: isSmallScreen ? 130 : 190,
              height: isSmallScreen ? 130 : 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? const Color(0xFF1E2530).withAlpha(150) : Colors.grey.withAlpha(20),
              ),
            ),
            // Sound wave animation
            SizedBox(
              width: isSmallScreen ? 120 : 180,
              height: isSmallScreen ? 120 : 180,
              child: CustomPaint(
                painter: SoundWavePainter(
                  color: theme.colorScheme.primary,
                  animationValue: DateTime.now().millisecondsSinceEpoch % 2000 / 2000,
                ),
                child: Container(),
              ),
            ),
            // CF Logo in center
            Container(
              width: isSmallScreen ? 70 : 100,
              height: isSmallScreen ? 70 : 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/cf_logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildStatusText(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    String text;
    if (_step == 1) {
      text = "Processing...";
    } else if (_isListening) {
      text = "Listening...";
    } else if (_step == 2) {
      text = "Speaking...";
    } else {
      text = "Tap to start";
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: isSmallScreen ? 18 : 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVoiceControls(ThemeData theme) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isListening ? Icons.mic_off : Icons.mic,
            color: theme.colorScheme.primary,
            onPressed: _toggleListening,
            isAnimated: true,
            size: isSmallScreen ? 50.0 : 56.0,
          ),
          _buildControlButton(
            icon: Icons.close,
            color: theme.colorScheme.error,
            onPressed: _cancelInteraction,
            size: isSmallScreen ? 50.0 : 56.0,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isSquare = false,
    bool isAnimated = false,
    double size = 56.0,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isSquare ? BorderRadius.circular(15) : null,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(102), // 0.4 opacity
            blurRadius: isAnimated && _isListening ? 15 : 10,
            spreadRadius: isAnimated && _isListening ? 3 : 1,
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: FloatingActionButton(
          backgroundColor: color,
          onPressed: onPressed,
          shape: isSquare
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              : const CircleBorder(),
          child: Icon(icon, size: size * 0.5, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _playLanguageSample(String languageCode) async {
    final languageName = _languages.firstWhere((lang) => lang['code'] == languageCode)['name'];
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak("This is a sample of the $languageName language.");
  }

  Future<void> _playVoiceSample() async {
    if (_currentVoice.isNotEmpty) {
      await _flutterTts.speak("This is a sample of how this voice sounds.");
    }
  }
}


