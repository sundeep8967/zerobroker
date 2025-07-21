import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/property_model.dart';

class RecentlyViewedService {
  static const String _recentlyViewedKey = 'recently_viewed_properties';
  static const int _maxRecentItems = 20;
  
  static List<Property> _recentlyViewed = [];
  static final List<VoidCallback> _listeners = [];

  // Getters
  static List<Property> get recentlyViewed => List.unmodifiable(_recentlyViewed);
  static int get count => _recentlyViewed.length;
  static bool get hasItems => _recentlyViewed.isNotEmpty;

  // Add listener for changes
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // Remove listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Load recently viewed from storage
  static Future<void> loadRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentlyViewedKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _recentlyViewed = jsonList
            .map((json) => Property.fromJson(json))
            .toList();
        _notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading recently viewed: $e');
      _recentlyViewed = [];
    }
  }

  // Save recently viewed to storage
  static Future<void> _saveRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _recentlyViewed.map((property) => property.toJson()).toList();
      await prefs.setString(_recentlyViewedKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving recently viewed: $e');
    }
  }

  // Add property to recently viewed
  static Future<void> addProperty(Property property) async {
    try {
      // Remove if already exists
      _recentlyViewed.removeWhere((p) => p.id == property.id);
      
      // Add to beginning
      _recentlyViewed.insert(0, property);
      
      // Limit to max items
      if (_recentlyViewed.length > _maxRecentItems) {
        _recentlyViewed = _recentlyViewed.take(_maxRecentItems).toList();
      }
      
      await _saveRecentlyViewed();
      _notifyListeners();
    } catch (e) {
      debugPrint('Error adding property to recently viewed: $e');
    }
  }

  // Remove property from recently viewed
  static Future<void> removeProperty(String propertyId) async {
    try {
      _recentlyViewed.removeWhere((p) => p.id == propertyId);
      await _saveRecentlyViewed();
      _notifyListeners();
    } catch (e) {
      debugPrint('Error removing property from recently viewed: $e');
    }
  }

  // Clear all recently viewed
  static Future<void> clearAll() async {
    try {
      _recentlyViewed.clear();
      await _saveRecentlyViewed();
      _notifyListeners();
    } catch (e) {
      debugPrint('Error clearing recently viewed: $e');
    }
  }

  // Get recently viewed by property type
  static List<Property> getByPropertyType(String propertyType) {
    return _recentlyViewed
        .where((property) => property.propertyType == propertyType)
        .toList();
  }

  // Get recently viewed in price range
  static List<Property> getByPriceRange(double minRent, double maxRent) {
    return _recentlyViewed
        .where((property) => 
            property.rent >= minRent && property.rent <= maxRent)
        .toList();
  }

  // Check if property is recently viewed
  static bool isRecentlyViewed(String propertyId) {
    return _recentlyViewed.any((p) => p.id == propertyId);
  }

  // Get similar properties based on recently viewed
  static List<Property> getSimilarProperties(List<Property> allProperties) {
    if (_recentlyViewed.isEmpty) return [];

    // Get most common property type from recently viewed
    final propertyTypeCounts = <String, int>{};
    for (final property in _recentlyViewed) {
      propertyTypeCounts[property.propertyType] = 
          (propertyTypeCounts[property.propertyType] ?? 0) + 1;
    }

    final mostCommonType = propertyTypeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Calculate average rent from recently viewed
    final avgRent = _recentlyViewed
        .map((p) => p.rent)
        .reduce((a, b) => a + b) / _recentlyViewed.length;

    // Find similar properties
    return allProperties
        .where((property) => 
            property.propertyType == mostCommonType &&
            (property.rent - avgRent).abs() <= avgRent * 0.3 && // Within 30% of avg rent
            !_recentlyViewed.any((recent) => recent.id == property.id)) // Not already viewed
        .take(10)
        .toList();
  }

  // Get viewing statistics
  static Map<String, dynamic> getViewingStats() {
    if (_recentlyViewed.isEmpty) {
      return {
        'totalViewed': 0,
        'averageRent': 0.0,
        'mostViewedType': '',
        'priceRange': {'min': 0.0, 'max': 0.0},
      };
    }

    final rents = _recentlyViewed.map((p) => p.rent).toList();
    final avgRent = rents.reduce((a, b) => a + b) / rents.length;
    
    final propertyTypeCounts = <String, int>{};
    for (final property in _recentlyViewed) {
      propertyTypeCounts[property.propertyType] = 
          (propertyTypeCounts[property.propertyType] ?? 0) + 1;
    }

    final mostViewedType = propertyTypeCounts.isNotEmpty
        ? propertyTypeCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : '';

    return {
      'totalViewed': _recentlyViewed.length,
      'averageRent': avgRent,
      'mostViewedType': mostViewedType,
      'priceRange': {
        'min': rents.reduce((a, b) => a < b ? a : b),
        'max': rents.reduce((a, b) => a > b ? a : b),
      },
      'propertyTypeCounts': propertyTypeCounts,
    };
  }
}

// Provider class for recently viewed
class RecentlyViewedProvider extends ChangeNotifier {
  RecentlyViewedProvider() {
    RecentlyViewedService.addListener(_onRecentlyViewedChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    RecentlyViewedService.removeListener(_onRecentlyViewedChanged);
    super.dispose();
  }

  void _onRecentlyViewedChanged() {
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    await RecentlyViewedService.loadRecentlyViewed();
  }

  // Getters
  List<Property> get recentlyViewed => RecentlyViewedService.recentlyViewed;
  int get count => RecentlyViewedService.count;
  bool get hasItems => RecentlyViewedService.hasItems;

  // Actions
  Future<void> addProperty(Property property) async {
    await RecentlyViewedService.addProperty(property);
  }

  Future<void> removeProperty(String propertyId) async {
    await RecentlyViewedService.removeProperty(propertyId);
  }

  Future<void> clearAll() async {
    await RecentlyViewedService.clearAll();
  }

  List<Property> getByPropertyType(String propertyType) {
    return RecentlyViewedService.getByPropertyType(propertyType);
  }

  List<Property> getByPriceRange(double minRent, double maxRent) {
    return RecentlyViewedService.getByPriceRange(minRent, maxRent);
  }

  bool isRecentlyViewed(String propertyId) {
    return RecentlyViewedService.isRecentlyViewed(propertyId);
  }

  List<Property> getSimilarProperties(List<Property> allProperties) {
    return RecentlyViewedService.getSimilarProperties(allProperties);
  }

  Map<String, dynamic> getViewingStats() {
    return RecentlyViewedService.getViewingStats();
  }
}