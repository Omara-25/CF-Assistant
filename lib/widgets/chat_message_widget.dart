import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import 'package:flutter/services.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;

  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  final FlutterTts _flutterTts = FlutterTts();
  bool isLiked = false;
  bool isDisliked = false;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setPitch(1.4);
    await _flutterTts.setSpeechRate(0.9);
    _flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> _toggleSpeak() async {
    if (isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      setState(() {
        isSpeaking = true;
      });
      await _flutterTts.speak(widget.message.text);
    }
  }

// Helper function to format the timestamp
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM d, yyyy hh:mm a').format(timestamp);
  }
 @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: widget.message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!widget.message.isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.message.isUser
                  ? (isDarkMode ? Colors.blue[800] : Colors.blue[100])
                  : (isDarkMode ? Colors.grey[800] : Colors.white),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: widget.message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.message.text,
                    style: TextStyle(
                      color: widget.message.isUser
                        ? (isDarkMode ? Colors.white : Colors.black87)
                        : theme.textTheme.bodyLarge?.color,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  if (!widget.message.isUser)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildActionButtons(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.message.isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.message.isUser
          ? theme.colorScheme.primary
          : (isDarkMode ? Colors.grey[700] : Colors.grey[200]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: widget.message.isUser
          ? const Icon(Icons.person, size: 18, color: Colors.white)
          : Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(
                'assets/cf_logo.png',
                width: 18,
                height: 18,
              ),
            ),
      ),
    );
  }

Widget _buildActionButtons() {
    return Wrap(
      spacing: 4, // Horizontal space between buttons
      children: [
        IconButton(
          constraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: widget.message.text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message copied to clipboard')),
            );
          },
        ),
        IconButton(
          constraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
          padding: EdgeInsets.zero,
          icon: Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 18,
          ),
          onPressed: () {
            setState(() {
              isLiked = !isLiked;
              isDisliked = false;
            });
          },
        ),
        IconButton(
          constraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
          padding: EdgeInsets.zero,
          icon: Icon(
            isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
            size: 18,
          ),
          onPressed: () {
            setState(() {
              isDisliked = !isDisliked;
              isLiked = false;
            });
          },
        ),
        IconButton(
          constraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
          padding: EdgeInsets.zero,
          icon: Icon(
            isSpeaking ? Icons.stop : Icons.volume_up,
            size: 18,
          ),
          onPressed: _toggleSpeak,
        ),
      ],
    );
  }


  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
