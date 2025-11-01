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
  List<File> _selectedImages = [];
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _loadMenus();
    _checkFirstTimeUser();
  }

  void _checkFirstTimeUser() async {
    final phoneNumber = await AuthService.getPhone();
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

  void _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something')),
      );
      return;
    }

    setState(() => _creating = true);

    final phoneNumber = await AuthService.getPhone();
    if (phoneNumber == null) {
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
          title: Row(
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
              Text(
                'Your post has been sent to admin for approval.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
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
              child: Text(
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

class _FirstTimeProfileModalState extends State<FirstTimeProfileModal> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessCategoryController = TextEditingController();
  final _businessLocationController = TextEditingController();
  
  String _profileType = 'business';
  bool _saving = false;
  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
    if (phoneNumber != null) {
      final profileData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profileType': _profileType,
        'businessName': _profileType == 'business' ? _nameController.text.trim() : '',
        'businessCategory': _selectedCategory ?? _businessCategoryController.text.trim(),
        'address': _businessLocationController.text.trim(),
      };

      final success = await ApiService.updateProfile(phoneNumber, profileData);
      
      setState(() => _saving = false);
      
      if (success) {
        Navigator.pop(context);
        widget.onProfileComplete();
      } else {
        // If API fails, save profile locally and proceed
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name_$phoneNumber', _nameController.text.trim());
        await prefs.setString('user_type_$phoneNumber', _profileType);
        await prefs.setString('user_email_$phoneNumber', _emailController.text.trim());
        await prefs.setString('user_category_$phoneNumber', _selectedCategory ?? _businessCategoryController.text.trim());
        await prefs.setString('user_address_$phoneNumber', _businessLocationController.text.trim());
        
        Navigator.pop(context);
        widget.onProfileComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Complete Your Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileTypeSelector(),
                  const SizedBox(height: 20),
                  if (_profileType == 'individual') _buildIndividualForm(),
                  if (_profileType == 'business') _buildBusinessForm(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC143C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Done',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _profileType = 'individual'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _profileType == 'individual' ? const Color(0xFFDC143C) : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'Individual',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _profileType == 'individual' ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _profileType = 'business'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _profileType == 'business' ? const Color(0xFFDC143C) : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'Business',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _profileType == 'business' ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualForm() {
    return Column(
      children: [
        _buildProfileImage(),
        const SizedBox(height: 20),
        _buildTextField(_nameController, 'Enter Your Name'),
        const SizedBox(height: 15),
        _buildTextField(_usernameController, 'Enter Username'),
        const SizedBox(height: 15),
        _buildTextField(_emailController, 'Enter Your Email'),
        const SizedBox(height: 15),
        _buildTextField(TextEditingController(), 'Enter Your Number', enabled: false),
      ],
    );
  }

  Widget _buildBusinessForm() {
    return Column(
      children: [
        _buildTextField(_nameController, 'Enter Your Name'),
        const SizedBox(height: 15),
        _buildCategoryField(),
        const SizedBox(height: 15),
        _buildTextField(_businessLocationController, 'Business Location'),
        const SizedBox(height: 20),
        _buildLogoUpload(),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 50, color: Colors.grey),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        border: const UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDC143C)),
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        hintText: 'Business Category',
        border: UnderlineInputBorder(),
      ),
      items: _categories.map((category) => DropdownMenuItem(
        value: category,
        child: Text(category),
      )).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
    );
  }

  Widget _buildLogoUpload() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDC143C), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 40, color: Color(0xFFDC143C)),
          SizedBox(height: 8),
          Text(
            'Upload Your Logo',
            style: TextStyle(color: Color(0xFFDC143C), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _businessCategoryController.dispose();
    _businessLocationController.dispose();
    super.dispose();
  }
}