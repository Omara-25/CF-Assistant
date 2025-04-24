import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_flow_provider.dart';
import '../models/chat_flow.dart';

class ChatFlowDialog extends StatefulWidget {
  final ChatFlow? chatFlow;
  final bool isEditing;

  const ChatFlowDialog({
    Key? key,
    this.chatFlow,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<ChatFlowDialog> createState() => _ChatFlowDialogState();
}

class _ChatFlowDialogState extends State<ChatFlowDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _flowIdController = TextEditingController();
  final _apiUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.chatFlow != null) {
      _nameController.text = widget.chatFlow!.name;
      _flowIdController.text = widget.chatFlow!.flowId;
      _apiUrlController.text = widget.chatFlow!.apiUrl;
      _apiKeyController.text = widget.chatFlow!.apiKey;
    } else {
      // Default values for new chat flow
      _apiUrlController.text = 'https://llminabox.criticalfutureglobal.com';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _flowIdController.dispose();
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveChatFlow() {
    if (_formKey.currentState!.validate()) {
      final chatFlowProvider = context.read<ChatFlowProvider>();
      
      final chatFlow = ChatFlow(
        id: widget.isEditing ? widget.chatFlow!.id : DateTime.now().toString(),
        name: _nameController.text,
        flowId: _flowIdController.text,
        apiUrl: _apiUrlController.text,
        apiKey: _apiKeyController.text,
      );

      if (widget.isEditing) {
        chatFlowProvider.updateChatFlow(chatFlow);
      } else {
        chatFlowProvider.addChatFlow(chatFlow);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Chat Flow' : 'Add New Chat Flow'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Flow Name',
                  hintText: 'e.g. Customer Support Bot',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _flowIdController,
                decoration: const InputDecoration(
                  labelText: 'Flowise Chat Flow ID',
                  hintText: 'e.g. 5b81df01-af37-4717-982e-1322ab09cf96',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a flow ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiUrlController,
                decoration: const InputDecoration(
                  labelText: 'API Host URL',
                  hintText: 'e.g. https://your-flowise-instance.com',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an API URL';
                  }
                  if (!Uri.parse(value).isAbsolute) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key (Optional)',
                  hintText: 'Leave blank if not required',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveChatFlow,
          child: Text(widget.isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}

