import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'otp_page.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final String phone;
  const RegisterPage({super.key, required this.phone});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  bool _registering = false;
  bool _checking = true;
  bool _userExists = false;
  
  @override
  void initState() {
    super.initState();
    _checkUser();
  }
  
  void _checkUser() async {
    final userCheck = await _checkUserExists(widget.phone);
    setState(() {
      _userExists = userCheck['exists'];
      _checking = false;
    });
  }

  void _register() async {
    setState(() => _registering = true);
    
    try {
      // First check if user exists
      final userCheck = await _checkUserExists(widget.phone);
      
      if (userCheck['exists']) {
        // User exists, just send OTP
        final otpSent = await ApiService.sendOtp(widget.phone);
        if (otpSent) {
          // Save last phone for future auto-fill
          await AuthService.saveLastPhone(widget.phone);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => OTPPage(phone: widget.phone)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to send OTP')));
        }
      } else {
        // New user, need name
        final name = _nameCtrl.text.trim();
        if (name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your name')));
          setState(() => _registering = false);
          return;
        }
        
        final success = await ApiService.registerUser(widget.phone, name);
        if (success) {
          final otpSent = await ApiService.sendOtp(widget.phone);
          if (otpSent) {
            // Save last phone for future auto-fill
            await AuthService.saveLastPhone(widget.phone);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => OTPPage(phone: widget.phone)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registration successful but failed to send OTP')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration failed. Please try again.')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please check your connection.')));
    }
    
    setState(() => _registering = false);
  }
  
  Future<Map<String, dynamic>> _checkUserExists(String phone) async {
    const baseUrls = ['http://localhost:5000/api', 'http://10.0.2.2:5000/api'];
    
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
    return {'exists': false};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 192, 21, 21), Color.fromARGB(255, 233, 90, 90)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userExists ? 'Welcome Back' : 'Create Account',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your details for ${widget.phone}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_userExists && !_checking)
                          TextField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: const TextStyle(color: Colors.black54),
                              hintText: 'Enter your full name',
                              hintStyle: const TextStyle(color: Colors.black38),
                              prefixIcon: const Icon(Icons.person_outline, color: Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black26),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFDC143C), width: 2),
                              ),
                            ),
                          ),
                        if (!_userExists && !_checking) const SizedBox(height: 24),
                        if (_checking)
                          const CircularProgressIndicator(color: Color(0xFFDC143C))
                        else
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _registering ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC143C),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _registering
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    _userExists ? 'Send OTP' : 'Create Account',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}