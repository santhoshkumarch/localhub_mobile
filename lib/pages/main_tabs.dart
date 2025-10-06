import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'feeds_page.dart';
import 'my_posts_page.dart';
import 'directory_page.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final List<GlobalKey> _pageKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    
    // Trigger refresh for feeds and my posts pages
    if (index == 1 || index == 2) {
      Future.delayed(const Duration(milliseconds: 250), () {
        final currentState = _pageKeys[index].currentState;
        if (currentState != null) {
          try {
            (currentState as dynamic).refreshPosts();
          } catch (e) {
            print('Error refreshing posts: $e');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: [
            HomePage(key: _pageKeys[0]),
            FeedsPage(key: _pageKeys[1]),
            MyPostsPage(key: _pageKeys[2]),
            DirectoryPage(key: _pageKeys[3]),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: const Color(0xFFDC143C),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Text('🏠', style: TextStyle(fontSize: 24)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Text('📰', style: TextStyle(fontSize: 24)),
              label: 'Feeds',
            ),
            BottomNavigationBarItem(
              icon: Text('📝', style: TextStyle(fontSize: 24)),
              label: 'My Posts',
            ),
            BottomNavigationBarItem(
              icon: Text('🏢', style: TextStyle(fontSize: 24)),
              label: 'Directory',
            ),
          ],
        ),
      ),
    );
  }
}