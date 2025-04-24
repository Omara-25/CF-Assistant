import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_flow_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/history_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/sign_in_screen.dart';
import '../models/chat_flow.dart';
import 'chat_flow_dialog.dart';

class Sidebar extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const Sidebar({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isChatFlowExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final chatFlowProvider = Provider.of<ChatFlowProvider>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isExpanded ? 220 : 0,
      child: Drawer(
        child: ListView(
          children: [
            const SizedBox(height: 12),
            // CF Logo and Sign In/Out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  if (authProvider.isAuthenticated) {
                    authProvider.signOut();
                  } else {
                    // Close sidebar before navigation
                    widget.onToggle();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Image.asset(
                        'assets/cf_logo.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        authProvider.isAuthenticated ? 'Sign Out' : 'Sign In',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.grey),

            // Chat Flow Management Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  // Toggle expansion
                  setState(() {
                    _isChatFlowExpanded = !_isChatFlowExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Icon(Icons.api, color: theme.iconTheme.color, size: 20),
                          ),
                          Flexible(
                            child: Text(
                              'Chat Flows',
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isChatFlowExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.iconTheme.color,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (_isChatFlowExpanded) ...[
                // Active Chat Flow Selector
                if (chatFlowProvider.chatFlows.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Active Chat Flow',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      value: chatFlowProvider.activeChatFlowId,
                      items: chatFlowProvider.chatFlows.map((ChatFlow flow) {
                        return DropdownMenuItem<String>(
                          value: flow.id,
                          child: Text(
                            flow.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          chatFlowProvider.setActiveChatFlow(newValue);
                          // Close sidebar when a chat flow is selected
                          widget.onToggle();
                        }
                      },
                    ),
                  ),

                // List of Chat Flows
                ...chatFlowProvider.chatFlows.map((flow) => Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 10.0, top: 4.0, bottom: 4.0),
                  child: InkWell(
                    onTap: () {
                      chatFlowProvider.setActiveChatFlow(flow.id);
                      widget.onToggle();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flow.name,
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: chatFlowProvider.activeChatFlowId == flow.id
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                flow.apiUrl,
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 14,
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Close sidebar before showing dialog
                                    widget.onToggle();
                                    showDialog(
                                      context: context,
                                      builder: (context) => ChatFlowDialog(
                                        chatFlow: flow,
                                        isEditing: true,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 14,
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    // Close sidebar before showing dialog
                                    widget.onToggle();
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Chat Flow'),
                                        content: Text('Are you sure you want to delete "${flow.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              chatFlowProvider.deleteChatFlow(flow.id);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

                // Add New Chat Flow Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Chat Flow'),
                    onPressed: () {
                      // Close sidebar before showing dialog
                      widget.onToggle();
                      showDialog(
                        context: context,
                        builder: (context) => const ChatFlowDialog(),
                      );
                    },
                  ),
                ),
              ],
            // History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  // Close sidebar before navigation
                  widget.onToggle();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Icon(Icons.history, color: theme.iconTheme.color, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        'History',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.grey),

            // Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  // Close sidebar before navigation
                  widget.onToggle();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Icon(Icons.settings, color: theme.iconTheme.color, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Help Center
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  // Close sidebar before navigation
                  widget.onToggle();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Icon(Icons.help_outline, color: theme.iconTheme.color, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        'Help Center',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
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

