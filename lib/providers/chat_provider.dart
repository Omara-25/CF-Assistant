import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'chat_flow_provider.dart';
import '../models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final ChatFlowProvider chatFlowProvider;
  List<ChatMessage> _messages = [];
  List<ChatHistory> _chatHistory = [];
  final List<ChatHistory> _archivedChats = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  List<ChatHistory> get chatHistory => _chatHistory;
  bool get isTyping => _isTyping;

  ChatProvider({required this.chatFlowProvider}) {
    _loadChatHistory();
    _loadMessages();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('chat_history') ?? [];
    _chatHistory = historyJson
        .map((json) => ChatHistory.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _chatHistory
        .map((chat) => jsonEncode(chat.toJson()))
        .toList();
    await prefs.setStringList('chat_history', historyJson);
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('messages');
    if (messagesJson != null) {
      final List<dynamic> decodedMessages = jsonDecode(messagesJson);
      _messages = decodedMessages.map((m) => ChatMessage.fromJson(m)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('messages', messagesJson);
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
    _saveMessages();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
    _saveMessages();
  }

  void resetCurrentChat() {
    _messages.clear();
    notifyListeners();
    _saveMessages();
  }

  Future<void> sendMessage(String message, {File? attachment, bool isVoice = false}) async {
    if (message.trim().isEmpty && attachment == null) return;

    final activeChatFlow = chatFlowProvider.activeChatFlow;
    if (activeChatFlow == null) {
      addMessage(ChatMessage(
        text: "Error: No chat flow configured. Please set up a chat flow first.",
        isUser: false,
        timestamp: DateTime.now(),
        isVoice: false,
      ));
      return;
    }

    addMessage(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
      attachment: attachment,
      isVoice: isVoice,
    ));

    _isTyping = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${activeChatFlow.apiUrl}/api/v1/prediction/${activeChatFlow.flowId}')
      );

      if (activeChatFlow.apiKey.isNotEmpty) {
        request.headers.addAll({
          'Authorization': 'Bearer ${activeChatFlow.apiKey}',
          'Content-Type': 'multipart/form-data',
        });
      } else {
        request.headers.addAll({
          'Content-Type': 'multipart/form-data',
        });
      }

      request.fields['question'] = message;

      if (attachment != null) {
        request.files.add(await http.MultipartFile.fromPath('file', attachment.path));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        final aiResponse = responseData['text'] ?? 'No response';
        addMessage(ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
          isVoice: false,
        ));
      } else {
        print('Error response: $responseBody');
        addMessage(ChatMessage(
          text: 'Error: Server returned ${response.statusCode}',
          isUser: false,
          timestamp: DateTime.now(),
          isVoice: false,
        ));
      }
    } catch (e) {
      print('Exception details: $e');
      addMessage(ChatMessage(
        text: 'Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
        isVoice: false,
      ));
    }

    _isTyping = false;
    notifyListeners();
  }

  Future<void> sendVoiceMessage(String text) async {
    await sendMessage(text, isVoice: true);
  }

  void startNewChat() {
    if (_messages.isNotEmpty) {
      final existingChatIndex = _chatHistory.indexWhere(
        (chat) => chat.title == _messages.first.text,
      );

      if (existingChatIndex != -1) {
        _chatHistory[existingChatIndex] = ChatHistory(
          id: _chatHistory[existingChatIndex].id,
          title: _messages.first.text,
          lastMessage: _messages.last.text,
          timestamp: DateTime.now(),
          messages: List.from(_messages),
        );
      } else {
        final chatHistory = ChatHistory(
          id: DateTime.now().toString(),
          title: _messages.first.text,
          lastMessage: _messages.last.text,
          timestamp: DateTime.now(),
          messages: List.from(_messages),
        );
        _chatHistory.insert(0, chatHistory);
      }

      _saveChatHistory();
    }

    _messages = [];
    notifyListeners();
    _saveMessages();
  }

  Future<void> loadChat(String chatId) async {
    final chat = _chatHistory.firstWhere((chat) => chat.id == chatId);
    _messages = List.from(chat.messages);
    notifyListeners();
    _saveMessages();
  }

  void deleteChat(String chatId) {
    _chatHistory.removeWhere((chat) => chat.id == chatId);
    _saveChatHistory();
    notifyListeners();
  }

  void archiveChat(String chatId) {
    final chatIndex = _chatHistory.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      final archivedChat = _chatHistory.removeAt(chatIndex);
      _archivedChats.insert(0, archivedChat);
      _saveChatHistory();
      notifyListeners();
    }
  }

  void renameChat(String chatId, String newTitle) {
    final chatIndex = _chatHistory.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      _chatHistory[chatIndex] = ChatHistory(
        id: _chatHistory[chatIndex].id,
        title: newTitle,
        lastMessage: _chatHistory[chatIndex].lastMessage,
        timestamp: _chatHistory[chatIndex].timestamp,
        messages: _chatHistory[chatIndex].messages,
      );
      _saveChatHistory();
      notifyListeners();
    }
  }

  void clearChatHistory() {
    _chatHistory.clear();
    _saveChatHistory();
    notifyListeners();
  }
}

class ChatHistory {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final List<ChatMessage> messages;

  ChatHistory({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'lastMessage': lastMessage,
    'timestamp': timestamp.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory ChatHistory.fromJson(Map<String, dynamic> json) => ChatHistory(
    id: json['id'],
    title: json['title'],
    lastMessage: json['lastMessage'],
    timestamp: DateTime.parse(json['timestamp']),
    messages: (json['messages'] as List)
        .map((m) => ChatMessage.fromJson(m))
        .toList(),
  );
}

