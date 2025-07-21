import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import 'performance_service.dart';

class OfflineService {
  static const String _offlinePropertiesKey = 'offline_properties';
  static const String _offlineImagesKey = 'offline_images';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const Duration _syncInterval = Duration(hours: 6);
  static const int _maxOfflineProperties = 50;
  static const int _maxOfflineImages = 100;
  
  static final Map<String, Property> _cachedProperties = {};
  static final Map<String, String> _cachedImagePaths = {};
  static bool _isInitialized = false;
  
  // Initialize offline service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadCachedProperties();
      await _loadCachedImages();
      _isInitialized = true;
      debugPrint('OfflineService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing OfflineService: $e');
    }
  }
  
  // Cache property for offline viewing
  static Future<void> cacheProperty(Property property) async {
    try {
      _cachedProperties[property.id] = property;
      
      // Cache property images
      for (final imageUrl in property.images) {
        await _cacheImage(imageUrl);
      }
      
      await _saveCachedProperties();
      debugPrint('Property ${property.id} cached for offline viewing');
    } catch (e) {
      debugPrint('Error caching property ${property.id}: $e');
    }
  }
  
  // Cache multiple properties (for recently viewed, favorites, etc.)
  static Future<void> cacheProperties(List<Property> properties) async {
    try {
      for (final property in properties.take(_maxOfflineProperties)) {
        await cacheProperty(property);
      }
      debugPrint('Cached ${properties.length} properties for offline viewing');
    } catch (e) {
      debugPrint('Error caching properties: $e');
    }
  }
  
  // Get cached property
  static Property? getCachedProperty(String propertyId) {
    return _cachedProperties[propertyId];
  }
  
  // Get all cached properties
  static List<Property> getAllCachedProperties() {
    return _cachedProperties.values.toList();
  }
  
  // Check if property is cached
  static bool isPropertyCached(String propertyId) {
    return _cachedProperties.containsKey(propertyId);
  }
  
  // Get cached image path
  static String? getCachedImagePath(String imageUrl) {
    return _cachedImagePaths[imageUrl];
  }
  
  // Check if image is cached
  static bool isImageCached(String imageUrl) {
    return _cachedImagePaths.containsKey(imageUrl);
  }
  
  // Cache image locally
  static Future<String?> _cacheImage(String imageUrl) async {
    try {
      if (_cachedImagePaths.containsKey(imageUrl)) {
        return _cachedImagePaths[imageUrl];
      }
      
      if (_cachedImagePaths.length >= _maxOfflineImages) {
        await _cleanupOldImages();
      }
      
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = imageUrl.split('/').last.split('?').first;
        final filePath = '${directory.path}/cached_images/$fileName';
        
        final file = File(filePath);
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        
        _cachedImagePaths[imageUrl] = filePath;
        await _saveCachedImages();
        
        return filePath;
      }
    } catch (e) {
      debugPrint('Error caching image $imageUrl: $e');
    }
    return null;
  }
  
  // Load cached properties from storage
  static Future<void> _loadCachedProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_offlinePropertiesKey);
      
      if (cachedData != null) {
        final Map<String, dynamic> data = json.decode(cachedData);
        _cachedProperties.clear();
        
        for (final entry in data.entries) {
          try {
            final property = Property.fromJson(entry.value);
            _cachedProperties[entry.key] = property;
          } catch (e) {
            debugPrint('Error parsing cached property ${entry.key}: $e');
          }
        }
        
        debugPrint('Loaded ${_cachedProperties.length} cached properties');
      }
    } catch (e) {
      debugPrint('Error loading cached properties: $e');
    }
  }
  
  // Save cached properties to storage
  static Future<void> _saveCachedProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {};
      
      for (final entry in _cachedProperties.entries) {
        data[entry.key] = entry.value.toJson();
      }
      
      await prefs.setString(_offlinePropertiesKey, json.encode(data));
    } catch (e) {
      debugPrint('Error saving cached properties: $e');
    }
  }
  
  // Load cached images from storage
  static Future<void> _loadCachedImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_offlineImagesKey);
      
      if (cachedData != null) {
        final Map<String, dynamic> data = json.decode(cachedData);
        _cachedImagePaths.clear();
        
        for (final entry in data.entries) {
          final filePath = entry.value as String;
          if (await File(filePath).exists()) {
            _cachedImagePaths[entry.key] = filePath;
          }
        }
        
        debugPrint('Loaded ${_cachedImagePaths.length} cached images');
      }
    } catch (e) {
      debugPrint('Error loading cached images: $e');
    }
  }
  
  // Save cached images to storage
  static Future<void> _saveCachedImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_offlineImagesKey, json.encode(_cachedImagePaths));
    } catch (e) {
      debugPrint('Error saving cached images: $e');
    }
  }
  
  // Cleanup old images when cache is full
  static Future<void> _cleanupOldImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/cached_images');
      
      if (await cacheDir.exists()) {
        final files = await cacheDir.list().toList();
        files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
        
        // Remove oldest 20% of files
        final filesToRemove = files.take((files.length * 0.2).round());
        for (final file in filesToRemove) {
          try {
            await file.delete();
            // Remove from cache map
            _cachedImagePaths.removeWhere((key, value) => value == file.path);
          } catch (e) {
            debugPrint('Error deleting cached file ${file.path}: $e');
          }
        }
        
        await _saveCachedImages();
      }
    } catch (e) {
      debugPrint('Error cleaning up old images: $e');
    }
  }
  
  // Clear all cached data
  static Future<void> clearCache() async {
    try {
      _cachedProperties.clear();
      _cachedImagePaths.clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlinePropertiesKey);
      await prefs.remove(_offlineImagesKey);
      
      // Delete cached images directory
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/cached_images');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      
      debugPrint('All offline cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
  
  // Get cache statistics
  static Future<OfflineCacheStats> getCacheStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/cached_images');
      
      int totalImages = 0;
      int totalSizeBytes = 0;
      
      if (await cacheDir.exists()) {
        final files = await cacheDir.list().toList();
        totalImages = files.length;
        
        for (final file in files) {
          try {
            final stat = await file.stat();
            totalSizeBytes += stat.size;
          } catch (e) {
            debugPrint('Error getting file stats: $e');
          }
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt(_lastSyncKey);
      final lastSyncDate = lastSync != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastSync)
          : null;
      
      return OfflineCacheStats(
        cachedProperties: _cachedProperties.length,
        cachedImages: totalImages,
        totalSizeMB: (totalSizeBytes / (1024 * 1024)).round(),
        lastSyncDate: lastSyncDate,
      );
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
      return OfflineCacheStats(
        cachedProperties: 0,
        cachedImages: 0,
        totalSizeMB: 0,
        lastSyncDate: null,
      );
    }
  }
  
  // Check if device is offline
  static Future<bool> isOffline() async {
    try {
      final result = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'Connection': 'close'},
      ).timeout(const Duration(seconds: 3));
      return result.statusCode != 200;
    } catch (e) {
      return true; // Assume offline if request fails
    }
  }
  
  // Sync cached data when online
  static Future<void> syncWhenOnline() async {
    try {
      if (await isOffline()) {
        debugPrint('Device is offline, skipping sync');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt(_lastSyncKey);
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (lastSync == null || 
          now - lastSync > _syncInterval.inMilliseconds) {
        
        // Perform sync operations here
        // This could include updating cached properties, downloading new images, etc.
        
        await prefs.setInt(_lastSyncKey, now);
        debugPrint('Offline cache synced successfully');
      }
    } catch (e) {
      debugPrint('Error syncing offline cache: $e');
    }
  }
}

class OfflineCacheStats {
  final int cachedProperties;
  final int cachedImages;
  final int totalSizeMB;
  final DateTime? lastSyncDate;
  
  OfflineCacheStats({
    required this.cachedProperties,
    required this.cachedImages,
    required this.totalSizeMB,
    this.lastSyncDate,
  });
}