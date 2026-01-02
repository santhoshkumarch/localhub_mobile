import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFFDC143C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('FAQ'),
              subtitle: const Text('Frequently asked questions'),
              onTap: () {
                _showFAQDialog(context);
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.contact_support),
              title: const Text('Contact Support'),
              subtitle: const Text('Get help from our team'),
              onTap: () {
                _showContactDialog(context);
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              subtitle: const Text('Share your thoughts'),
              onTap: () {
                _showFeedbackDialog(context);
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Terms & Privacy'),
              subtitle: const Text('Read our policies'),
              onTap: () {
                _showPolicyDialog(context);
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Report a Bug'),
              subtitle: const Text('Help us fix issues'),
              onTap: () {
                _showBugReportDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  static void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: How do I create a post?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Tap the + button on the home screen and fill in your post details.\n'),
              Text('Q: How do I edit my profile?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Go to Profile tab and tap the edit button.\n'),
              Text('Q: How do I change my password?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Go to Settings > Account > Change Password.\n'),
              Text('Q: How do I delete my account?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Go to Settings > Account > Delete Account.'),
            ],
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
  
  static void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: support@mygroupapp.com'),
            SizedBox(height: 8),
            Text('Phone: +91 9876543210'),
            SizedBox(height: 8),
            Text('Hours: Mon-Fri 9AM-6PM IST'),
            SizedBox(height: 16),
            Text('We typically respond within 24 hours.'),
          ],
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
  
  static void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We value your feedback! Let us know how we can improve.'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Your feedback...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
  
  static void _showPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service:\n'
            '1. You must be 13+ years old to use this app\n'
            '2. Do not post inappropriate content\n'
            '3. Respect other users\n\n'
            'Privacy Policy:\n'
            '1. We protect your personal information\n'
            '2. We do not sell your data\n'
            '3. You can delete your account anytime\n\n'
            'For complete terms, visit our website.',
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
  
  static void _showBugReportDialog(BuildContext context) {
    final TextEditingController bugController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Found a bug? Help us fix it by describing what happened.'),
            const SizedBox(height: 16),
            TextField(
              controller: bugController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the bug...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                const SnackBar(content: Text('Bug report submitted. Thank you!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}