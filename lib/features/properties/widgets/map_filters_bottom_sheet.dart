import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';

class MapFiltersBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const MapFiltersBottomSheet({
    Key? key,
    required this.currentFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<MapFiltersBottomSheet> createState() => _MapFiltersBottomSheetState();
}

class _MapFiltersBottomSheetState extends State<MapFiltersBottomSheet> {
  late Map<String, dynamic> _filters;
  RangeValues _priceRange = const RangeValues(5000, 50000);
  String? _selectedPropertyType;
  List<String> _selectedAmenities = [];
  bool _verifiedOnly = false;
  bool _availableNow = true;

  final List<String> _propertyTypes = [
    '1 RK',
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4+ BHK',
    'Studio',
    'Villa',
    'Penthouse',
  ];

  final List<String> _amenities = [
    'Parking',
    'Gym',
    'Swimming Pool',
    'Security',
    'Power Backup',
    'Lift',
    'Garden',
    'Club House',
    'Wi-Fi',
    'AC',
    'Furnished',
    'Semi-Furnished',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _initializeFilters();
  }

  void _initializeFilters() {
    _priceRange = RangeValues(
      (_filters['minRent'] ?? 5000).toDouble(),
      (_filters['maxRent'] ?? 50000).toDouble(),
    );
    _selectedPropertyType = _filters['propertyType'];
    _selectedAmenities = List<String>.from(_filters['amenities'] ?? []);
    _verifiedOnly = _filters['verifiedOnly'] ?? false;
    _availableNow = _filters['availableNow'] ?? true;
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'minRent': _priceRange.start.round(),
      'maxRent': _priceRange.end.round(),
      'propertyType': _selectedPropertyType,
      'amenities': _selectedAmenities,
      'verifiedOnly': _verifiedOnly,
      'availableNow': _availableNow,
    };

    // Remove null values
    filters.removeWhere((key, value) => value == null);

    widget.onFiltersApplied(filters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(5000, 50000);
      _selectedPropertyType = null;
      _selectedAmenities = [];
      _verifiedOnly = false;
      _availableNow = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _clearFilters,
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Filters Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildPriceRangeSection(),
                  ),

                  const SizedBox(height: 30),

                  // Property Type
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildPropertyTypeSection(),
                  ),

                  const SizedBox(height: 30),

                  // Quick Filters
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildQuickFiltersSection(),
                  ),

                  const SizedBox(height: 30),

                  // Amenities
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildAmenitiesSection(),
                  ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),

          // Apply Button
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${_priceRange.start.round().toString()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    '₹${_priceRange.end.round().toString()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: _priceRange,
                min: 1000,
                max: 100000,
                divisions: 99,
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.primaryColor.withOpacity(0.3),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Type',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _propertyTypes.map((type) {
            final isSelected = _selectedPropertyType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPropertyType = isSelected ? null : type;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          'Verified Properties Only',
          'Show only verified listings',
          _verifiedOnly,
          (value) => setState(() => _verifiedOnly = value),
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          'Available Now',
          'Show only immediately available properties',
          _availableNow,
          (value) => setState(() => _availableNow = value),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _amenities.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAmenities.remove(amenity);
                  } else {
                    _selectedAmenities.add(amenity);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.1) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    if (isSelected) const SizedBox(width: 4),
                    Text(
                      amenity,
                      style: TextStyle(
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.primaryTextColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}