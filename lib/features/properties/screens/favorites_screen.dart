import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/favorites_service.dart';
import '../providers/property_provider.dart';
import '../widgets/property_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: const Text('Saved Properties'),
        trailing: Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, child) {
            if (favoritesProvider.favoriteCount > 0) {
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  _showClearAllDialog(context, favoritesProvider);
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: CupertinoColors.destructiveRed),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: Consumer2<FavoritesProvider, PropertyProvider>(
        builder: (context, favoritesProvider, propertyProvider, child) {
          final favoriteIds = favoritesProvider.favoritePropertyIds;
          
          if (favoriteIds.isEmpty) {
            return _buildEmptyState();
          }
          
          // Get favorite properties
          final favoriteProperties = favoriteIds
              .map((id) => propertyProvider.getPropertyById(id))
              .where((property) => property != null)
              .cast<Property>()
              .toList();
          
          if (favoriteProperties.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteProperties.length,
            itemBuilder: (context, index) {
              return PropertyCard(property: favoriteProperties[index]);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.heart,
            size: 80,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Saved Properties',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Properties you save will appear here',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryTextColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(25),
            onPressed: () {
              Navigator.of(context).pop(); // Go back to properties list
            },
            child: const Text('Browse Properties'),
          ),
        ],
      ),
    );
  }
  
  void _showClearAllDialog(BuildContext context, FavoritesProvider favoritesProvider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text('Are you sure you want to remove all saved properties?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear All'),
            onPressed: () {
              favoritesProvider.clearAllFavorites();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites cleared'),
                  backgroundColor: AppTheme.secondaryTextColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}