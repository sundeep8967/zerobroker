import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/property_model.dart';

class PropertyComparisonWidget extends StatefulWidget {
  final List<Property> properties;
  final VoidCallback? onClose;

  const PropertyComparisonWidget({
    Key? key,
    required this.properties,
    this.onClose,
  }) : super(key: key);

  @override
  State<PropertyComparisonWidget> createState() => _PropertyComparisonWidgetState();
}

class _PropertyComparisonWidgetState extends State<PropertyComparisonWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Compare Properties (${widget.properties.length})'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryTextColor,
        elevation: 0,
        actions: [
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: widget.properties.isEmpty
          ? _buildEmptyState()
          : _buildComparisonTable(),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.square_stack_3d_down_right,
              size: 80,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 24),
            Text(
              'No Properties to Compare',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Add properties to your comparison list to see them side by side',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return FadeInUp(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Property Images Row
            _buildPropertyImagesRow(),
            
            // Comparison Table
            _buildComparisonRows(),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImagesRow() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: Row(
        children: widget.properties.map((property) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Property Image
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: property.photos.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(property.photos.first),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: property.photos.isEmpty ? AppTheme.backgroundColor : null,
                      ),
                      child: property.photos.isEmpty
                          ? const Center(
                              child: Icon(
                                CupertinoIcons.photo,
                                size: 40,
                                color: AppTheme.secondaryTextColor,
                              ),
                            )
                          : null,
                    ),
                    
                    // Property Title Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Text(
                          property.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    
                    // Verified Badge
                    if (property.isVerified)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparisonRows() {
    final comparisonData = [
      {'label': 'Rent', 'getValue': (Property p) => '₹${p.rent.toInt()}/month'},
      {'label': 'Deposit', 'getValue': (Property p) => p.deposit != null ? '₹${p.deposit!.toInt()}' : 'Not specified'},
      {'label': 'Property Type', 'getValue': (Property p) => p.propertyType},
      {'label': 'Location', 'getValue': (Property p) => p.location.address},
      {'label': 'Amenities', 'getValue': (Property p) => '${p.amenities.length} amenities'},
      {'label': 'Views', 'getValue': (Property p) => '${p.views} views'},
      {'label': 'Unlocks', 'getValue': (Property p) => '${p.unlocks} unlocks'},
      {'label': 'Listed', 'getValue': (Property p) => _formatDate(p.createdAt)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        children: comparisonData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final isEven = index % 2 == 0;
          
          return Container(
            decoration: BoxDecoration(
              color: isEven ? Colors.white : AppTheme.backgroundColor,
              borderRadius: index == 0
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    )
                  : index == comparisonData.length - 1
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        )
                      : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Label
                  SizedBox(
                    width: 100,
                    child: Text(
                      data['label'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                  ),
                  
                  // Values for each property
                  ...widget.properties.map((property) {
                    final getValue = data['getValue'] as String Function(Property);
                    final value = getValue(property);
                    
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          value,
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _shareComparison,
              icon: const Icon(CupertinoIcons.share),
              label: const Text('Share Comparison'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _saveComparison,
              icon: const Icon(CupertinoIcons.bookmark),
              label: const Text('Save Comparison'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _shareComparison() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comparison shared successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveComparison() {
    // Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comparison saved successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Service for managing property comparisons
class PropertyComparisonService {
  static final List<Property> _comparisonList = [];
  static final List<VoidCallback> _listeners = [];

  // Getters
  static List<Property> get comparisonList => List.unmodifiable(_comparisonList);
  static int get count => _comparisonList.length;
  static bool get hasProperties => _comparisonList.isNotEmpty;
  static const int maxComparisons = 4;

  // Add listener
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // Remove listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Notify listeners
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Add property to comparison
  static bool addToComparison(Property property) {
    if (_comparisonList.length >= maxComparisons) {
      return false; // Max limit reached
    }
    
    if (_comparisonList.any((p) => p.id == property.id)) {
      return false; // Already in comparison
    }
    
    _comparisonList.add(property);
    _notifyListeners();
    return true;
  }

  // Remove property from comparison
  static void removeFromComparison(String propertyId) {
    _comparisonList.removeWhere((p) => p.id == propertyId);
    _notifyListeners();
  }

  // Clear all comparisons
  static void clearAll() {
    _comparisonList.clear();
    _notifyListeners();
  }

  // Check if property is in comparison
  static bool isInComparison(String propertyId) {
    return _comparisonList.any((p) => p.id == propertyId);
  }

  // Get comparison summary
  static Map<String, dynamic> getComparisonSummary() {
    if (_comparisonList.isEmpty) return {};

    final rents = _comparisonList.map((p) => p.rent).toList();
    final avgRent = rents.reduce((a, b) => a + b) / rents.length;
    final minRent = rents.reduce((a, b) => a < b ? a : b);
    final maxRent = rents.reduce((a, b) => a > b ? a : b);

    return {
      'totalProperties': _comparisonList.length,
      'averageRent': avgRent,
      'minRent': minRent,
      'maxRent': maxRent,
      'verifiedCount': _comparisonList.where((p) => p.isVerified).length,
    };
  }
}

// Comparison Manager to handle property comparison state
class PropertyComparisonManager extends ChangeNotifier {
  static final PropertyComparisonManager _instance = PropertyComparisonManager._internal();
  factory PropertyComparisonManager() => _instance;
  PropertyComparisonManager._internal();

  final List<Property> _comparisonList = [];
  static const int maxComparisons = 3;

  List<Property> get comparisonList => List.unmodifiable(_comparisonList);
  int get count => _comparisonList.length;
  bool get isFull => _comparisonList.length >= maxComparisons;
  bool get isEmpty => _comparisonList.isEmpty;

  bool isInComparison(String propertyId) {
    return _comparisonList.any((p) => p.id == propertyId);
  }

  bool addToComparison(Property property) {
    if (_comparisonList.length >= maxComparisons) {
      return false; // Cannot add more
    }
    
    if (!isInComparison(property.id)) {
      _comparisonList.add(property);
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeFromComparison(String propertyId) {
    _comparisonList.removeWhere((p) => p.id == propertyId);
    notifyListeners();
  }

  void clearComparison() {
    _comparisonList.clear();
    notifyListeners();
  }
}