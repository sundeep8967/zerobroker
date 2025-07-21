import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/recently_viewed_service.dart';
import '../widgets/property_card.dart';

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({Key? key}) : super(key: key);

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', '1 BHK', '2 BHK', '3 BHK', 'Studio', 'Villa'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Recently Viewed'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryTextColor,
        elevation: 0,
        actions: [
          Consumer<RecentlyViewedProvider>(
            builder: (context, provider, child) {
              if (!provider.hasItems) return const SizedBox.shrink();
              
              return TextButton(
                onPressed: () => _showClearDialog(provider),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<RecentlyViewedProvider>(
        builder: (context, provider, child) {
          if (!provider.hasItems) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Filter tabs
              _buildFilterTabs(provider),
              
              // Statistics card
              _buildStatsCard(provider),
              
              // Properties list
              Expanded(
                child: _buildPropertiesList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.clock,
              size: 80,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 24),
            Text(
              'No Recently Viewed Properties',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Properties you view will appear here for quick access',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Browse Properties'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(RecentlyViewedProvider provider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(RecentlyViewedProvider provider) {
    final stats = provider.getViewingStats();
    
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Viewing Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Viewed',
                    '${stats['totalViewed']}',
                    CupertinoIcons.eye,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg. Rent',
                    '₹${(stats['averageRent'] as double).toInt()}',
                    CupertinoIcons.money_dollar,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Preferred Type',
                    stats['mostViewedType'] ?? 'N/A',
                    CupertinoIcons.home,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPropertiesList(RecentlyViewedProvider provider) {
    final properties = _selectedFilter == 'All'
        ? provider.recentlyViewed
        : provider.getByPropertyType(_selectedFilter);

    if (properties.isEmpty) {
      return FadeIn(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.search,
                size: 60,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No properties found for "$_selectedFilter"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: Dismissible(
            key: Key(property.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.delete,
                color: Colors.white,
                size: 24,
              ),
            ),
            onDismissed: (direction) {
              provider.removeProperty(property.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${property.title} from recently viewed'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      provider.addProperty(property);
                    },
                  ),
                ),
              );
            },
            child: PropertyCard(property: property),
          ),
        );
      },
    );
  }

  void _showClearDialog(RecentlyViewedProvider provider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Recently Viewed'),
        content: const Text('Are you sure you want to clear all recently viewed properties?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear All'),
            onPressed: () {
              provider.clearAll();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}