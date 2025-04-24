import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_flow_provider.dart';
import '../models/chat_flow.dart';

class ChatFlowSelector extends StatelessWidget {
  const ChatFlowSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatFlowProvider>(
      builder: (context, provider, child) {
        if (provider.chatFlows.isEmpty) {
          return ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('No chat flows configured'),
            subtitle: const Text('Add a chat flow to continue'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/chat-flows');
              },
            ),
          );
        }

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: provider.activeChatFlowId,
            icon: const Icon(Icons.arrow_drop_down),
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onChanged: (String? newValue) {
              if (newValue != null) {
                provider.setActiveChatFlow(newValue);
              }
            },
            items: provider.chatFlows.map<DropdownMenuItem<String>>((ChatFlow flow) {
              return DropdownMenuItem<String>(
                value: flow.id,
                child: Text(
                  flow.name,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

