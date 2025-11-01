import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/side_menu.dart';
import 'notifications_page.dart';
import 'create_post_page.dart';

// Fixed: All ApiService methods are properly defined

class FeedsPage extends StatefulWidget {
  final String? filterCategory;
  const FeedsPage({super.key, this.filterCategory});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _filteredPosts = [];
  bool _loading = true;
  Set<int> _likedPosts = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void refreshPosts() {
    _loadPosts();
  }

  void _filterPosts() {
    if (widget.filterCategory == null) {
      _filteredPosts = _posts;
    } else {
      _filteredPosts = _posts.where((post) {
        final menuName = post['menuName']?.toString().toLowerCase() ?? '';
        final assignedLabel = post['assignedLabel']?.toString().toLowerCase() ?? '';
        final filterLower = widget.filterCategory!.toLowerCase();
        return menuName.contains(filterLower) || assignedLabel.contains(filterLower);
      }).toList();
    }
  }

  void _loadPosts() async {
    if (!mounted) return;
    setState(() => _loading = true);
    
    final phoneNumber = await AuthService.getPhone();
    final posts = await ApiService.getAllPosts();
    
    // Load liked posts from local storage
    if (phoneNumber != null) {
      final prefs = await SharedPreferences.getInstance();
      final likedPostsJson = prefs.getStringList('liked_posts_$phoneNumber') ?? [];
      _likedPosts = Set<int>.from(likedPostsJson.map((id) => int.parse(id)));
    }
    
    if (mounted) {
      setState(() {
        _posts = posts.map((post) {
          return {
            ...post,
            'likes': post['likes'] ?? 0,
            'comments': post['comments'] ?? 0,
            'views': post['views'] ?? 0,
          };
        }).toList();
        _filterPosts();
        _loading = false;
      });
    }
  }

  void _toggleLike(int postId, int index) async {
    final phoneNumber = await AuthService.getPhone();
    if (phoneNumber == null) return;
    
    final success = await ApiService.toggleLike(postId, phoneNumber);
    if (success) {
      setState(() {
        if (_likedPosts.contains(postId)) {
          _likedPosts.remove(postId);
          _filteredPosts[index]['likes'] = (_filteredPosts[index]['likes'] ?? 0) - 1;
        } else {
          _likedPosts.add(postId);
          _filteredPosts[index]['likes'] = (_filteredPosts[index]['likes'] ?? 0) + 1;
        }
      });
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      final likedPostsList = _likedPosts.map((id) => id.toString()).toList();
      await prefs.setStringList('liked_posts_$phoneNumber', likedPostsList);
    }
  }

  void _showCommentsDrawer(int postId, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsDrawer(
        postId: postId,
        onCommentAdded: () {
          setState(() {
            _filteredPosts[index]['comments'] = (_filteredPosts[index]['comments'] ?? 0) + 1;
          });
        },
      ),
    );
  }

  final List<Map<String, dynamic>> mockFeeds = const [
    {
      'id': 1,
      'userName': 'Ravi Kumar',
      'userType': 'Restaurant Owner',
      'content': 'Grand opening of our new branch in T. Nagar! Special 20% discount for the first 100 customers 🎉',
      'timestamp': '2 hours ago',
      'likes': 45,
      'comments': 12,
      'hashtags': ['#GrandOpening', '#TNagar', '#Discount'],
    },
    {
      'id': 2,
      'userName': 'Priya Textiles',
      'userType': 'Business',
      'content': 'New collection of silk sarees arrived! Perfect for the upcoming festival season. Visit our showroom in Coimbatore.',
      'timestamp': '4 hours ago',
      'likes': 28,
      'comments': 8,
      'hashtags': ['#SilkSarees', '#Festival', '#Coimbatore'],
    },
    {
      'id': 3,
      'userName': 'Tech Solutions',
      'userType': 'IT Services',
      'content': 'Looking for talented developers to join our team. Great opportunity for freshers and experienced professionals.',
      'timestamp': '6 hours ago',
      'likes': 67,
      'comments': 23,
      'hashtags': ['#Hiring', '#Developers', '#JobOpportunity'],
    },
    {
      'id': 4,
      'userName': 'Green Grocers',
      'userType': 'Grocery',
      'content': 'Fresh organic vegetables delivered to your doorstep. Free delivery for orders above ₹500 in Madurai area.',
      'timestamp': '8 hours ago',
      'likes': 34,
      'comments': 15,
      'hashtags': ['#Organic', '#FreeDelivery', '#Madurai'],
    },
    {
      'id': 5,
      'userName': 'Auto Care Center',
      'userType': 'Automotive',
      'content': 'Monsoon car service package now available! Complete check-up and maintenance at discounted rates.',
      'timestamp': '1 day ago',
      'likes': 19,
      'comments': 6,
      'hashtags': ['#CarService', '#Monsoon', '#Maintenance'],
    },
  ];

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.post_add, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            widget.filterCategory != null 
              ? 'No ${widget.filterCategory!.toLowerCase()} posts found'
              : 'No posts yet', 
            style: const TextStyle(fontSize: 18, color: Colors.grey)
          ),
          Text(
            widget.filterCategory != null
              ? 'Try a different category or create a new post'
              : 'Be the first to create a post!', 
            style: const TextStyle(color: Colors.grey)
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: Text(widget.filterCategory != null ? '${widget.filterCategory} Posts' : 'Feeds'),
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
                      '3',
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
          : RefreshIndicator(
              onRefresh: () async => _loadPosts(),
              child: _filteredPosts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = _filteredPosts[index];
                        final postId = post['id'] ?? index;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFFDC143C),
                                      child: Text(
                                        (post['authorName'] ?? 'U')[0].toUpperCase(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post['authorName'] ?? 'Unknown User',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            post['authorType'] ?? 'User',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(post['createdAt'] ?? ''),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  post['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post['content'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                if (post['mediaUrls'] != null && (post['mediaUrls'] as List).isNotEmpty)
                                  const SizedBox(height: 12),
                                if (post['mediaUrls'] != null && (post['mediaUrls'] as List).isNotEmpty)
                                  SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: (post['mediaUrls'] as List).length,
                                      itemBuilder: (context, mediaIndex) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              (post['mediaUrls'] as List)[mediaIndex],
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 200,
                                                  height: 200,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.image, size: 50),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDC143C).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        post['menuName'] ?? 'General',
                                        style: const TextStyle(
                                          color: Color(0xFFDC143C),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (post['assignedLabel'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          post['assignedLabel'],
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    if (post['adminRemarks'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          post['adminRemarks'],
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Stats row
                                Row(
                                  children: [
                                    Icon(Icons.visibility, size: 16, color: Colors.grey),
                                    Text(' ${post['views'] ?? 12} views', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    const SizedBox(width: 16),
                                    Icon(Icons.favorite, size: 16, color: Colors.red),
                                    Text(' ${post['likes'] ?? 0}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    const SizedBox(width: 16),
                                    Icon(Icons.comment, size: 16, color: Colors.blue),
                                    Text(' ${post['comments'] ?? 0}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Divider(color: Colors.grey[300]),
                                const SizedBox(height: 8),
                                // Action buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _toggleLike(postId, index),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _likedPosts.contains(postId) ? Icons.favorite : Icons.favorite_border,
                                                size: 20,
                                                color: _likedPosts.contains(postId) ? Colors.red : Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Like',
                                                style: TextStyle(
                                                  color: _likedPosts.contains(postId) ? Colors.red : Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(width: 1, height: 30, color: Colors.grey[300]),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _showCommentsDrawer(postId, index),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Comment',
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(width: 1, height: 30, color: Colors.grey[300]),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Post shared!')),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.share_outlined, size: 20, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Share',
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostPage()),
          );
          if (result == true) {
            _loadPosts();
          }
        },
        backgroundColor: const Color(0xFFDC143C),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CommentsDrawer extends StatefulWidget {
  final int postId;
  final VoidCallback onCommentAdded;

  const CommentsDrawer({
    super.key,
    required this.postId,
    required this.onCommentAdded,
  });

  @override
  State<CommentsDrawer> createState() => _CommentsDrawerState();
}

class _CommentsDrawerState extends State<CommentsDrawer> {
  final _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final comments = await ApiService.getComments(widget.postId);
    if (mounted) {
      setState(() {
        _comments = comments;
        _loading = false;
      });
    }
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    final phoneNumber = await AuthService.getPhone();
    if (phoneNumber == null) return;
    
    final success = await ApiService.addComment(
      widget.postId,
      phoneNumber,
      _commentController.text.trim(),
    );
    
    if (success) {
      _commentController.clear();
      widget.onCommentAdded();
      _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(
                        child: Text(
                          'No comments yet\nBe the first to comment!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFDC143C),
                                  child: Text(
                                    (comment['authorName'] ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment['authorName'] ?? 'Unknown User',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        comment['comment'] ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment['createdAt'] ?? '',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send, color: Color(0xFFDC143C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}