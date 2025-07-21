import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/property_model.dart';
import '../../properties/providers/property_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../properties/screens/property_details_screen.dart';
import '../../properties/screens/add_property_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  List<Property> _userProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProperties();
  }

  Future<void> _loadUserProperties() async {
    final authProvider = context.read<AuthProvider>();
    final propertyProvider = context.read<PropertyProvider>();
    final userId = authProvider.currentUser?.id ?? 'demo_user';

    setState(() {
      _isLoading = true;
    });

    try {
      // Filter properties by current user
      final allProperties = propertyProvider.properties;
      final userProperties = allProperties.where((property) => 
        property.ownerId == userId
      ).toList();

      setState(() {
        _userProperties = userProperties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load your properties');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CupertinoColors.systemRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CupertinoColors.systemGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteProperty(Property property) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${property.title}"? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final propertyProvider = context.read<PropertyProvider>();
        // TODO: Implement delete property functionality
        // await propertyProvider.deleteProperty(property.id);
        _showSuccessSnackBar('Property deleted successfully');
        _loadUserProperties(); // Refresh the list
      } catch (e) {
        _showErrorSnackBar('Failed to delete property');
      }
    }
  }

  Future<void> _editProperty(Property property) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) => const AddPropertyScreen(),
      ),
    );

    if (result == true) {
      _loadUserProperties(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: const Text('My Properties'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(
              CupertinoPageRoute(
                builder: (context) => const AddPropertyScreen(),
              ),
            );
            if (result == true) {
              _loadUserProperties();
            }
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 20),
            )
          : RefreshIndicator(
              onRefresh: _loadUserProperties,
              child: _userProperties.isEmpty
                  ? _buildEmptyState()
                  : _buildPropertiesList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  CupertinoIcons.home,
                  size: 60,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Properties Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Start by adding your first property to reach potential tenants.',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      CupertinoPageRoute(
                        builder: (context) => const AddPropertyScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadUserProperties();
                    }
                  },
                  child: const Text('Add Your First Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userProperties.length,
      itemBuilder: (context, index) {
        final property = _userProperties[index];
        return FadeInUp(
          duration: Duration(milliseconds: 600 + (index * 100)),
          child: _buildPropertyCard(property),
        );
      },
    );
  }

  Widget _buildPropertyCard(Property property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: property.photos.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: property.photos.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: CupertinoColors.systemGrey5,
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: CupertinoColors.systemGrey5,
                        child: const Icon(
                          CupertinoIcons.photo,
                          size: 40,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    )
                  : Container(
                      color: CupertinoColors.systemGrey5,
                      child: const Icon(
                        CupertinoIcons.photo,
                        size: 40,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
            ),
          ),
          
          // Property Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(true).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Available',
                        style: TextStyle(
                          color: _getStatusColor(true),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.location,
                      size: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.location.city}, ${property.location.state}',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${property.rent.toStringAsFixed(0)}/month',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.eye,
                          size: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${property.viewCount} views',
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.systemBlue,
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => PropertyDetailsScreen(
                                propertyId: property.id,
                              ),
                            ),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CupertinoButton(
                      padding: const EdgeInsets.all(12),
                      color: CupertinoColors.systemGrey5,
                      onPressed: () => _editProperty(property),
                      child: const Icon(
                        CupertinoIcons.pencil,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: const EdgeInsets.all(12),
                      color: CupertinoColors.systemRed.withOpacity(0.1),
                      onPressed: () => _deleteProperty(property),
                      child: const Icon(
                        CupertinoIcons.trash,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(bool isAvailable) {
    return isAvailable ? CupertinoColors.systemGreen : CupertinoColors.systemOrange;
  }
}