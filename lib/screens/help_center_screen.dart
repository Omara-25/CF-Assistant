import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@criticalfuture.co.uk',
      queryParameters: {
        'subject': 'Help Request',
      },
    );
    
    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not launch email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              title: Text('Contact Support'),
              subtitle: Text('Get help with your account or technical issues'),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _launchEmail,
            icon: const Icon(Icons.email),
            label: const Text('Email Support'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Contact us at: info@criticalfuture.co.uk',
            style: TextStyle(fontSize: 16),
          ),
          // Add FAQ section or other help resources
        ],
      ),
    );
  }
}