import 'package:flutter/material.dart';
import '../widgets/side_menu.dart';
import 'notifications_page.dart';

class DirectoryPage extends StatelessWidget {
  const DirectoryPage({super.key});

  final List<Map<String, dynamic>> mockBusinesses = const [
    {
      'name': 'Tamil Spice Restaurant',
      'category': 'Restaurant',
      'location': 'Chennai',
      'rating': 4.5,
      'image': Icons.restaurant,
    },
    {
      'name': 'Tech Solutions Ltd',
      'category': 'IT Services',
      'location': 'Coimbatore',
      'rating': 4.8,
      'image': Icons.computer,
    },
    {
      'name': 'Fashion Hub',
      'category': 'Clothing',
      'location': 'Madurai',
      'rating': 4.2,
      'image': Icons.shopping_bag,
    },
    {
      'name': 'Auto Care Center',
      'category': 'Automotive',
      'location': 'Salem',
      'rating': 4.6,
      'image': Icons.car_repair,
    },
    {
      'name': 'Health Plus Clinic',
      'category': 'Healthcare',
      'location': 'Trichy',
      'rating': 4.9,
      'image': Icons.local_hospital,
    },
    {
      'name': 'Green Grocers',
      'category': 'Grocery',
      'location': 'Tirunelveli',
      'rating': 4.3,
      'image': Icons.local_grocery_store,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Business Directory'),
        backgroundColor: const Color(0xFFDC143C),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Text(
                      '1',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockBusinesses.length,
        itemBuilder: (context, index) {
          final business = mockBusinesses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFDC143C),
                child: Icon(
                  business['image'],
                  color: Colors.white,
                ),
              ),
              title: Text(
                business['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(business['category']),
                  Text(
                    business['location'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(
                    business['rating'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped on ${business['name']}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}