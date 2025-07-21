import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/property_model.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../providers/property_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late PropertyFilters _filters;
  RangeValues _priceRange = const RangeValues(5000, 50000);
  List<String> _selectedPropertyTypes = [];
  List<String> _selectedAmenities = [];
  bool _verifiedOnly = false;

  @override
  void initState() {
    super.initState();
    final currentFilters = context.read<PropertyProvider>().currentFilters;
    _filters = currentFilters;
    
    // Initialize filter values
    _priceRange = RangeValues(
      currentFilters.minRent ?? 5000,
      currentFilters.maxRent ?? 50000,
    );
    _selectedPropertyTypes = currentFilters.propertyTypes ?? [];
    _selectedAmenities = currentFilters.amenities ?? [];
    _verifiedOnly = currentFilters.isVerified ?? false;
  }

  void _applyFilters() {
    final newFilters = PropertyFilters(
      minRent: _priceRange.start,
      maxRent: _priceRange.end,
      propertyTypes: _selectedPropertyTypes.isEmpty ? null : _selectedPropertyTypes,
      amenities: _selectedAmenities.isEmpty ? null : _selectedAmenities,
      isVerified: _verifiedOnly ? true : null,
    );
    
    context.read<PropertyProvider>().applyFilters(newFilters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(5000, 50000);
      _selectedPropertyTypes.clear();
      _selectedAmenities.clear();
      _verifiedOnly = false;
    });
    
    context.read<PropertyProvider>().clearFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  _buildPriceRangeSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Property Types
                  _buildPropertyTypesSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Amenities
                  _buildAmenitiesSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Verified Only
                  _buildVerifiedSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Apply Button
          Container(
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
              child: AnimatedButton(
                text: 'Apply Filters',
                onPressed: _applyFilters,
                icon: Icons.check,
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
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Price Display
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹${_priceRange.start.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text('to'),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹${_priceRange.end.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Range Slider
        RangeSlider(
          values: _priceRange,
          min: 1000,
          max: 100000,
          divisions: 99,
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.primaryColor.withOpacity(0.3),
          onChanged: (values) {
            setState(() => _priceRange = values);
          },
        ),
      ],
    );
  }

  Widget _buildPropertyTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Type',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.propertyTypes.map((type) {
            final isSelected = _selectedPropertyTypes.contains(type);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedPropertyTypes.remove(type);
                  } else {
                    _selectedPropertyTypes.add(type);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.borderColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : AppTheme.primaryTextColor,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.amenities.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedAmenities.add(amenity);
                  } else {
                    _selectedAmenities.remove(amenity);
                  }
                });
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVerifiedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other Filters',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: const Text('Verified Properties Only'),
            subtitle: const Text('Show only verified listings'),
            value: _verifiedOnly,
            onChanged: (value) {
              setState(() => _verifiedOnly = value);
            },
            activeColor: AppTheme.primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}