import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  final List<Map<String, dynamic>> mockNotifications = const [
    {
      'id': 1,
      'title': 'New Business Registration',
      'message': 'Tech Solutions Ltd has registered as a new business in Coimbatore',
      'timestamp': '2 hours ago',
      'type': 'business',
      'isRead': false,
    },
    {
      'id': 2,
      'title': 'Post Liked',
      'message': 'Ravi Kumar liked your post about restaurant opening',
      'timestamp': '4 hours ago',
      'type': 'like',
      'isRead': false,
    },
    {
      'id': 3,
      'title': 'New Comment',
      'message': 'Priya commented on your textile business post',
      'timestamp': '6 hours ago',
      'type': 'comment',
      'isRead': true,
    },
    {
      'id': 4,
      'title': 'Directory Update',
      'message': 'Your business listing has been approved and is now live',
      'timestamp': '1 day ago',
      'type': 'approval',
      'isRead': true,
    },
    {
      'id': 5,
      'title': 'New Follower',
      'message': 'Green Grocers started following your business',
      'timestamp': '2 days ago',
      'type': 'follow',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFFDC143C),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: const Text(
              'Mark All Read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final notification = mockNotifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notification['isRead'] 
                    ? Colors.grey.shade300 
                    : const Color(0xFFDC143C),
                child: Icon(
                  _getNotificationIcon(notification['type']),
                  color: notification['isRead'] ? Colors.grey : Colors.white,
                ),
              ),
              title: Text(
                notification['title'],
                style: TextStyle(
                  fontWeight: notification['isRead'] 
                      ? FontWeight.normal 
                      : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notification['message']),
                  const SizedBox(height: 4),
                  Text(
                    notification['timestamp'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: notification['isRead'] 
                  ? null 
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC143C),
                        shape: BoxShape.circle,
                      ),
                    ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opened: ${notification['title']}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'business':
        return Icons.business;
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'approval':
        return Icons.check_circle;
      case 'follow':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }
}