import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';



class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  List<MenuItem> _menus = [];
  MenuItem? _selectedMenu;
  String? _selectedLabel;
  String _userType = 'individual';
  String _userName = 'User';
  bool _loading = false;
  bool _creating = false;
  final List<File> _selectedImages = [];
  final bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _loadMenus();
    _checkFirstTimeUser();
  }

  void _checkFirstTimeUser() async {
    final phoneNumber = await AuthService.getPhone();
    final email = await AuthService.getEmail();
    final userName = await AuthService.getName();
    
    if (phoneNumber != null) {
      final profile = await ApiService.getProfile(phoneNumber);
      
      // Check local storage if API fails
      final prefs = await SharedPreferences.getInstance();
      final localName = prefs.getString('user_name_$phoneNumber');
      
      // Check if user has a complete profile (API or local)
      final hasProfile = (profile != null && profile['name'] != null && profile['name'].toString().trim().isNotEmpty) ||
                        (localName != null && localName.trim().isNotEmpty);
      
      if (!hasProfile) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFirstTimeProfileModal();
        });
      } else {
        _loadUserType();
      }
    } else if (email != null) {
      // Email user - check if they have completed profile
      final prefs = await SharedPreferences.getInstance();
      final profileCompleted = prefs.getBool('profile_completed_$email') ?? false;
      
      if (!profileCompleted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFirstTimeProfileModal();
        });
      } else {
        setState(() {
          _userName = userName ?? 'User';
          _userType = 'individual';
        });
      }
    }
  }

  void _loadMenus() async {
    setState(() => _loading = true);
    final menus = await ApiService.getMenus();
    setState(() {
      _menus = menus;
      _loading = false;
    });
  }

  void _loadUserType() async {
    final phoneNumber = await AuthService.getPhone();
    final email = await AuthService.getEmail();
    final userName = await AuthService.getName();
    
    if (phoneNumber != null) {
      // Try to get from API first
      final userType = await ApiService.getUserType(phoneNumber);
      final profile = await ApiService.getProfile(phoneNumber);
      
      // If API fails, try local storage
      if (profile == null || profile['name'] == null) {
        final prefs = await SharedPreferences.getInstance();
        final localName = prefs.getString('user_name_$phoneNumber');
        final localType = prefs.getString('user_type_$phoneNumber');
        
        setState(() {
          _userType = localType ?? userType ?? 'individual';
          _userName = localName ?? profile?['name'] ?? 'User';
        });
      } else {
        setState(() {
          _userType = userType ?? 'individual';
          _userName = profile['name'] ?? 'User';
        });
      }
    } else if (email != null) {
      final prefs = await SharedPreferences.getInstance();
      final profileType = prefs.getString('user_profile_type') ?? 'individual';
      
      setState(() {
        _userType = profileType;
        _userName = userName ?? 'User';
      });
    }
  }

  void _pickImages() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image upload feature will be available in the next update!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _menus.length,
            itemBuilder: (context, index) {
              final menu = _menus[index];
              return ListTile(
                leading: Text(menu.icon, style: const TextStyle(fontSize: 20)),
                title: Text(menu.name),
                onTap: () {
                  setState(() {
                    _selectedMenu = menu;
                    _selectedLabel = null;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLabelDialog() {
    if (_selectedMenu == null || _selectedMenu!.labels.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Label'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _selectedMenu!.labels.length,
            itemBuilder: (context, index) {
              final label = _selectedMenu!.labels[index];
              return ListTile(
                title: Text(label),
                onTap: () {
                  setState(() => _selectedLabel = label);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }



  void _showFirstTimeProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => FirstTimeProfileModal(
        onProfileComplete: () {
          _loadUserType();
        },
      ),
    );
  }

  void _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something')),
      );
      return;
    }

    setState(() => _creating = true);

    final phoneNumber = await AuthService.getPhone();
    final email = await AuthService.getEmail();
    
    if (phoneNumber == null && email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      setState(() => _creating = false);
      return;
    }

    final postData = {
      'title': _contentController.text.trim().split('\n')[0],
      'content': _contentController.text.trim(),
      'menuId': _selectedMenu?.id ?? 1,
      'assignedLabel': _selectedLabel,
      'phoneNumber': phoneNumber,
      'email': email,
      'mediaUrls': [],
      'status': 'pending', // Post starts as pending admin approval
    };

    final success = await ApiService.createPost(postData);
    setState(() => _creating = false);

    if (success) {
      // Show success dialog instead of snackbar
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Post Submitted!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your post has been sent to admin for approval.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'It will appear in feeds once approved by admin.',
                        style: TextStyle(color: Colors.blue[800], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(true); // Close create post page
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFFDC143C), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create post',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _creating || _contentController.text.trim().isEmpty ? null : _createPost,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _creating || _contentController.text.trim().isEmpty 
                      ? Colors.grey[300] 
                      : const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _creating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'POST',
                        style: TextStyle(
                          color: _creating || _contentController.text.trim().isEmpty 
                              ? Colors.grey[600] 
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildUserHeader(),
                        _buildContentInput(),
                        if (_selectedImages.isNotEmpty) _buildImagePreview(),
                      ],
                    ),
                  ),
                ),
                _buildBottomOptions(),
              ],
            ),
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFDC143C),
            child: Text(
              _userName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _userName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 16, color: color),
        ],
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _contentController,
            maxLines: null,
            minLines: 8,
            style: const TextStyle(fontSize: 18, color: Colors.black),
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
              border: InputBorder.none,
            ),
            onChanged: (value) => setState(() {}),
          ),
          if (_contentController.text.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: RichText(
                text: _buildHighlightedText(_contentController.text),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.keyboard_arrow_up, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  TextSpan _buildHighlightedText(String text) {
    final List<TextSpan> spans = [];
    final RegExp hashtagRegex = RegExp(r'#\w+');
    int lastMatchEnd = 0;

    for (final Match match in hashtagRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1877F2),
          fontWeight: FontWeight.w600,
        ),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ));
    }

    return TextSpan(children: spans);
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _selectedImages.length == 1 ? 1 : 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          _buildOptionItem(Icons.photo_library, 'Photo/video', Colors.green, _pickImages),
        ],
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }









  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}

class FirstTimeProfileModal extends StatefulWidget {
  final VoidCallback onProfileComplete;

  const FirstTimeProfileModal({super.key, required this.onProfileComplete});

  @override
  State<FirstTimeProfileModal> createState() => _FirstTimeProfileModalState();
}

class _FirstTimeProfileModalState extends State<FirstTimeProfileModal> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessCategoryController = TextEditingController();
  final _businessLocationController = TextEditingController();
  
  String _profileType = 'business';
  bool _saving = false;
  List<String> _categories = [];
  String? _selectedCategory;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _loadCategories();
    _slideController.forward();
    _fadeController.forward();
  }

  void _loadCategories() async {
    final categories = await ApiService.getBusinessCategories();
    setState(() => _categories = categories);
  }

  void _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _saving = true);

    final phoneNumber = await AuthService.getPhone();
    final email = await AuthService.getEmail();
    
    if (phoneNumber != null) {
      final profileData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profile_type': _profileType,
        'user_type': _profileType,
        'business_name': _profileType == 'business' ? _nameController.text.trim() : '',
        'business_category': _selectedCategory ?? _businessCategoryController.text.trim(),
        'address': _businessLocationController.text.trim(),
      };

      final success = await ApiService.updateProfile(phoneNumber, profileData);
      
      // If business type, also create business entry
      if (success && _profileType == 'business') {
        final businessData = {
          'name': _nameController.text.trim(),
          'category': _selectedCategory ?? _businessCategoryController.text.trim(),
          'address': _businessLocationController.text.trim(),
          'phone': phoneNumber,
        };
        await ApiService.createBusinessByPhone(phoneNumber, businessData);
      }
      
      if (success) {
        setState(() => _saving = false);
        Navigator.pop(context);
        widget.onProfileComplete();
      } else {
        // If API fails, save profile locally and proceed
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name_$phoneNumber', _nameController.text.trim());
        await prefs.setString('user_type_$phoneNumber', _profileType);
        
        setState(() => _saving = false);
        Navigator.pop(context);
        widget.onProfileComplete();
      }
    } else if (email != null) {
      // For email users, save to database
      final profileData = {
        'name': _nameController.text.trim(),
        'profile_type': _profileType,
        'user_type': _profileType,
        'business_name': _profileType == 'business' ? _nameController.text.trim() : '',
        'business_category': _selectedCategory ?? _businessCategoryController.text.trim(),
        'address': _businessLocationController.text.trim(),
      };
      
      final success = await ApiService.updateProfileByEmail(email, profileData);
      
      // If business type, also create business entry
      if (success && _profileType == 'business') {
        final businessData = {
          'name': _nameController.text.trim(),
          'category': _selectedCategory ?? _businessCategoryController.text.trim(),
          'address': _businessLocationController.text.trim(),
          'email': email,
        };
        await ApiService.createBusinessByEmail(email, businessData);
      }
      
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('profile_completed_$email', true);
        
        setState(() => _saving = false);
        Navigator.pop(context);
        widget.onProfileComplete();
      } else {
        // If API fails, save locally as fallback
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text.trim());
        await prefs.setString('user_profile_type', _profileType);
        await prefs.setBool('profile_completed_$email', true);
        
        setState(() => _saving = false);
        Navigator.pop(context);
        widget.onProfileComplete();
      }
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildAnimatedProfileTypeSelector(),
                        const SizedBox(height: 30),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: _profileType == 'individual' 
                              ? _buildIndividualForm() 
                              : _buildBusinessForm(),
                        ),
                        const SizedBox(height: 100), // Extra space for button
                      ],
                    ),
                  ),
                ),
                _buildAnimatedButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '✨ Complete Your Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProfileTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _profileType = 'individual'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _profileType == 'individual' 
                      ? Colors.white 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _profileType == 'individual'
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: _profileType == 'individual' 
                          ? const Color(0xFFDC143C) 
                          : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Individual',
                      style: TextStyle(
                        color: _profileType == 'individual' 
                            ? const Color(0xFFDC143C) 
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _profileType = 'business'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _profileType == 'business' 
                      ? Colors.white 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _profileType == 'business'
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_outlined,
                      color: _profileType == 'business' 
                          ? const Color(0xFFDC143C) 
                          : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Business',
                      style: TextStyle(
                        color: _profileType == 'business' 
                            ? const Color(0xFFDC143C) 
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualForm() {
    return Column(
      key: const ValueKey('individual'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedProfileImage(),
        const SizedBox(height: 20),
        _buildTextField(_nameController, 'Enter Your Full Name', icon: Icons.person_outline),
        _buildTextField(_usernameController, 'Choose a Username', icon: Icons.alternate_email),
        _buildTextField(_emailController, 'Enter Your Email', icon: Icons.email_outlined),
      ],
    );
  }

  Widget _buildBusinessForm() {
    return Column(
      key: const ValueKey('business'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField(_nameController, 'Business Name', icon: Icons.person_outline),
        _buildAnimatedCategoryField(),
        _buildTextField(_businessLocationController, 'Business Location', icon: Icons.location_on_outlined),
        const SizedBox(height: 10),
        _buildAnimatedLogoUpload(),
      ],
    );
  }

  Widget _buildAnimatedProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFDC143C), Color(0xFFFF6B6B)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDC143C).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Color(0xFFDC143C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _saving
                ? [Colors.grey[400]!, Colors.grey[500]!]
                : [const Color(0xFFDC143C), const Color(0xFFFF6B6B)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC143C).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _saving ? null : _saveProfile,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rocket_launch,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

  Widget _buildTextField(TextEditingController controller, String hint, {bool enabled = true, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null 
              ? Icon(icon, color: const Color(0xFFDC143C), size: 20)
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDC143C), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAnimatedCategoryField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          hintText: 'Select Business Category',
          prefixIcon: const Icon(Icons.business_center_outlined, color: Color(0xFFDC143C), size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDC143C), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: _categories.map((category) => DropdownMenuItem(
          value: category,
          child: Text(category),
        )).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
      ),
    );
  }

  Widget _buildAnimatedLogoUpload() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
        ),
        border: Border.all(
          color: const Color(0xFFDC143C).withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDC143C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              size: 24,
              color: Color(0xFFDC143C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload Business Logo',
            style: TextStyle(
              color: Color(0xFFDC143C),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            'Tap to select image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _businessCategoryController.dispose();
    _businessLocationController.dispose();
    super.dispose();
  }
}