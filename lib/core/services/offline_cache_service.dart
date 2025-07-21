import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/property_model.dart';

class OfflineCacheService {
  static const String _propertiesCacheFile = 'cached_properties.json';
  static const String _favoritesCacheFile = 'cached_favorites.json';
  static const String _searchCacheFile = 'cached_searches.json';
  static const String _userDataCacheFile = 'cached_user_data.json';
  
  static const int _maxCacheAge = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
  static const int _maxCachedProperties = 100; // Limit cache size
  
  // Check network connectivity
  static Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  // Get cache directory
  static Future<Directory> _getCacheDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/offline_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  // Cache properties
  static Future<void> cacheProperties(List<Property> properties) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$_propertiesCacheFile');
      
      // Limit cache size
      final propertiesToCache = properties.take(_maxCachedProperties).toList();
      
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'properties': propertiesToCache.map((p) => p.toJson()).toList(),
      };
      
      await file.writeAsString(json.encode(cacheData));
      debugPrint('Cached ${propertiesToCache.length} properties');
    } catch (e) {
      debugPrint('Error caching properties: $e');
    }
  }

  // Get cached properties
  static Future<List<Property>> getCachedProperties() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$_propertiesCacheFile');
      
      if (!await file.exists()) {
        return [];
      }
      
      final content = await file.readAsString();
      final cacheData = json.decode(content);
      
      // Check cache age
      final timestamp = cacheData['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      
      if (age > _maxCacheAge) {
        debugPrint('Cache expired, clearing...');
        await clearCache();
        return [];
      }
      
      final propertiesJson = cacheData['properties'] as List;
      final properties = propertiesJson
          .map((json) => Property.fromJson(json))
          .toList();
      
      debugPrint('Retrieved ${properties.length} cached properties');
      return properties;
    } catch (e) {
      debugPrint('Error retrieving cached properties: $e');
      return [];
    }
  }

  // Cache individual property details
  static Future<void> cachePropertyDetails(Property property) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/property_${property.id}.json');
      
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'property': property.toJson(),
      };
      
      await file.writeAsString(json.encode(cacheData));
      debugPrint('Cached property details for ${property.id}');
    } catch (e) {
      debugPrint('Error caching property details: $e');
    }
  }

  // Get cached property details
  static Future<Property?> getCachedPropertyDetails(String propertyId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/property_$propertyId.json');
      
      if (!await file.exists()) {
        return null;
      }
      
      final content = await file.readAsString();
      final cacheData = json.decode(content);
      
      // Check cache age
      final timestamp = cacheData['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      
      if (age > _maxCacheAge) {
        await file.delete();
        return null;
      }
      
      return Property.fromJson(cacheData['property']);
    } catch (e) {
      debugPrint('Error retrieving cached property details: $e');
      return null;
    }
  }

  // Cache favorites
  static Future<void> cacheFavorites(List<String> favoriteIds) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$_favoritesCacheFile');
      
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'favorites': favoriteIds,
      };
      
      await file.writeAsString(json.encode(cacheData));
      debugPrint('Cached ${favoriteIds.length} favorites');
    } catch (e) {
      debugPrint('Error caching favorites: $e');
    }
  }

  // Get cached favorites
  static Future<List<String>> getCachedFavorites() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$_favoritesCacheFile');
      
      if (!await file.exists()) {
        return [];
      }
      
      final content = await file.readAsString();
      final cacheData = json.decode(content);
      
      final favorites = List<String>.from(cacheData['favorites'] ?? []);
      debugPrint('Retrieved ${favorites.length} cached favorites');
      return favorites;
    } catch (e) {
      debugPrint('Error retrieving cached favorites: $e');
      return [];
    }
  }

  // Cache search results
  static Future<void> cacheSearchResults(String query, List<Property> results) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$_searchCacheFile');
      
      Map<String, dynamic> searchCache = {};
      
      // Load existing cache
      if (await file.exists()) {
        final content = await file.readAsString();
        searchCache = json.decode(content);
      }
      
      // Add new search result
      searchCache[query.toLowerCase()] = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'results': results.map((p) => p.toJson()).toList(),
      };
      
      // Limit cache size (keep only last 10 searches)
      if (searchCache.length > 10) {
        final sortedKeys = searchCache.keys.toList()
          ..sort((a, b) => searchCache[b]['timestamp'].compareTo(searchCache[a]['timestamp']));
        
        final newCache = <String, dynamic>{};
        for (int i = 0; i < 10; i++) {
          newCache[sortedKeys[i]] = searchCache[sortedKeys[i]];
        }
        searchCache = newCache;
      }
      
      await file.writeAsString(json.encode(searchCache));
      debugPrint('Cached search results for: $query');
    } catch (e) {
      debugPrint('Error caching search results: $e');
    }
  }

  // Get cached search results
  static Future<List<Property>?> getCachedSearchResults(String query) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$_searchCacheFile');
      
      if (!await file.exists()) {
        return null;
      }
      
      final content = await file.readAsString();
      final searchCache = json.decode(content);
      final queryKey = query.toLowerCase();
      
      if (!searchCache.containsKey(queryKey)) {
        return null;
      }
      
      final cacheData = searchCache[queryKey];
      final timestamp = cacheData['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      
      if (age > _maxCacheAge) {
        return null;
      }
      
      final resultsJson = cacheData['results'] as List;
      final results = resultsJson.map((json) => Property.fromJson(json)).toList();
      
      debugPrint('Retrieved ${results.length} cached search results for: $query');
      return results;
    } catch (e) {
      debugPrint('Error retrieving cached search results: $e');
      return null;
    }
  }

  // Cache user data
  static Future<void> cacheUserData(Map<String, dynamic> userData) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$_userDataCacheFile');
      
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userData': userData,
      };
      
      await file.writeAsString(json.encode(cacheData));
      debugPrint('Cached user data');
    } catch (e) {
      debugPrint('Error caching user data: $e');
    }
  }

  // Get cached user data
  static Future<Map<String, dynamic>?> getCachedUserData() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$_userDataCacheFile');
      
      if (!await file.exists()) {
        return null;
      }
      
      final content = await file.readAsString();
      final cacheData = json.decode(content);
      
      return Map<String, dynamic>.from(cacheData['userData'] ?? {});
    } catch (e) {
      debugPrint('Error retrieving cached user data: $e');
      return null;
    }
  }

  // Get cache size
  static Future<double> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      double totalSize = 0;
      
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize / (1024 * 1024); // Return size in MB
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0;
    }
  }

  // Clear all cache
  static Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
      
      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  // Clear expired cache
  static Future<void> clearExpiredCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await for (final entity in cacheDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final content = await entity.readAsString();
            final data = json.decode(content);
            final timestamp = data['timestamp'] as int?;
            
            if (timestamp != null && (now - timestamp) > _maxCacheAge) {
              await entity.delete();
              debugPrint('Deleted expired cache file: ${entity.path}');
            }
          } catch (e) {
            // If we can't read the file, delete it
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing expired cache: $e');
    }
  }

  // Preload properties for offline use
  static Future<void> preloadPropertiesForOffline(List<Property> properties) async {
    try {
      // Cache the properties list
      await cacheProperties(properties);
      
      // Cache individual property details for the first 20 properties
      final propertiesToCache = properties.take(20).toList();
      
      for (final property in propertiesToCache) {
        await cachePropertyDetails(property);
        
        // Small delay to prevent overwhelming the system
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      debugPrint('Preloaded ${propertiesToCache.length} properties for offline use');
    } catch (e) {
      debugPrint('Error preloading properties: $e');
    }
  }

  // Check if property is cached
  static Future<bool> isPropertyCached(String propertyId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/property_$propertyId.json');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Get offline status info
  static Future<Map<String, dynamic>> getOfflineStatus() async {
    try {
      final isConnected = await isOnline();
      final cacheSize = await getCacheSize();
      final cachedProperties = await getCachedProperties();
      final cachedFavorites = await getCachedFavorites();
      
      return {
        'isOnline': isConnected,
        'cacheSize': cacheSize,
        'cachedPropertiesCount': cachedProperties.length,
        'cachedFavoritesCount': cachedFavorites.length,
        'lastCacheUpdate': cachedProperties.isNotEmpty 
            ? DateTime.now().subtract(const Duration(hours: 1)) 
            : null,
      };
    } catch (e) {
      debugPrint('Error getting offline status: $e');
      return {
        'isOnline': false,
        'cacheSize': 0.0,
        'cachedPropertiesCount': 0,
        'cachedFavoritesCount': 0,
        'lastCacheUpdate': null,
      };
    }
  }
}