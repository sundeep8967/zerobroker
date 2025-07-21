import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import '../../../core/constants/app_constants.dart';

class LocationPicker extends StatefulWidget {
  final Function(loc.LocationData) onLocationSelected;
  final String? initialAddress;

  const LocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialAddress,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  loc.LocationData? _currentLocation;
  bool _isLoading = false;
  String _selectedCity = 'Bangalore';

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _addressController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      loc.Location location = loc.Location();

      // Check if location service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _showError('Location service is disabled');
          return;
        }
      }

      // Check location permissions
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          _showError('Location permission denied');
          return;
        }
      }

      // Get current location
      _currentLocation = await location.getLocation();
      
      if (_currentLocation != null) {
        // Get address from coordinates
        await _getAddressFromCoordinates(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        );
        
        widget.onLocationSelected(_currentLocation!);
      }
    } catch (e) {
      _showError('Failed to get current location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        setState(() {
          _addressController.text = 
              '${place.street}, ${place.subLocality}, ${place.locality}';
          _selectedCity = place.locality ?? 'Bangalore';
          _pincodeController.text = place.postalCode ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  Future<void> _searchLocation() async {
    if (_addressController.text.trim().isEmpty) {
      _showError('Please enter an address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String fullAddress = '${_addressController.text}, $_selectedCity';
      List<Location> locations = await locationFromAddress(fullAddress);
      
      if (locations.isNotEmpty) {
        Location geoLoc = locations.first;
        _currentLocation = loc.LocationData.fromMap({
          'latitude': geoLoc.latitude,
          'longitude': geoLoc.longitude,
        });
        
        widget.onLocationSelected(_currentLocation!);
        _showSuccess('Location found successfully!');
      } else {
        _showError('Location not found');
      }
    } catch (e) {
      _showError('Failed to search location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CupertinoColors.systemRed,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CupertinoColors.systemGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Location Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          child: CupertinoButton(
            color: CupertinoColors.systemBlue,
            onPressed: _isLoading ? null : _getCurrentLocation,
            child: _isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.location, color: CupertinoColors.white),
                      SizedBox(width: 8),
                      Text('Use Current Location'),
                    ],
                  ),
          ),
        ),

        // Divider
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR'),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 16),

        // City Selection
        _buildCitySelector(),
        const SizedBox(height: 16),

        // Address Input
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          placeholder: 'Enter street address',
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Landmark Input
        _buildTextField(
          controller: _landmarkController,
          label: 'Landmark (Optional)',
          placeholder: 'Near landmark',
        ),
        const SizedBox(height: 16),

        // Pincode Input
        _buildTextField(
          controller: _pincodeController,
          label: 'Pincode',
          placeholder: 'Enter pincode',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),

        // Search Button
        Container(
          width: double.infinity,
          child: CupertinoButton(
            color: CupertinoColors.activeGreen,
            onPressed: _isLoading ? null : _searchLocation,
            child: const Text('Search Location'),
          ),
        ),

        // Location Info
        if (_currentLocation != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CupertinoColors.systemGreen),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location Selected',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGreen,
                        ),
                      ),
                      Text(
                        'Lat: ${_currentLocation!.latitude?.toStringAsFixed(6)}, '
                        'Lng: ${_currentLocation!.longitude?.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'City',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showCityPicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCity,
                  style: const TextStyle(color: CupertinoColors.label),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCityPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Select City',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedCity = AppConstants.cities[index]['name'];
                  });
                },
                children: AppConstants.cities.map((city) {
                  return Center(
                    child: Text(
                      '${city['name']}, ${city['state']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          maxLines: maxLines,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

