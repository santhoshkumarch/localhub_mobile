import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/side_menu.dart';
import 'notifications_page.dart';
import 'create_post_page.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void refreshPosts() {
    _loadPosts();
  }

  void _loadPosts() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final phoneNumber = await AuthService.getPhone();
    final user = await AuthService.getUser();
    print('AuthService user: $user');
    print('Loading posts for phone: $phoneNumber');
    if (phoneNumber != null) {
      final posts = await ApiService.getUserPosts(phoneNumber);
      print('Loaded ${posts.length} posts: $posts');
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
          _loading = false;
        });
      }
    } else {
      print('No phone number found in AuthService');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  final List<Map<String, dynamic>> mockPosts = const [
    {
      'id': 1,
      'content': 'Just opened my new restaurant in Chennai! Come try our authentic Tamil cuisine 🍛',
      'timestamp': '2 hours ago',
      'likes': 24,
      'comments': 8,
      'hashtags': ['#TamilFood', '#Chennai', '#NewOpening'],
    },
    {
      'id': 2,
      'content': 'Looking for reliable suppliers for my textile business. Any recommendations?',
      'timestamp': '1 day ago',
      'likes': 12,
      'comments': 15,
      'hashtags': ['#Textile', '#Business', '#Suppliers'],
    },
    {
      'id': 3,
      'content': 'Great networking event in Coimbatore today! Met amazing entrepreneurs 💼',
      'timestamp': '3 days ago',
      'likes': 45,
      'comments': 12,
      'hashtags': ['#Networking', '#Coimbatore', '#Entrepreneurs'],
    },
    {
      'id': 4,
      'content': 'Special discount on all electronics this weekend! Visit our store in Madurai',
      'timestamp': '1 week ago',
      'likes': 67,
      'comments': 23,
      'hashtags': ['#Electronics', '#Discount', '#Madurai'],
    },
  ];

  void _showCommentsDrawer(int postId, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsDrawer(
        postId: postId,
        onCommentAdded: () {
          setState(() {
            _posts[index]['comments'] = (_posts[index]['comments'] ?? 0) + 1;
          });
        },
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
        title: const Text('My Posts'),
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
                      '2',
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
              child: _posts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.post_add, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No posts yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          Text('Create your first post!', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                Row(
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
                                    if (post['assignedLabel'] != null) ...[
                                      const SizedBox(width: 8),
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
                                    ]
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Stats row
                                Row(
                                  children: [
                                    Icon(Icons.visibility, size: 16, color: Colors.grey),
                                    Text(' ${post['views'] ?? 0} views', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    const SizedBox(width: 16),
                                    Icon(Icons.favorite, size: 16, color: Colors.red),
                                    Text(' ${post['likes'] ?? 0}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () => _showCommentsDrawer(post['id'] ?? index, index),
                                      child: Row(
                                        children: [
                                          Icon(Icons.comment, size: 16, color: Colors.blue),
                                          Text(' ${post['comments'] ?? 0}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatTimestamp(post['createdAt'] ?? ''),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: post['status'] == 'approved' 
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            post['status'] ?? 'pending',
                                            style: TextStyle(
                                              color: post['status'] == 'approved' 
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        PopupMenuButton(
                                          icon: const Icon(Icons.more_vert, size: 16),
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('$value post')),
                                            );
                                          },
                                        ),
                                      ],
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