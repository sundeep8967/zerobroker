import 'package:flutter/material.dart';

class FavoritesService {
  static final Set<String> _favoritePropertyIds = <String>{};
  static final List<VoidCallback> _listeners = [];
  
  // Getters
  static Set<String> get favoritePropertyIds => Set.unmodifiable(_favoritePropertyIds);
  static bool isFavorite(String propertyId) => _favoritePropertyIds.contains(propertyId);
  static int get favoriteCount => _favoritePropertyIds.length;
  
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
  
  // Toggle favorite status
  static bool toggleFavorite(String propertyId) {
    if (_favoritePropertyIds.contains(propertyId)) {
      _favoritePropertyIds.remove(propertyId);
      _notifyListeners();
      return false; // Removed from favorites
    } else {
      _favoritePropertyIds.add(propertyId);
      _notifyListeners();
      return true; // Added to favorites
    }
  }
  
  // Add to favorites
  static void addToFavorites(String propertyId) {
    if (!_favoritePropertyIds.contains(propertyId)) {
      _favoritePropertyIds.add(propertyId);
      _notifyListeners();
    }
  }
  
  // Remove from favorites
  static void removeFromFavorites(String propertyId) {
    if (_favoritePropertyIds.contains(propertyId)) {
      _favoritePropertyIds.remove(propertyId);
      _notifyListeners();
    }
  }
  
  // Clear all favorites
  static void clearAllFavorites() {
    _favoritePropertyIds.clear();
    _notifyListeners();
  }
  
  // Get favorite properties list (for use with PropertyProvider)
  static List<String> getFavoritesList() {
    return _favoritePropertyIds.toList();
  }
  
  // Load favorites from storage (mock implementation)
  static Future<void> loadFavorites() async {
    // In a real app, this would load from SharedPreferences or database
    // For now, we'll just simulate loading
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock some initial favorites for demo
    _favoritePropertyIds.addAll(['1', '3']); // Add property IDs 1 and 3 as favorites
    _notifyListeners();
  }
  
  // Save favorites to storage (mock implementation)
  static Future<void> saveFavorites() async {
    // In a real app, this would save to SharedPreferences or database
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('Favorites saved: ${_favoritePropertyIds.toList()}');
  }
}

// Provider class for favorites
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider() {
    FavoritesService.addListener(_onFavoritesChanged);
    _loadInitialFavorites();
  }
  
  @override
  void dispose() {
    FavoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }
  
  void _onFavoritesChanged() {
    notifyListeners();
  }
  
  Future<void> _loadInitialFavorites() async {
    await FavoritesService.loadFavorites();
  }
  
  // Getters
  Set<String> get favoritePropertyIds => FavoritesService.favoritePropertyIds;
  bool isFavorite(String propertyId) => FavoritesService.isFavorite(propertyId);
  int get favoriteCount => FavoritesService.favoriteCount;
  
  // Actions
  bool toggleFavorite(String propertyId) {
    final isNowFavorite = FavoritesService.toggleFavorite(propertyId);
    FavoritesService.saveFavorites(); // Save to storage
    return isNowFavorite;
  }
  
  void addToFavorites(String propertyId) {
    FavoritesService.addToFavorites(propertyId);
    FavoritesService.saveFavorites();
  }
  
  void removeFromFavorites(String propertyId) {
    FavoritesService.removeFromFavorites(propertyId);
    FavoritesService.saveFavorites();
  }
  
  void clearAllFavorites() {
    FavoritesService.clearAllFavorites();
    FavoritesService.saveFavorites();
  }
}