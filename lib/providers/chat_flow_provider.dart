import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_flow.dart';

class ChatFlowProvider with ChangeNotifier {
  List<ChatFlow> _chatFlows = [];
  String? _activeChatFlowId;

  List<ChatFlow> get chatFlows => _chatFlows;
  String? get activeChatFlowId => _activeChatFlowId;

  ChatFlow? get activeChatFlow {
    if (_activeChatFlowId == null) return null;
    try {
      return _chatFlows.firstWhere((flow) => flow.id == _activeChatFlowId);
    } catch (e) {
      return null;
    }
  }

  ChatFlowProvider() {
    _loadChatFlows();
  }

  Future<void> _loadChatFlows() async {
    final prefs = await SharedPreferences.getInstance();
    final flowsJson = prefs.getStringList('chat_flows') ?? [];
    final activeId = prefs.getString('active_chat_flow_id');

    _chatFlows = flowsJson
        .map((json) => ChatFlow.fromJson(jsonDecode(json)))
        .toList();
    _activeChatFlowId = activeId;
    
    // If there's no active flow but we have flows, set the first one as active
    if (_activeChatFlowId == null && _chatFlows.isNotEmpty) {
      _activeChatFlowId = _chatFlows.first.id;
      _saveActiveChatFlow();
    }
    
    notifyListeners();
  }

  Future<void> _saveChatFlows() async {
    final prefs = await SharedPreferences.getInstance();
    final flowsJson = _chatFlows
        .map((flow) => jsonEncode(flow.toJson()))
        .toList();
    await prefs.setStringList('chat_flows', flowsJson);
  }

  Future<void> _saveActiveChatFlow() async {
    final prefs = await SharedPreferences.getInstance();
    if (_activeChatFlowId != null) {
      await prefs.setString('active_chat_flow_id', _activeChatFlowId!);
    } else {
      await prefs.remove('active_chat_flow_id');
    }
  }

  void addChatFlow(ChatFlow chatFlow) {
    _chatFlows.add(chatFlow);
    
    // If this is the first flow, make it active
    if (_chatFlows.length == 1) {
      _activeChatFlowId = chatFlow.id;
      _saveActiveChatFlow();
    }
    
    _saveChatFlows();
    notifyListeners();
  }

  void updateChatFlow(ChatFlow chatFlow) {
    final index = _chatFlows.indexWhere((flow) => flow.id == chatFlow.id);
    if (index != -1) {
      _chatFlows[index] = chatFlow;
      _saveChatFlows();
      notifyListeners();
    }
  }

  void deleteChatFlow(String id) {
    _chatFlows.removeWhere((flow) => flow.id == id);
    
    // If we deleted the active flow, set a new active flow
    if (_activeChatFlowId == id) {
      _activeChatFlowId = _chatFlows.isNotEmpty ? _chatFlows.first.id : null;
      _saveActiveChatFlow();
    }
    
    _saveChatFlows();
    notifyListeners();
  }

  void setActiveChatFlow(String id) {
    _activeChatFlowId = id;
    _saveActiveChatFlow();
    notifyListeners();
  }
}

