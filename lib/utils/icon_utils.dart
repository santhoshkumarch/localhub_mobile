import 'package:flutter/material.dart';

class IconUtils {
  static Color getColorFromString(String iconName, String menuName) {
    // First try to map by icon name
    switch (iconName.toLowerCase()) {
      case 'quiz':
      case 'test':
        return Colors.blue;
      case 'event':
      case 'events':
        return Colors.green;
      case 'room_service':
      case 'services':
      case 'service':
        return Colors.orange;
      case 'local_offer':
      case 'offers':
      case 'offer':
        return Colors.red;
      case 'work':
      case 'jobs':
      case 'job':
        return Colors.indigo;
      case 'shopping_cart':
      case 'shop':
        return Colors.purple;
      case 'restaurant':
      case 'food':
        return Colors.deepOrange;
      case 'home':
        return Colors.teal;
      case 'favorite':
      case 'heart':
        return Colors.pink;
      case 'star':
        return Colors.amber;
      case 'location_on':
      case 'location':
        return Colors.red;
      case 'phone':
        return Colors.green;
      case 'email':
        return Colors.blue;
      case 'camera':
        return Colors.grey;
      case 'photo':
        return Colors.cyan;
      case 'video':
        return Colors.deepPurple;
      case 'music':
        return Colors.lime;
      case 'settings':
        return Colors.blueGrey;
      case 'account':
      case 'profile':
        return Colors.brown;
    }

    // If icon name doesn't match, try menu name
    switch (menuName.toLowerCase()) {
      case 'test':
        return Colors.blue;
      case 'events':
        return Colors.green;
      case 'services':
        return Colors.orange;
      case 'offers':
        return Colors.red;
      case 'jobs':
        return Colors.indigo;
      case 'business':
        return Colors.teal;
      case 'news':
        return Colors.blue;
      case 'chat':
        return Colors.green;
      case 'people':
        return Colors.purple;
      case 'shopping':
      case 'shop':
        return Colors.purple;
      case 'food':
      case 'restaurant':
        return Colors.deepOrange;
      case 'home':
        return Colors.teal;
      case 'favorites':
        return Colors.pink;
      case 'reviews':
        return Colors.amber;
      case 'location':
        return Colors.red;
      case 'contact':
        return Colors.green;
      case 'gallery':
        return Colors.cyan;
      case 'camera':
        return Colors.grey;
      case 'videos':
        return Colors.deepPurple;
      case 'music':
        return Colors.lime;
      case 'settings':
        return Colors.blueGrey;
      case 'profile':
      case 'account':
        return Colors.brown;
      default:
        return const Color(0xFF1565C0);
    }
  }

  static String getEmojiFromString(String iconName, String menuName) {
    // First try to map by icon name
    switch (iconName.toLowerCase()) {
      case 'quiz':
      case 'test':
        return '📝';
      case 'event':
      case 'events':
        return '🎉';
      case 'room_service':
      case 'services':
      case 'service':
        return '🔧';
      case 'local_offer':
      case 'offers':
      case 'offer':
        return '🏷️';
      case 'work':
      case 'jobs':
      case 'job':
        return '💼';
      case 'shopping_cart':
      case 'shop':
        return '🛒';
      case 'restaurant':
      case 'food':
        return '🍽️';
      case 'home':
        return '🏠';
      case 'favorite':
      case 'heart':
        return '❤️';
      case 'star':
        return '⭐';
      case 'location_on':
      case 'location':
        return '📍';
      case 'phone':
        return '📞';
      case 'email':
        return '📧';
      case 'camera':
        return '📷';
      case 'photo':
        return '🖼️';
      case 'video':
        return '🎥';
      case 'music':
        return '🎵';
      case 'settings':
        return '⚙️';
      case 'account':
      case 'profile':
        return '👤';
    }

    // If icon name doesn't match, try menu name
    switch (menuName.toLowerCase()) {
      case 'test':
        return '📝';
      case 'events':
        return '🎉';
      case 'services':
        return '🔧';
      case 'offers':
        return '🏷️';
      case 'jobs':
        return '💼';
      case 'business':
        return '🏢';
      case 'news':
        return '📰';
      case 'chat':
        return '💬';
      case 'people':
        return '👥';
      case 'shopping':
      case 'shop':
        return '🛍️';
      case 'food':
      case 'restaurant':
        return '🍽️';
      case 'home':
        return '🏠';
      case 'favorites':
        return '❤️';
      case 'reviews':
        return '⭐';
      case 'location':
        return '📍';
      case 'contact':
        return '📞';
      case 'gallery':
        return '🖼️';
      case 'camera':
        return '📷';
      case 'videos':
        return '🎥';
      case 'music':
        return '🎵';
      case 'settings':
        return '⚙️';
      case 'profile':
      case 'account':
        return '👤';
      case 'education':
        return '🎓';
      case 'travel':
        return '✈️';
      case 'sports':
        return '⚽';
      case 'health':
        return '💊';
      case 'finance':
        return '💰';
      case 'entertainment':
        return '🎬';
      case 'technology':
        return '💻';
      case 'social':
        return '🌐';
      case 'fitness':
        return '🏋️';
      case 'productivity':
        return '📈';
      case 'pets':
        return '🐾';
      case 'nature':
        return '🌿';
      case 'weather':
        return '☀️';

      default:
        return '📱';
    }
  }
}
