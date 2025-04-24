import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_flow_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/live_voice_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/help_center_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatFlowProvider()),
        ChangeNotifierProxyProvider<ChatFlowProvider, ChatProvider>(
          create: (context) => ChatProvider(
            chatFlowProvider: Provider.of<ChatFlowProvider>(context, listen: false),
          ),
          update: (context, chatFlowProvider, previous) =>
            ChatProvider(chatFlowProvider: chatFlowProvider),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Mai - AI Voice Assistant',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: const ChatScreen(),
          debugShowCheckedModeBanner: false, // Hides the debug banner
          routes: {
            '/live_voice_screen': (context) => const LiveVoiceScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/help_center': (context) => const HelpCenterScreen(),
          },
        );
      },
    );
  }
}

