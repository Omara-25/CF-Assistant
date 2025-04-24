import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class VoiceSettings extends StatelessWidget {
  final String currentLanguage;
  final String currentVoice;
  final List<Map<String, String>> languages;
  final Map<String, List<dynamic>> voicesByLanguage;
  final double speechRate;
  final double pitch;
  final double positiveSpeechThreshold;
  final double negativeSpeechThreshold;
  final int redemptionFrames;
  final int frameSamples;
  final int preSpeechPadFrames;
  final int minimumSpeechFrames;
  final Function(String) onLanguageChanged;
  final Function(String) onVoiceChanged;
  final Function(double) onSpeechRateChanged;
  final Function(double) onPitchChanged;
  final Function(double) onPositiveSpeechThresholdChanged;
  final Function(double) onNegativeSpeechThresholdChanged;
  final Function(int) onRedemptionFramesChanged;
  final Function(int) onFrameSamplesChanged;
  final Function(int) onPreSpeechPadFramesChanged;
  final Function(int) onMinimumSpeechFramesChanged;
  final VoidCallback onClose;

  const VoiceSettings({
    super.key,
    required this.currentLanguage,
    required this.currentVoice,
    required this.languages,
    required this.voicesByLanguage,
    required this.speechRate,
    required this.pitch,
    required this.positiveSpeechThreshold,
    required this.negativeSpeechThreshold,
    required this.redemptionFrames,
    required this.frameSamples,
    required this.preSpeechPadFrames,
    required this.minimumSpeechFrames,
    required this.onLanguageChanged,
    required this.onVoiceChanged,
    required this.onSpeechRateChanged,
    required this.onPitchChanged,
    required this.onPositiveSpeechThresholdChanged,
    required this.onNegativeSpeechThresholdChanged,
    required this.onRedemptionFramesChanged,
    required this.onFrameSamplesChanged,
    required this.onPreSpeechPadFramesChanged,
    required this.onMinimumSpeechFramesChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    // Prepare language dropdown items
    final dropdownItems = languages.map<DropdownMenuItem<String>>((language) {
      return DropdownMenuItem<String>(
        value: language['code'],
        child: Text(
          language['name']!,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }).toList();
    
    // Prepare voice items for the current language
    List<DropdownMenuItem<String>> voiceItems = [];
    if (voicesByLanguage.containsKey(currentLanguage)) {
      voiceItems = voicesByLanguage[currentLanguage]!.map<DropdownMenuItem<String>>((voice) {
        return DropdownMenuItem<String>(
          value: voice['name'],
          child: Text(
            voice['name'],
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList();
    }
    
    return Container(
      color: isDarkMode ? const Color(0xFF424242) : Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Voice Settings',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDarkMode ? Colors.white : Colors.black),
                  onPressed: onClose,
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Language',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF333333) : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: currentLanguage,
                icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.black),
                isExpanded: true,
                dropdownColor: isDarkMode ? const Color(0xFF333333) : Colors.grey[200],
                underline: Container(),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onLanguageChanged(newValue);
                  }
                },
                items: dropdownItems,
              ),
            ),
            
            // Voice Selection Section
            if (voiceItems.isNotEmpty) ...[
              SizedBox(height: isSmallScreen ? 12 : 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voice',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${voiceItems.length} available',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: isSmallScreen ? 12 : 13,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF333333) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: currentVoice.isNotEmpty ? currentVoice : null,
                  hint: Text('Select voice', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                  icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.black),
                  isExpanded: true,
                  dropdownColor: isDarkMode ? const Color(0xFF333333) : Colors.grey[200],
                  underline: Container(),
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onVoiceChanged(newValue);
                    }
                  },
                  items: voiceItems,
                ),
              ),
            ] else ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No specific voices available for this language',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: isSmallScreen ? 12 : 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              'Voice Settings',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Speech Rate: ${speechRate.toStringAsFixed(2)}',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: isDarkMode ? Colors.white : Colors.purple,
                activeTrackColor: isDarkMode ? Colors.purple[200] : Colors.purple[400],
                inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.purple[100],
                overlayColor: Colors.purple.withOpacity(0.2),
              ),
              child: Slider(
                value: speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 18,
                label: speechRate.toStringAsFixed(2),
                onChanged: onSpeechRateChanged,
              ),
            ),
            Text(
              'Pitch: ${pitch.toStringAsFixed(2)}',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: isDarkMode ? Colors.white : Colors.purple,
                activeTrackColor: isDarkMode ? Colors.purple[200] : Colors.purple[400],
                inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.purple[100],
                overlayColor: Colors.purple.withOpacity(0.2),
              ),
              child: Slider(
                value: pitch,
                min: 0.5,
                max: 2.0,
                divisions: 30,
                label: pitch.toStringAsFixed(2),
                onChanged: onPitchChanged,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              'Speech Recognition Settings',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Positive Speech Threshold (${positiveSpeechThreshold.toStringAsFixed(2)})',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: isDarkMode ? Colors.white : Colors.purple,
                activeTrackColor: isDarkMode ? Colors.purple[200] : Colors.purple[400],
                inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.purple[100],
                overlayColor: Colors.purple.withOpacity(0.2),
              ),
              child: Slider(
                value: positiveSpeechThreshold,
                min: 0.1,
                max: 1.0,
                onChanged: onPositiveSpeechThresholdChanged,
              ),
            ),
            Text(
              'Negative Speech Threshold (${negativeSpeechThreshold.toStringAsFixed(2)})',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: isDarkMode ? Colors.white : Colors.purple,
                activeTrackColor: isDarkMode ? Colors.purple[200] : Colors.purple[400],
                inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.purple[100],
                overlayColor: Colors.purple.withOpacity(0.2),
              ),
              child: Slider(
                value: negativeSpeechThreshold,
                min: 0.1,
                max: 1.0,
                onChanged: onNegativeSpeechThresholdChanged,
              ),
            ),
            Text(
              'Redemption Frames (${redemptionFrames.toString()})',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: isDarkMode ? Colors.white : Colors.purple,
                activeTrackColor: isDarkMode ? Colors.purple[200] : Colors.purple[400],
                inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.purple[100],
                overlayColor: Colors.purple.withOpacity(0.2),
              ),
              child: Slider(
                value: redemptionFrames.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                onChanged: (value) => onRedemptionFramesChanged(value.toInt()),
              ),
            ),
            Text(
              'Frame Samples (${frameSamples.toString()})',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: isDarkMode ? Colors.white : Colors.purple,
                activeTrackColor: isDarkMode ? Colors.purple[200] : Colors.purple[400],
                inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.purple[100],
                overlayColor: Colors.purple.withOpacity(0.2),
              ),
              child: Slider(
                value: frameSamples.toDouble(),
                min: 128,
                max: 4096,
                divisions: 16,
                onChanged: (value) => onFrameSamplesChanged(value.toInt()),
              ),
            ),
            Text(
              'Pre Speech Pad Frames (${preSpeechPadFrames.toString()})',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: isDarkMode ? Colors.white : Colors.purple,
                activeTrackColor: isDarkMode ? Colors.purple[200] : Colors.purple[400],
                inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.purple[100],
                overlayColor: Colors.purple.withOpacity(0.2),
              ),
              child: Slider(
                value: preSpeechPadFrames.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (value) => onPreSpeechPadFramesChanged(value.toInt()),
              ),
            ),
            Text(
              'Minimum Speech Frames (${minimumSpeechFrames.toString()})',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                thumbColor: isDarkMode ? Colors.white : Colors.purple,
                activeTrackColor: isDarkMode ? Colors.purple[200] : Colors.purple[400],
                inactiveTrackColor: isDarkMode ? Colors.white24 : Colors.purple[100],
                overlayColor: Colors.purple.withOpacity(0.2),
              ),
              child: Slider(
                value: minimumSpeechFrames.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: (value) => onMinimumSpeechFramesChanged(value.toInt()),
              ),
            ),
            // Add extra padding at the bottom to ensure the last slider is fully visible
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

