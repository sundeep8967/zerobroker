import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/services/offline_cache_service.dart';
import '../../../core/models/property_model.dart';
import '../../properties/widgets/property_card.dart';
import '../../properties/screens/property_details_screen.dart';

class OfflinePropertiesScreen extends StatefulWidget {
  const OfflinePropertiesScreen({super.key});

  @override
  State<OfflinePropertiesScreen> createState() => _OfflinePropertiesScreenState();
}

class _OfflinePropertiesScreenState extends State<OfflinePropertiesScreen> {
  List<Property> _cachedProperties = [];
  bool _isLoading = true;
  Map<String, dynamic> _offlineStatus = {};

  @override
  void initState() {
    super.initState();
    _loadOfflineData();
  }

  Future<void> _loadOfflineData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final properties = await OfflineCacheService.getCachedProperties();
      final status = await OfflineCacheService.getOfflineStatus();

      setState(() {
        _cachedProperties = properties;
        _offlineStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load offline data');
    }
  }

  Future<void> _clearCache() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Offline Cache'),
        content: const Text(
          'This will remove all cached properties and free up storage space. You\'ll need an internet connection to browse properties again.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );

    if (result == true) {
      await OfflineCacheService.clearCache();
      _showSuccessSnackBar('Cache cleared successfully');
      _loadOfflineData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: const Text('Offline Properties'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _clearCache,
          child: const Icon(CupertinoIcons.trash),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 20),
            )
          : RefreshIndicator(
              onRefresh: _loadOfflineData,
              child: Column(
                children: [
                  _buildOfflineStatusCard(),
                  Expanded(
                    child: _cachedProperties.isEmpty
                        ? _buildEmptyState()
                        : _buildPropertiesList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOfflineStatusCard() {
    final isOnline = _offlineStatus['isOnline'] ?? false;
    final cacheSize = _offlineStatus['cacheSize'] ?? 0.0;
    final propertiesCount = _offlineStatus['cachedPropertiesCount'] ?? 0;

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline 
                        ? CupertinoColors.systemGreen 
                        : CupertinoColors.systemRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (!isOnline)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Offline Mode',
                      style: TextStyle(
                        color: CupertinoColors.systemOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    'Cached Properties',
                    '$propertiesCount',
                    CupertinoIcons.house_alt,
                    CupertinoColors.systemBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatusItem(
                    'Cache Size',
                    '${cacheSize.toStringAsFixed(1)} MB',
                    CupertinoIcons.folder,
                    CupertinoColors.systemPurple,
                  ),
                ),
              ],
            ),
            if (!isOnline) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(
                      CupertinoIcons.wifi_slash,
                      color: CupertinoColors.systemOrange,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You\'re offline. Showing cached properties only.',
                        style: TextStyle(
                          color: CupertinoColors.systemOrange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
                  color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  CupertinoIcons.wifi_slash,
                  size: 60,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Offline Properties',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Browse properties while online to automatically cache them for offline viewing.',
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Browse Properties Online'),
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
      itemCount: _cachedProperties.length,
      itemBuilder: (context, index) {
        final property = _cachedProperties[index];
        return FadeInUp(
          duration: Duration(milliseconds: 600 + (index * 100)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                // Check if detailed property data is cached
                final cachedDetails = await OfflineCacheService.getCachedPropertyDetails(property.id);
                
                if (cachedDetails != null && mounted) {
                  navigator.push(
                    CupertinoPageRoute(
                      builder: (context) => PropertyDetailsScreen(
                        propertyId: property.id,
                      ),
                    ),
                  );
                } else if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Property details not available offline'),
                      backgroundColor: CupertinoColors.systemRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Stack(
                children: [
                  PropertyCard(property: property),
                  // Offline indicator overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            CupertinoIcons.wifi_slash,
                            color: CupertinoColors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'OFFLINE',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}