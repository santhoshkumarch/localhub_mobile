import 'package:flutter/material.dart';
import '../widgets/side_menu.dart';
import '../services/api_service.dart';
import 'notifications_page.dart';

class DirectoryPage extends StatefulWidget {
  const DirectoryPage({super.key});

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  List<Map<String, dynamic>> _businesses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  void _loadBusinesses() async {
    setState(() => _loading = true);
    final businesses = await ApiService.getBusinesses();
    setState(() {
      _businesses = businesses;
      _loading = false;
    });
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'it services':
      case 'technology':
        return Icons.computer;
      case 'clothing':
      case 'fashion':
        return Icons.shopping_bag;
      case 'automotive':
        return Icons.car_repair;
      case 'healthcare':
      case 'medical':
        return Icons.local_hospital;
      case 'grocery':
        return Icons.local_grocery_store;
      default:
        return Icons.business;
    }
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _businesses.isEmpty
              ? const Center(
                  child: Text(
                    'No businesses found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _businesses.length,
                  itemBuilder: (context, index) {
                    final business = _businesses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFDC143C),
                          child: Icon(
                            _getCategoryIcon(business['category']),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          business['name'] ?? 'Unknown Business',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(business['category'] ?? 'General'),
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