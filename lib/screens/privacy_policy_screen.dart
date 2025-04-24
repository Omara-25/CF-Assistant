import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Last Updated: June 1, 2024',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Introduction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Critical Future ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you use our CF-Assistant application and tell you about your privacy rights and how the law protects you.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Information We Collect',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We may collect, use, store, and transfer different kinds of personal data about you which we have grouped together as follows:\n\n'
              '• Identity Data includes first name, last name, username or similar identifier.\n'
              '• Contact Data includes email address and telephone numbers.\n'
              '• Technical Data includes internet protocol (IP) address, your login data, browser type and version, time zone setting and location, browser plug-in types and versions, operating system and platform, and other technology on the devices you use to access this application.\n'
              '• Usage Data includes information about how you use our application and services.\n'
              '• Voice Data includes recordings of your voice when you use the voice assistant features.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'How We Use Your Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:\n\n'
              '• To provide and maintain our service\n'
              '• To notify you about changes to our service\n'
              '• To provide customer support\n'
              '• To gather analysis or valuable information so that we can improve our service\n'
              '• To monitor the usage of our service\n'
              '• To detect, prevent and address technical issues',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Data Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used, or accessed in an unauthorized way, altered, or disclosed. In addition, we limit access to your personal data to those employees, agents, contractors, and other third parties who have a business need to know.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Your Legal Rights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Under certain circumstances, you have rights under data protection laws in relation to your personal data, including the right to:\n\n'
              '• Request access to your personal data\n'
              '• Request correction of your personal data\n'
              '• Request erasure of your personal data\n'
              '• Object to processing of your personal data\n'
              '• Request restriction of processing your personal data\n'
              '• Request transfer of your personal data\n'
              '• Right to withdraw consent',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'If you have any questions about this privacy policy or our privacy practices, please contact us at:\n\n'
              'Email: info@criticalfuture.co.uk\n'
              'Critical Future\n'
              'London, United Kingdom',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
