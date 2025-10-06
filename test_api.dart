import 'lib/services/api_service.dart';

void main() async {
  print('Testing API endpoints...');
  
  // Test get all posts
  try {
    final posts = await ApiService.getAllPosts();
    print('✅ getAllPosts: ${posts.length} posts found');
    if (posts.isNotEmpty) {
      print('   First post: ${posts[0]['title']}');
    }
  } catch (e) {
    print('❌ getAllPosts failed: $e');
  }
  
  // Test get menus
  try {
    final menus = await ApiService.getMenus();
    print('✅ getMenus: ${menus.length} menus found');
    if (menus.isNotEmpty) {
      print('   First menu: ${menus[0].name}');
    }
  } catch (e) {
    print('❌ getMenus failed: $e');
  }
  
  print('API test completed!');
}