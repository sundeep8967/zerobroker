import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/property_model.dart';
import '../../../core/services/firebase_service.dart';

class FirebasePropertyProvider extends ChangeNotifier {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  Map<String, dynamic> _filters = {};
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;

  // Getters
  List<Property> get properties => _filteredProperties.isEmpty && _searchQuery.isEmpty 
      ? _properties 
      : _filteredProperties;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;
  String get searchQuery => _searchQuery;
  Map<String, dynamic> get filters => _filters;

  // Initialize properties from Firebase
  Future<void> initializeProperties() async {
    _isLoading = true;
    _error = null;
    _lastDocument = null;
    _hasMoreData = true;
    notifyListeners();

    try {
      final properties = await FirebaseService.getProperties(limit: 20);
      _properties = properties;
      _filteredProperties = [];
      _searchQuery = '';
      _filters = {};
      _error = null;
    } catch (e) {
      _error = e.toString();
      _properties = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more properties (pagination)
  Future<void> loadMoreProperties() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newProperties = await FirebaseService.getProperties(
        limit: 20,
        lastDocument: _lastDocument,
        filters: _filters.isNotEmpty ? _filters : null,
      );

      if (newProperties.isEmpty) {
        _hasMoreData = false;
      } else {
        _properties.addAll(newProperties);
        // Update last document for pagination
        // Note: You'll need to modify FirebaseService to return the last document
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Search properties
  Future<void> searchProperties(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredProperties = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final searchResults = await FirebaseService.searchProperties(query);
      _filteredProperties = searchResults;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _filteredProperties = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply filters
  Future<void> applyFilters(Map<String, dynamic> filters) async {
    _filters = filters;
    _isLoading = true;
    _lastDocument = null;
    _hasMoreData = true;
    notifyListeners();

    try {
      final filteredProperties = await FirebaseService.getProperties(
        limit: 20,
        filters: filters,
      );
      _properties = filteredProperties;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _properties = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear filters
  void clearFilters() {
    _filters = {};
    initializeProperties();
  }

  // Get property by ID
  Property? getPropertyById(String id) {
    try {
      return _properties.firstWhere((property) => property.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new property
  Future<String?> addProperty(Property property) async {
    try {
      final propertyId = await FirebaseService.createProperty(property);
      
      // Add to local list
      final newProperty = property.copyWith(id: propertyId);
      _properties.insert(0, newProperty);
      notifyListeners();
      
      return propertyId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update property
  Future<bool> updateProperty(Property property) async {
    try {
      await FirebaseService.updateProperty(property);
      
      // Update local list
      final index = _properties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        _properties[index] = property;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete property
  Future<bool> deleteProperty(String propertyId) async {
    try {
      await FirebaseService.deleteProperty(propertyId);
      
      // Remove from local list
      _properties.removeWhere((p) => p.id == propertyId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Unlock contact
  Future<bool> unlockContact(String propertyId, String userId, String paymentId) async {
    try {
      await FirebaseService.recordUnlock(
        userId: userId,
        propertyId: propertyId,
        paymentId: paymentId,
        amount: 10.0,
      );

      // Update local property unlock count
      final propertyIndex = _properties.indexWhere((p) => p.id == propertyId);
      if (propertyIndex != -1) {
        final property = _properties[propertyIndex];
        _properties[propertyIndex] = property.copyWith(
          unlocks: property.unlocks + 1,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check if user has unlocked property
  Future<bool> hasUserUnlockedProperty(String userId, String propertyId) async {
    try {
      return await FirebaseService.hasUserUnlockedProperty(userId, propertyId);
    } catch (e) {
      return false;
    }
  }

  // Get user's unlocked properties
  Future<List<String>> getUserUnlockedProperties(String userId) async {
    try {
      return await FirebaseService.getUserUnlockedProperties(userId);
    } catch (e) {
      return [];
    }
  }

  // Report property
  Future<bool> reportProperty({
    required String propertyId,
    required String userId,
    required String reason,
    String? description,
  }) async {
    try {
      await FirebaseService.reportProperty(
        propertyId: propertyId,
        userId: userId,
        reason: reason,
        description: description,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Refresh properties
  Future<void> refreshProperties() async {
    await initializeProperties();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}