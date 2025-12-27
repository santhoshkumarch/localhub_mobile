import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'main_tabs.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _deleteSpecificUser();

    Timer(const Duration(milliseconds: 2500), () async {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainTabs()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  void _deleteSpecificUser() async {
    const phone = '9944542511';
    
    // Clear local storage for this user
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name_$phone');
      await prefs.remove('user_type_$phone');
      await prefs.remove('user_email_$phone');
      await prefs.remove('user_category_$phone');
      await prefs.remove('user_address_$phone');
      print('Cleared local storage for user $phone');
    } catch (e) {
      print('Error clearing local storage: $e');
    }
  }

  Future<Map<String, dynamic>> _checkLoginStatus(String phone) async {
    const baseUrls = [
      'https://localhubbackend-production.up.railway.app/api',
      'https://localhubbackend-production.up.railway.app/api'
    ];

    for (String baseUrl in baseUrls) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/check-user'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phone': phone}),
        );
        if (response.statusCode == 200) {
          return json.decode(response.body);
        }
      } catch (e) {
        continue;
      }
    }
    return {'exists': false, 'isLoggedIn': false};
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 300,
                  height: 300,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
