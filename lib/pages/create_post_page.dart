import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    _loadUserType();
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
      final userType = await ApiService.getUserType(phoneNumber);
      final profile = await ApiService.getProfile(phoneNumber);
      setState(() {
        _userType = userType ?? 'individual';
        _userName = profile?['name'] ?? 'User';
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
    };

    final success = await ApiService.createPost(postData);
    setState(() => _creating = false);

    if (success) {
      Navigator.pop(context, true);
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
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showCategoryDialog(),
                child: _buildOptionChip(
                  Icons.category, 
                  _selectedMenu?.name ?? 'Category', 
                  Colors.blue
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedMenu != null && _selectedMenu!.labels.isNotEmpty)
                GestureDetector(
                  onTap: () => _showLabelDialog(),
                  child: _buildOptionChip(
                    Icons.label, 
                    _selectedLabel ?? 'Label', 
                    Colors.blue
                  ),
                ),
            ],
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