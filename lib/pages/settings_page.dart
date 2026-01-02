import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('selected_language', _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFDC143C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.notifications),
          //   title: const Text('Notifications'),
          //   subtitle: const Text('Receive push notifications'),
          //   trailing: Switch(
          //     value: _notificationsEnabled,
          //     activeColor: const Color(0xFFDC143C),
          //     onChanged: (value) {
          //       setState(() {
          //         _notificationsEnabled = value;
          //       });
          //       _saveSettings();
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(
          //           content: Text(
          //             _notificationsEnabled
          //               ? 'Notifications enabled'
          //               : 'Notifications disabled'
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            onTap: () {
              _showPrivacyDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            subtitle: const Text('Read terms and conditions'),
            onTap: () {
              _showTermsDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete Account'),
            subtitle: const Text('Permanently delete your account'),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve the app'),
            onTap: () {
              _showFeedbackDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Tamil'),
              value: 'Tamil',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'We respect your privacy and are committed to protecting your personal data. '
            'This privacy policy explains how we collect, use, and protect your information '
            'when you use our app.\n\n'
            '1. Information We Collect\n'
            '2. How We Use Your Information\n'
            '3. Data Security\n'
            '4. Your Rights\n\n'
            'For the complete privacy policy, visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using this app, you agree to our terms and conditions:\n\n'
            '1. Acceptable Use\n'
            '2. User Content\n'
            '3. Prohibited Activities\n'
            '4. Termination\n\n'
            'For the complete terms of service, visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'My Group App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.apps, size: 64),
      children: [
        const Text('A social networking app for local communities.'),
      ],
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Tell us what you think...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
