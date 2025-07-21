import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/property_model.dart';
import '../providers/property_provider.dart';
import '../widgets/property_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Property? _selectedProperty;
  Map<String, dynamic> _filters = {};
  
  // Default location (Bangalore)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(12.9716, 77.5946),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPropertyMarkers();
    });
  }

  void _loadPropertyMarkers() {
    final propertyProvider = context.read<PropertyProvider>();
    final properties = propertyProvider.properties;
    
    setState(() {
      _markers = properties.map((property) {
        return Marker(
          markerId: MarkerId(property.id),
          position: LatLng(
            property.location.latitude,
            property.location.longitude,
          ),
          infoWindow: InfoWindow(
            title: property.title,
            snippet: '₹${property.rent.toInt()}/month',
          ),
          onTap: () {
            setState(() {
              _selectedProperty = property;
            });
          },
        );
      }).toSet();
    });
  }

  void _goToCurrentLocation() async {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(_initialPosition),
      );
    }
  }

  List<Property> _applyFiltersToProperties(List<Property> properties) {
    if (_filters.isEmpty) return properties;

    return properties.where((property) {
      // Price range filter
      if (_filters['minRent'] != null && property.rent < _filters['minRent']) {
        return false;
      }
      if (_filters['maxRent'] != null && property.rent > _filters['maxRent']) {
        return false;
      }

      // Property type filter
      if (_filters['propertyType'] != null && 
          property.propertyType != _filters['propertyType']) {
        return false;
      }

      // Verified only filter
      if (_filters['verifiedOnly'] == true && !property.isVerified) {
        return false;
      }

      // Amenities filter
      if (_filters['amenities'] != null && _filters['amenities'].isNotEmpty) {
        final requiredAmenities = List<String>.from(_filters['amenities']);
        final hasAllAmenities = requiredAmenities.every(
          (amenity) => property.amenities.contains(amenity),
        );
        if (!hasAllAmenities) return false;
      }

      return true;
    }).toList();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Text('Map Filters Coming Soon'),
        ),
      ), // MapFiltersBottomSheet(
        currentFilters: _filters,
        onFiltersApplied: (filters) {
          setState(() {
            _filters = filters;
          });
          _loadPropertyMarkers();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            buildingsEnabled: true,
            trafficEnabled: false,
          ),
          
          // Search bar overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(
                    CupertinoIcons.search,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Search location...',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _loadPropertyMarkers();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        CupertinoIcons.slider_horizontal_3,
                        color: CupertinoColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          
          // My Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _goToCurrentLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      CupertinoIcons.location,
                      size: 24,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom sheet handle
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomSheet() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '127 properties found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'in this area',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey.darkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(20),
                    onPressed: () {
                      // TODO: Show list view
                    },
                    child: const Text(
                      'View List',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}