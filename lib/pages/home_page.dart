import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../utils/icon_utils.dart';
import '../widgets/side_menu.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'create_post_page.dart';
import 'feeds_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MenuItem> menus = [];
  bool isLoading = true;
  String? errorMessage;

  // Constants for better maintainability
  static const double _headerRadius = 30.0;
  static const double _bannerHeight = 180.0;
  static const double _bannerOffset = -60.0; // Reduced from -80
  static const double _profileRadius = 25.0;
  static const int _gridCrossAxisCount = 4;
  static const double _gridSpacing = 20.0;

  // Color constants
  static const List<Color> _gradientColors = [
    Color.fromARGB(255, 192, 21, 21),
    Color.fromARGB(255, 233, 90, 90)
  ];

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      debugPrint('Starting to load menus...');
      final fetchedMenus = await ApiService.getMenus().timeout(
        const Duration(seconds: 8),
      );

      if (!mounted) return;

      debugPrint('API Response: Fetched ${fetchedMenus.length} menus');
      
      setState(() {
        menus = fetchedMenus;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('API Error: $e');

      if (!mounted) return;

      setState(() {
        menus = [];
        isLoading = false;
        errorMessage = 'Failed to load menus. Please try again.';
      });
    }
  }



  Future<void> _refreshMenus() async {
    await _loadMenus();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        drawer: const SideMenu(),
        body: RefreshIndicator(
          onRefresh: _refreshMenus,
          child: Column(
            children: [
              _buildHeaderSection(),
              _buildBannerSection(),
              _buildMenuSection(),
            ],
          ),
        ),

      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_headerRadius),
          bottomRight: Radius.circular(_headerRadius),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildProfileSection(),
            const SizedBox(height: 100), // Reduced from 140
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              tooltip: 'Open menu',
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Implement QR scanner
              debugPrint('QR scanner tapped');
            },
            icon: const Icon(Icons.qr_code_scanner,
                color: Colors.white, size: 24),
            tooltip: 'Scan QR code',
          ),
          IconButton(
            onPressed: _refreshMenus,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            tooltip: 'Refresh',
          ),
          _buildNotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications, color: Colors.white, size: 24),
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
                '5',
                style: TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      tooltip: 'Notifications',
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: _profileRadius,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, size: 30, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Santhosh Kumar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            tooltip: 'Edit profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return Transform.translate(
      offset: const Offset(0, _bannerOffset),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        height: _bannerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/banner.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildBannerFallback(),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Banner Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, -20), // Add negative offset to pull menus up
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildMenuContent(),
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading menus...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshMenus,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (menus.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No menus available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridCrossAxisCount,
        mainAxisSpacing: _gridSpacing,
        crossAxisSpacing: _gridSpacing,
        childAspectRatio: 0.8,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return _buildMenuItem(menu);
      },
    );
  }

  Widget _buildMenuItem(MenuItem menu) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FeedsPage(filterCategory: menu.name),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              IconUtils.getEmojiFromString(menu.icon, menu.name),
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                menu.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
