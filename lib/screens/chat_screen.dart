import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/text_input_field.dart';
import '../widgets/footer_widget.dart';
import '../widgets/sidebar.dart';
import '../widgets/Live_voice_chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Add a more detailed welcome message
      chatProvider.addMessage(
        ChatMessage(
          text: "👋 Welcome to CF-Assistant!\n\n"
               "I'm your AI assistant powered by Critical Future. I can help with:\n"
               "• Answering questions and providing information\n"
               "• Assisting with tasks and problem-solving\n"
               "• Engaging in natural conversations\n\n"
               "You can type your message or use the voice input options. How can I assist you today?",
          isUser: false,
          timestamp: DateTime.now(),
          isVoice: false,
        ),
      );
    });
  }

  bool _isSidebarExpanded = false;



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarExpanded = !_isSidebarExpanded;
            });
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/cf_logo.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text('CF-Assistant',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New chat',
            onPressed: () {
              context.read<ChatProvider>().startNewChat();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset current chat',
            onPressed: () => context.read<ChatProvider>().resetCurrentChat(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
              ? [
                  Colors.grey[900]!,
                  Colors.grey[850]!,
                ]
              : [
                  Colors.blue[50]!,
                  Colors.white,
                ],
          ),
        ),
        child: Row(
          children: [
            Sidebar(
              isExpanded: _isSidebarExpanded,
              onToggle: () {
                setState(() {
                  _isSidebarExpanded = !_isSidebarExpanded;
                });
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Close sidebar when tapping on the chat area
                  if (_isSidebarExpanded) {
                    setState(() {
                      _isSidebarExpanded = false;
                    });
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          if (chatProvider.messages.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/cf_logo.png',
                                    width: 80,
                                    height: 80,
                                    color: isDarkMode ? Colors.white70 : Colors.blue[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Start a new conversation!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode ? Colors.white70 : Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ask me anything or try voice input',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white60 : Colors.blue[400],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListView.builder(
                              itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == chatProvider.messages.length && chatProvider.isTyping) {
                                  return const TypingIndicator();
                                }
                                final message = chatProvider.messages[index];
                                return ChatMessageWidget(message: message);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const FooterWidget(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 5,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextInputField(
                              onSubmitted: (String text) {
                                context.read<ChatProvider>().sendMessage(text);
                              },
                            ),
                          ),
                          const VoiceInputButton(),
                          const LiveVoiceChatWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Text('CF-Assistant is typing', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(width: 8),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}

