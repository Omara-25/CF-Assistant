import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'profile_edit_screen.dart';
import 'security_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_center_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildAccountSettings(context),

          const SizedBox(height: 16),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeSettings(context),
          _buildFontSettings(context),

          const SizedBox(height: 16),

          // Subscription Section
          _buildSectionHeader(context, 'Subscription'),
          _buildSubscriptionCards(context),

          const SizedBox(height: 16),

          // Notification Section
          _buildSectionHeader(context, 'Notifications'),
          _buildNotificationSettings(context),

          const SizedBox(height: 16),

          // Privacy Section
          _buildSectionHeader(context, 'Privacy'),
          _buildPrivacySettings(context),

          const SizedBox(height: 16),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildAboutSettings(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: Text(authProvider.userEmail ?? 'Edit your personal information'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security'),
            subtitle: const Text('Manage password and security settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.color_lens),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButton<ThemeMode>(
                        isExpanded: true,
                        value: themeProvider.themeMode,
                        onChanged: (ThemeMode? newValue) {
                          if (newValue != null) {
                            themeProvider.setThemeMode(newValue);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System Default'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light Mode'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark Mode'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFontSettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Chat Font Size'),
                subtitle: Text(settingsProvider.fontSizeLabel),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showFontSizeDialog(context, settingsProvider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Font Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFontSizeOption(context, 'Small', 14.0, settingsProvider),
              _buildFontSizeOption(context, 'Medium', 16.0, settingsProvider),
              _buildFontSizeOption(context, 'Large', 18.0, settingsProvider),
              _buildFontSizeOption(context, 'Extra Large', 20.0, settingsProvider),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontSizeOption(
    BuildContext context,
    String label,
    double size,
    SettingsProvider settingsProvider
  ) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(fontSize: size),
      ),
      leading: Radio<String>(
        value: label,
        groupValue: settingsProvider.fontSizeLabel,
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setFontSize(size, value);
            Navigator.pop(context);
          }
        },
      ),
      onTap: () {
        settingsProvider.setFontSize(size, label);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSubscriptionCards(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('Free Trial'),
            subtitle: const Text('Try premium features for 7 days'),
            trailing: ElevatedButton(
              onPressed: () {
                _showSubscriptionDialog(context, 'Free Trial');
              },
              child: const Text('Start Trial'),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Premium Plan'),
            subtitle: const Text('£9.99/month'),
            trailing: ElevatedButton(
              onPressed: () {
                _showSubscriptionDialog(context, 'Premium Plan');
              },
              child: const Text('Subscribe'),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.stars),
            title: const Text('Annual Plan'),
            subtitle: const Text('£99.99/year (Save 17%)'),
            trailing: ElevatedButton(
              onPressed: () {
                _showSubscriptionDialog(context, 'Annual Plan');
              },
              child: const Text('Subscribe'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context, String planName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Subscribe to $planName'),
          content: const Text(
            'This feature is coming soon. In the future, you will be able to subscribe to premium plans to access advanced features.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive alerts for new messages'),
                value: settingsProvider.pushNotificationsEnabled,
                onChanged: (value) {
                  settingsProvider.togglePushNotifications(value);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.email),
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive weekly summary and updates'),
                value: settingsProvider.emailNotificationsEnabled,
                onChanged: (value) {
                  settingsProvider.toggleEmailNotifications(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrivacySettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.data_usage),
                title: const Text('Data Collection'),
                subtitle: const Text('Allow anonymous usage data collection'),
                value: settingsProvider.dataCollectionEnabled,
                onChanged: (value) {
                  settingsProvider.toggleDataCollection(value);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Account'),
                subtitle: const Text('Permanently remove your account and data'),
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Here you would implement the actual account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deletion request submitted')),
                );
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version'),
            subtitle: Text('1.0.0 (Build 42)'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('Rate the App'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _launchAppStore(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchAppStore(BuildContext context) async {
    // For Android
    final Uri androidUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.criticalfuture.cfassistant');
    // For iOS
    final Uri iosUrl = Uri.parse('https://apps.apple.com/app/cf-assistant/id123456789');

    try {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        if (await canLaunchUrl(iosUrl)) {
          await launchUrl(iosUrl);
        } else {
          throw 'Could not launch App Store';
        }
      } else {
        if (await canLaunchUrl(androidUrl)) {
          await launchUrl(androidUrl);
        } else {
          throw 'Could not launch Play Store';
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}