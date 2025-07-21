import 'dart:math';
import '../models/analytics_model.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final Map<String, PropertyAnalytics> _propertyAnalytics = {};
  OverallAnalytics? _overallAnalytics;

  // Initialize with mock data
  void initializeMockData() {
    _generateMockPropertyAnalytics();
    _generateMockOverallAnalytics();
  }

  // Get property analytics
  Future<PropertyAnalytics?> getPropertyAnalytics(String propertyId, AnalyticsFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    return _propertyAnalytics[propertyId];
  }

  // Get overall analytics
  Future<OverallAnalytics> getOverallAnalytics(AnalyticsFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network delay
    return _overallAnalytics ?? _generateMockOverallAnalytics();
  }

  // Get user's properties analytics
  Future<List<PropertyAnalytics>> getUserPropertiesAnalytics(String userId, AnalyticsFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Return subset of properties for the user
    return _propertyAnalytics.values.take(3).toList();
  }

  // Get analytics summary
  Future<Map<String, dynamic>> getAnalyticsSummary(AnalyticsFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final overall = _overallAnalytics ?? _generateMockOverallAnalytics();
    
    return {
      'totalViews': overall.totalViews,
      'totalUnlocks': overall.totalUnlocks,
      'totalRevenue': overall.totalRevenue,
      'conversionRate': overall.averageConversionRate,
      'growthRate': 15.5, // Mock growth rate
      'topPerformingProperty': overall.topProperties.isNotEmpty ? overall.topProperties.first.title : 'N/A',
    };
  }

  // Generate mock property analytics
  void _generateMockPropertyAnalytics() {
    final random = Random();
    final propertyIds = ['1', '2', '3', '4', '5'];
    final propertyTitles = [
      '2BHK Apartment in Koramangala',
      '3BHK Villa in Whitefield',
      '1BHK Studio in Indiranagar',
      '4BHK House in Jayanagar',
      '2BHK Flat in Electronic City'
    ];

    for (int i = 0; i < propertyIds.length; i++) {
      final propertyId = propertyIds[i];
      final totalViews = 100 + random.nextInt(900);
      final uniqueViews = (totalViews * 0.7).round();
      final contactUnlocks = 5 + random.nextInt(25);
      final favorites = random.nextInt(50);
      
      // Generate views by date (last 30 days)
      final viewsByDate = <String, int>{};
      final unlocksByDate = <String, int>{};
      
      for (int day = 0; day < 30; day++) {
        final date = DateTime.now().subtract(Duration(days: day));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        viewsByDate[dateKey] = random.nextInt(20);
        unlocksByDate[dateKey] = random.nextInt(3);
      }

      final analytics = PropertyAnalytics(
        propertyId: propertyId,
        propertyTitle: propertyTitles[i],
        totalViews: totalViews,
        uniqueViews: uniqueViews,
        contactUnlocks: contactUnlocks,
        favorites: favorites,
        conversionRate: (contactUnlocks / totalViews * 100),
        averageRating: 3.5 + random.nextDouble() * 1.5,
        totalReviews: random.nextInt(20),
        viewsByDate: viewsByDate,
        unlocksByDate: unlocksByDate,
        viewSources: [
          ViewSource(source: 'Search', count: (totalViews * 0.4).round(), percentage: 40.0),
          ViewSource(source: 'Map', count: (totalViews * 0.3).round(), percentage: 30.0),
          ViewSource(source: 'Favorites', count: (totalViews * 0.2).round(), percentage: 20.0),
          ViewSource(source: 'Direct', count: (totalViews * 0.1).round(), percentage: 10.0),
        ],
        demographics: [
          UserDemographic(category: 'Age', value: '25-35', count: 45, percentage: 45.0),
          UserDemographic(category: 'Age', value: '35-45', count: 30, percentage: 30.0),
          UserDemographic(category: 'Age', value: '18-25', count: 25, percentage: 25.0),
          UserDemographic(category: 'Gender', value: 'Male', count: 60, percentage: 60.0),
          UserDemographic(category: 'Gender', value: 'Female', count: 40, percentage: 40.0),
        ],
        revenue: contactUnlocks * 10.0,
      );

      _propertyAnalytics[propertyId] = analytics;
    }
  }

  // Generate mock overall analytics
  OverallAnalytics _generateMockOverallAnalytics() {
    final random = Random();
    
    // Generate revenue by month (last 12 months)
    final revenueByMonth = <String, double>{};
    for (int month = 0; month < 12; month++) {
      final date = DateTime.now().subtract(Duration(days: month * 30));
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      revenueByMonth[monthKey] = 1000 + random.nextDouble() * 4000;
    }

    final analytics = OverallAnalytics(
      totalProperties: 156,
      totalUsers: 2847,
      totalViews: 15420,
      totalUnlocks: 892,
      totalRevenue: 8920.0,
      averageConversionRate: 5.8,
      propertiesByType: {
        'Apartment': 89,
        'Villa': 34,
        'Studio': 23,
        'House': 10,
      },
      usersByCity: {
        'Bangalore': 1420,
        'Mumbai': 680,
        'Delhi': 520,
        'Chennai': 227,
      },
      revenueByMonth: revenueByMonth,
      topProperties: [
        TopProperty(
          id: '1',
          title: '2BHK Apartment in Koramangala',
          image: 'https://picsum.photos/400/300?random=1',
          views: 1250,
          unlocks: 89,
          revenue: 890.0,
          rating: 4.5,
        ),
        TopProperty(
          id: '2',
          title: '3BHK Villa in Whitefield',
          image: 'https://picsum.photos/400/300?random=2',
          views: 980,
          unlocks: 67,
          revenue: 670.0,
          rating: 4.2,
        ),
        TopProperty(
          id: '3',
          title: '1BHK Studio in Indiranagar',
          image: 'https://picsum.photos/400/300?random=3',
          views: 856,
          unlocks: 54,
          revenue: 540.0,
          rating: 4.0,
        ),
      ],
      recentActivities: _generateRecentActivities(),
    );

    _overallAnalytics = analytics;
    return analytics;
  }

  // Generate recent activities
  List<RecentActivity> _generateRecentActivities() {
    final activities = <RecentActivity>[];
    final random = Random();
    
    final activityTypes = ['view', 'unlock', 'favorite', 'review', 'property_added'];
    final userNames = ['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Wilson', 'David Brown'];
    final propertyTitles = [
      '2BHK Apartment in Koramangala',
      '3BHK Villa in Whitefield',
      '1BHK Studio in Indiranagar',
    ];

    for (int i = 0; i < 20; i++) {
      final type = activityTypes[random.nextInt(activityTypes.length)];
      final userName = userNames[random.nextInt(userNames.length)];
      final propertyTitle = propertyTitles[random.nextInt(propertyTitles.length)];
      
      String description;
      switch (type) {
        case 'view':
          description = '$userName viewed $propertyTitle';
          break;
        case 'unlock':
          description = '$userName unlocked contact for $propertyTitle';
          break;
        case 'favorite':
          description = '$userName added $propertyTitle to favorites';
          break;
        case 'review':
          description = '$userName left a review for $propertyTitle';
          break;
        case 'property_added':
          description = '$userName added a new property: $propertyTitle';
          break;
        default:
          description = '$userName performed an action on $propertyTitle';
      }

      final activity = RecentActivity(
        id: 'activity_$i',
        type: type,
        description: description,
        userId: 'user_${random.nextInt(100)}',
        userName: userName,
        propertyId: '${random.nextInt(5) + 1}',
        propertyTitle: propertyTitle,
        timestamp: DateTime.now().subtract(Duration(hours: random.nextInt(72))),
        metadata: {
          'amount': type == 'unlock' ? 10.0 : null,
          'rating': type == 'review' ? (3 + random.nextDouble() * 2) : null,
        },
      );

      activities.add(activity);
    }

    // Sort by timestamp (newest first)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return activities;
  }

  // Export analytics data
  Future<Map<String, dynamic>> exportAnalyticsData(AnalyticsFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final overall = await getOverallAnalytics(filter);
    final properties = _propertyAnalytics.values.toList();
    
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'filter': {
        'timeRange': filter.timeRange.toString(),
        'startDate': filter.startDate?.toIso8601String(),
        'endDate': filter.endDate?.toIso8601String(),
      },
      'overallAnalytics': overall.toJson(),
      'propertyAnalytics': properties.map((p) => p.toJson()).toList(),
    };
  }

  // Get performance insights
  Future<List<Map<String, dynamic>>> getPerformanceInsights(AnalyticsFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      {
        'type': 'success',
        'title': 'High Conversion Rate',
        'description': 'Your properties have a 5.8% conversion rate, which is above average.',
        'action': 'Keep up the good work!',
        'icon': 'trending_up',
      },
      {
        'type': 'warning',
        'title': 'Low Views on Some Properties',
        'description': '3 properties have received less than 50 views this month.',
        'action': 'Consider updating photos or descriptions.',
        'icon': 'visibility_off',
      },
      {
        'type': 'info',
        'title': 'Peak Activity Time',
        'description': 'Most users view properties between 6-9 PM.',
        'action': 'Consider posting new properties during this time.',
        'icon': 'schedule',
      },
      {
        'type': 'success',
        'title': 'Positive Reviews',
        'description': 'Your average rating is 4.2/5 across all properties.',
        'action': 'Maintain quality to keep ratings high.',
        'icon': 'star',
      },
    ];
  }
}