import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/property_comparison_widget.dart';
import '../../../core/theme/app_theme.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final comparisonManager = PropertyComparisonManager();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CupertinoNavigationBar(
        middle: const Text('Property Comparison'),
        backgroundColor: Colors.white,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        trailing: comparisonManager.count > 0
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Clear Comparison'),
                      content: const Text('Are you sure you want to remove all properties from comparison?'),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            comparisonManager.clearComparison();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Clear All'),
              )
            : null,
      ),
      body: AnimatedBuilder(
        animation: comparisonManager,
        builder: (context, child) {
          if (comparisonManager.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return PropertyComparisonWidget(
            properties: comparisonManager.comparisonList,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.building_2_fill,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Properties to Compare',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add properties to your comparison list\nfrom property details to see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.search),
            label: const Text('Browse Properties'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}