import 'package:flutter/material.dart';
import '../../../core/models/property_model.dart';

class PropertyProvider extends ChangeNotifier {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  PropertyFilters _currentFilters = PropertyFilters();
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Property> get properties => _filteredProperties;
  PropertyFilters get currentFilters => _currentFilters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with dummy data
  Future<void> initializeProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Generate dummy properties for demo
      _properties = _generateDummyProperties();
      _filteredProperties = List.from(_properties);
    } catch (e) {
      _error = 'Failed to load properties';
      debugPrint('Property initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply filters
  void applyFilters(PropertyFilters filters) {
    _currentFilters = filters;
    _filteredProperties = _properties.where((property) {
      // Price filter
      if (filters.minRent != null && property.rent < filters.minRent!) {
        return false;
      }
      if (filters.maxRent != null && property.rent > filters.maxRent!) {
        return false;
      }
      
      // Property type filter
      if (filters.propertyTypes != null && 
          filters.propertyTypes!.isNotEmpty &&
          !filters.propertyTypes!.contains(property.propertyType)) {
        return false;
      }
      
      // City filter
      if (filters.city != null && 
          property.location.city.toLowerCase() != filters.city!.toLowerCase()) {
        return false;
      }
      
      // Verified filter
      if (filters.isVerified != null && 
          property.isVerified != filters.isVerified!) {
        return false;
      }
      
      return true;
    }).toList();
    
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _currentFilters = PropertyFilters();
    _filteredProperties = List.from(_properties);
    notifyListeners();
  }

  // Get property by ID
  Property? getPropertyById(String id) {
    try {
      return _properties.firstWhere((property) => property.id == id);
    } catch (e) {
      return null;
    }
  }

  // Unlock contact for a property
  Future<bool> unlockContact(String propertyId) async {
    try {
      final propertyIndex = _properties.indexWhere((p) => p.id == propertyId);
      if (propertyIndex != -1) {
        final property = _properties[propertyIndex];
        final updatedProperty = property.copyWith(
          unlocks: property.unlocks + 1,
        );
        _properties[propertyIndex] = updatedProperty;
        
        // Update filtered properties as well
        final filteredIndex = _filteredProperties.indexWhere((p) => p.id == propertyId);
        if (filteredIndex != -1) {
          _filteredProperties[filteredIndex] = updatedProperty;
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error unlocking contact: $e');
      return false;
    }
  }

  // Add property
  Future<bool> addProperty(Property property) async {
    try {
      _properties.add(property);
      applyFilters(_currentFilters); // Reapply filters
      return true;
    } catch (e) {
      _error = 'Failed to add property';
      debugPrint('Add property error: $e');
      return false;
    }
  }

  // Search properties
  void searchProperties(String query) {
    if (query.isEmpty) {
      _filteredProperties = List.from(_properties);
    } else {
      _filteredProperties = _properties.where((property) {
        return property.title.toLowerCase().contains(query.toLowerCase()) ||
               property.location.city.toLowerCase().contains(query.toLowerCase()) ||
               property.location.address.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }


  // Generate dummy properties for demo
  List<Property> _generateDummyProperties() {
    return [
      Property(
        id: '1',
        title: 'Spacious 2BHK in HSR Layout',
        description: 'Beautiful 2BHK apartment with modern amenities, close to metro station and IT parks. This property features a spacious living room, well-ventilated bedrooms, and a modern kitchen.',
        rent: 25000,
        deposit: 50000,
        propertyType: '2 BHK',
        location: PropertyLocation(
          latitude: 12.9116,
          longitude: 77.6473,
          address: 'HSR Layout, Sector 1',
          city: 'Bangalore',
          state: 'Karnataka',
          pincode: '560102',
          landmark: 'Near Forum Mall',
        ),
        photos: [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
          'https://images.unsplash.com/photo-1560449752-8d4b7b8e8b6e?w=800',
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
        ],
        amenities: ['Parking', 'Lift', 'Security', 'Power Backup', 'Water Supply'],
        ownerId: 'owner_1',
        ownerName: 'Rajesh Kumar',
        ownerPhone: '+91 9876543210',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
        views: 45,
        unlocks: 12,
      ),
      Property(
        id: '2',
        title: 'Luxury 3BHK in Whitefield',
        description: 'Premium 3BHK apartment with swimming pool, gym, and 24/7 security. Perfect for families looking for luxury living with all modern amenities.',
        rent: 45000,
        deposit: 90000,
        propertyType: '3 BHK',
        location: PropertyLocation(
          latitude: 12.9698,
          longitude: 77.7500,
          address: 'Whitefield Main Road',
          city: 'Bangalore',
          state: 'Karnataka',
          pincode: '560066',
          landmark: 'Near Phoenix MarketCity',
        ),
        photos: [
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
          'https://images.unsplash.com/photo-1565182999561-18d7dc61c393?w=800',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
        ],
        amenities: ['Swimming Pool', 'Gym', 'Parking', 'Security', 'Club House', 'Garden'],
        ownerId: 'owner_2',
        ownerName: 'Priya Sharma',
        ownerPhone: '+91 9876543211',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerified: true,
        views: 78,
        unlocks: 23,
      ),
      Property(
        id: '3',
        title: 'Cozy 1BHK in Koramangala',
        description: 'Perfect for young professionals, fully furnished 1BHK with all modern amenities. Located in the heart of Koramangala with easy access to restaurants and cafes.',
        rent: 18000,
        deposit: 36000,
        propertyType: '1 BHK',
        location: PropertyLocation(
          latitude: 12.9352,
          longitude: 77.6245,
          address: 'Koramangala 4th Block',
          city: 'Bangalore',
          state: 'Karnataka',
          pincode: '560034',
          landmark: 'Near Forum Mall',
        ),
        photos: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
          'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
        ],
        amenities: ['Parking', 'Lift', 'Security', 'Furnished'],
        ownerId: 'owner_3',
        ownerName: 'Amit Patel',
        ownerPhone: '+91 9876543212',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isVerified: false,
        views: 23,
        unlocks: 5,
      ),
      Property(
        id: '4',
        title: 'Modern Studio in Indiranagar',
        description: 'Compact and modern studio apartment perfect for singles. Fully furnished with high-speed internet and modern appliances.',
        rent: 15000,
        deposit: 30000,
        propertyType: 'Studio',
        location: PropertyLocation(
          latitude: 12.9784,
          longitude: 77.6408,
          address: 'Indiranagar 100 Feet Road',
          city: 'Bangalore',
          state: 'Karnataka',
          pincode: '560038',
          landmark: 'Near Metro Station',
        ),
        photos: [
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800',
        ],
        amenities: ['Wi-Fi', 'Furnished', 'AC', 'Security'],
        ownerId: 'owner_4',
        ownerName: 'Sneha Reddy',
        ownerPhone: '+91 9876543213',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        isVerified: true,
        views: 15,
        unlocks: 3,
      ),
      Property(
        id: '5',
        title: 'Family Villa in Sarjapur',
        description: 'Spacious 4BHK independent villa with garden, perfect for large families. Quiet neighborhood with good connectivity.',
        rent: 60000,
        deposit: 120000,
        propertyType: '4 BHK',
        location: PropertyLocation(
          latitude: 12.8797,
          longitude: 77.6952,
          address: 'Sarjapur Road',
          city: 'Bangalore',
          state: 'Karnataka',
          pincode: '560035',
          landmark: 'Near Wipro Corporate Office',
        ),
        photos: [
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
          'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800',
        ],
        amenities: ['Garden', 'Parking', 'Security', 'Power Backup', 'Bore Well'],
        ownerId: 'owner_5',
        ownerName: 'Vikram Singh',
        ownerPhone: '+91 9876543214',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isVerified: true,
        views: 67,
        unlocks: 18,
      ),
    ];
  }
}