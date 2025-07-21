import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/property_model.dart';

class PerformanceService {
  static const String _cachePrefix = 'cache_';
  static const String _lastCacheUpdateKey = 'last_cache_update';
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Cache management
  static Future<void> cacheData(String key, dynamic data) async {
    try {
      // Store in memory cache
      _memoryCache[key] = data;
      _cacheTimestamps[key] = DateTime.now();

      // Store in persistent cache for important data
      if (_shouldPersistCache(key)) {
        final prefs = await SharedPreferences.getInstance();
        final cacheData = {
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        await prefs.setString('$_cachePrefix$key', json.encode(cacheData));
      }
    } catch (e) {
      debugPrint('Error caching data for key $key: $e');
    }
  }

  static Future<T?> getCachedData<T>(String key) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(key)) {
        final timestamp = _cacheTimestamps[key];
        if (timestamp != null && 
            DateTime.now().difference(timestamp) < _cacheExpiry) {
          return _memoryCache[key] as T?;
        } else {
          // Remove expired cache
          _memoryCache.remove(key);
          _cacheTimestamps.remove(key);
        }
      }

      // Check persistent cache
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString('$_cachePrefix$key');
      
      if (cacheString != null) {
        final cacheData = json.decode(cacheString);
        final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
        
        if (DateTime.now().difference(timestamp) < _cacheExpiry) {
          // Update memory cache
          _memoryCache[key] = cacheData['data'];
          _cacheTimestamps[key] = timestamp;
          return cacheData['data'] as T?;
        } else {
          // Remove expired cache
          await prefs.remove('$_cachePrefix$key');
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting cached data for key $key: $e');
      return null;
    }
  }

  static bool _shouldPersistCache(String key) {
    // Only persist important data like user preferences, recent searches, etc.
    const persistentKeys = [
      'user_preferences',
      'recent_searches',
      'favorite_areas',
      'property_filters',
    ];
    return persistentKeys.any((persistentKey) => key.contains(persistentKey));
  }

  // Image caching and optimization
  static Future<void> preloadImages(List<String> imageUrls) async {
    for (final url in imageUrls.take(5)) { // Limit to first 5 images
      try {
        await precacheImage(NetworkImage(url), NavigationService.navigatorKey.currentContext!);
      } catch (e) {
        debugPrint('Error preloading image $url: $e');
      }
    }
  }

  // Property list optimization
  static List<Property> optimizePropertyList(List<Property> properties) {
    // Sort by relevance/recency
    properties.sort((a, b) {
      // Prioritize verified properties
      if (a.isVerified && !b.isVerified) return -1;
      if (!a.isVerified && b.isVerified) return 1;
      
      // Then by creation date
      return b.createdAt.compareTo(a.createdAt);
    });

    return properties;
  }

  // Lazy loading helper
  static List<T> getPaginatedItems<T>(List<T> items, int page, int itemsPerPage) {
    final startIndex = page * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, items.length);
    
    if (startIndex >= items.length) return [];
    
    return items.sublist(startIndex, endIndex);
  }

  // Search optimization
  static List<Property> optimizedSearch(
    List<Property> properties, 
    String query, {
    int maxResults = 50,
  }) {
    if (query.isEmpty) return properties.take(maxResults).toList();

    final queryLower = query.toLowerCase();
    final results = <Property>[];
    final scores = <Property, int>{};

    for (final property in properties) {
      int score = 0;
      
      // Title match (highest priority)
      if (property.title.toLowerCase().contains(queryLower)) {
        score += 10;
        if (property.title.toLowerCase().startsWith(queryLower)) {
          score += 5; // Bonus for starting with query
        }
      }
      
      // Location match
      if (property.location.address.toLowerCase().contains(queryLower)) {
        score += 8;
      }
      
      // Property type match
      if (property.propertyType.toLowerCase().contains(queryLower)) {
        score += 6;
      }
      
      // Description match (lower priority)
      if (property.description.toLowerCase().contains(queryLower)) {
        score += 3;
      }
      
      // Amenities match
      for (final amenity in property.amenities) {
        if (amenity.toLowerCase().contains(queryLower)) {
          score += 2;
          break;
        }
      }
      
      if (score > 0) {
        scores[property] = score;
        results.add(property);
      }
    }

    // Sort by score (descending)
    results.sort((a, b) => (scores[b] ?? 0).compareTo(scores[a] ?? 0));
    
    return results.take(maxResults).toList();
  }

  // Memory management
  static void clearMemoryCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
  }

  static Future<void> clearPersistentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing persistent cache: $e');
    }
  }

  // Performance monitoring
  static Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'memoryCacheSize': _memoryCache.length,
        'persistentCacheSize': prefs.getKeys()
            .where((key) => key.startsWith(_cachePrefix))
            .length,
        'lastCacheUpdate': prefs.getString(_lastCacheUpdateKey),
        'cacheHitRate': _calculateCacheHitRate(),
      };
    } catch (e) {
      debugPrint('Error getting performance metrics: $e');
      return {};
    }
  }

  static double _calculateCacheHitRate() {
    // This would be implemented with actual hit/miss tracking
    return 0.85; // Placeholder
  }

  // Batch operations for better performance
  static Future<void> batchCacheUpdate(Map<String, dynamic> dataMap) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      for (final entry in dataMap.entries) {
        _memoryCache[entry.key] = entry.value;
        _cacheTimestamps[entry.key] = DateTime.now();
        
        if (_shouldPersistCache(entry.key)) {
          final cacheData = {
            'data': entry.value,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
          await prefs.setString('$_cachePrefix${entry.key}', json.encode(cacheData));
        }
      }
      
      await prefs.setString(_lastCacheUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error in batch cache update: $e');
    }
  }
}

// Navigation service for context access
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}