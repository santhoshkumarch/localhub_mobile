import 'dart:convert';
import 'package:http/http.dart' as http;

// API Service for authentication and data operations
class ApiService {
  static const String localUrl =
      'https://localhubbackend-production.up.railway.app/api'; // Local development
  static const String androidUrl =
      'https://localhubbackend-production.up.railway.app/api'; // Android emulator
  static const String productionUrl =
      'https://localhubbackend-production.up.railway.app/api';

  static Future<Map<String, dynamic>> checkUser(String phoneNumber) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/check-user'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phone': phoneNumber}),
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

  static Future<bool> registerUser(String phoneNumber, String name) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phone': phoneNumber, 'name': name}),
        );
        if (response.statusCode == 200) return true;
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static Future<bool> sendOtp(String phoneNumber) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/otp/send'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phoneNumber': phoneNumber}),
        );
        if (response.statusCode == 200) return true;
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String phoneNumber, String code) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/otp/verify'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phoneNumber': phoneNumber, 'code': code}),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return {
            'success': true,
            'verified': data['verified'],
            'message': data['message']
          };
        }
      } catch (e) {
        continue;
      }
    }
    return {'success': false};
  }

  static Future<bool> logoutUser(String phoneNumber) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phone': phoneNumber}),
        );
        if (response.statusCode == 200) return true;
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static Future<List<MenuItem>> getMenus() async {
    // Try localhost first, then production
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        print('Making API call to: $baseUrl/menus');
        final response = await http.get(Uri.parse('$baseUrl/menus'));
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.map((item) => MenuItem.fromJson(item)).toList();
        }
      } catch (e) {
        print('Failed to connect to $baseUrl: $e');
        continue;
      }
    }

    print('All API endpoints failed');
    return [];
  }

  static Future<Map<String, dynamic>?> getProfile(String phoneNumber) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/profile/$phoneNumber'));
        if (response.statusCode == 200) {
          return json.decode(response.body);
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  static Future<bool> updateProfile(String phoneNumber, Map<String, dynamic> profileData) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        print('Updating profile for: $phoneNumber');
        print('Profile data: $profileData');
        print('API URL: $baseUrl/profile/$phoneNumber');
        
        final response = await http.put(
          Uri.parse('$baseUrl/profile/$phoneNumber'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(profileData),
        );
        
        print('Update profile response status: ${response.statusCode}');
        print('Update profile response body: ${response.body}');
        
        if (response.statusCode == 200) return true;
      } catch (e) {
        print('Profile update error: $e');
        continue;
      }
    }
    return false;
  }

  static Future<List<String>> getBusinessCategories() async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/categories'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.map((item) => item['name'] as String).toList();
        }
      } catch (e) {
        continue;
      }
    }
    return [];
  }

  static Future<bool> addBusinessCategory(String categoryName) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/categories'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'name': categoryName}),
        );
        if (response.statusCode == 201) return true;
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static Future<bool> createPost(Map<String, dynamic> postData) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        print('Creating post: $postData');
        final response = await http.post(
          Uri.parse('$baseUrl/posts'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(postData),
        );
        print('Create post response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 201) return true;
      } catch (e) {
        print('Create post error: $e');
        continue;
      }
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> getUserPosts(String phoneNumber) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        print('Getting user posts for: $phoneNumber from $baseUrl');
        final response = await http.get(Uri.parse('$baseUrl/posts/user/$phoneNumber'));
        print('User posts response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        print('User posts error: $e');
        continue;
      }
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getAllPosts() async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/posts'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        continue;
      }
    }
    return [];
  }

  static Future<String?> getUserType(String phoneNumber) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/profile/$phoneNumber'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['profile_type'] ?? 'individual';
        }
      } catch (e) {
        continue;
      }
    }
    return 'individual';
  }

  static Future<bool> toggleLike(int postId, String phoneNumber) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/posts/$postId/like'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phoneNumber': phoneNumber}),
        );
        if (response.statusCode == 200) return true;
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static Future<bool> addComment(int postId, String phoneNumber, String comment) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/posts/$postId/comment'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'phoneNumber': phoneNumber,
            'comment': comment,
          }),
        );
        if (response.statusCode == 201) return true;
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> getComments(int postId) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/posts/$postId/comments'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        continue;
      }
    }
    return [];
  }

  static Future<bool> runEngagementMigration() async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.post(Uri.parse('$baseUrl/migration/engagement'));
        if (response.statusCode == 200) {
          print('Migration successful: ${response.body}');
          return true;
        }
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  static Future<List<int>> getUserLikedPosts(String phoneNumber) async {
    for (String baseUrl in [localUrl, androidUrl, productionUrl]) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/posts/liked/$phoneNumber'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.cast<int>();
        }
      } catch (e) {
        continue;
      }
    }
    return [];
  }
}

class MenuItem {
  final int id;
  final String name;
  final String description;
  final String icon;
  final List<String> labels;
  final int postCount;
  final bool isActive;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.labels,
    required this.postCount,
    required this.isActive,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'article',
      labels: List<String>.from(json['labels'] ?? []),
      postCount: json['postCount'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }
}
