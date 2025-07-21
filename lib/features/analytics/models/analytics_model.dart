class PropertyAnalytics {
  final String propertyId;
  final String propertyTitle;
  final int totalViews;
  final int uniqueViews;
  final int contactUnlocks;
  final int favorites;
  final double conversionRate;
  final double averageRating;
  final int totalReviews;
  final Map<String, int> viewsByDate;
  final Map<String, int> unlocksByDate;
  final List<ViewSource> viewSources;
  final List<UserDemographic> demographics;
  final double revenue;

  const PropertyAnalytics({
    required this.propertyId,
    required this.propertyTitle,
    required this.totalViews,
    required this.uniqueViews,
    required this.contactUnlocks,
    required this.favorites,
    required this.conversionRate,
    required this.averageRating,
    required this.totalReviews,
    required this.viewsByDate,
    required this.unlocksByDate,
    required this.viewSources,
    required this.demographics,
    required this.revenue,
  });

  factory PropertyAnalytics.fromJson(Map<String, dynamic> json) {
    return PropertyAnalytics(
      propertyId: json['propertyId'] ?? '',
      propertyTitle: json['propertyTitle'] ?? '',
      totalViews: json['totalViews'] ?? 0,
      uniqueViews: json['uniqueViews'] ?? 0,
      contactUnlocks: json['contactUnlocks'] ?? 0,
      favorites: json['favorites'] ?? 0,
      conversionRate: (json['conversionRate'] ?? 0.0).toDouble(),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      viewsByDate: Map<String, int>.from(json['viewsByDate'] ?? {}),
      unlocksByDate: Map<String, int>.from(json['unlocksByDate'] ?? {}),
      viewSources: (json['viewSources'] as List<dynamic>?)
          ?.map((e) => ViewSource.fromJson(e))
          .toList() ?? [],
      demographics: (json['demographics'] as List<dynamic>?)
          ?.map((e) => UserDemographic.fromJson(e))
          .toList() ?? [],
      revenue: (json['revenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'totalViews': totalViews,
      'uniqueViews': uniqueViews,
      'contactUnlocks': contactUnlocks,
      'favorites': favorites,
      'conversionRate': conversionRate,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'viewsByDate': viewsByDate,
      'unlocksByDate': unlocksByDate,
      'viewSources': viewSources.map((e) => e.toJson()).toList(),
      'demographics': demographics.map((e) => e.toJson()).toList(),
      'revenue': revenue,
    };
  }
}

class ViewSource {
  final String source;
  final int count;
  final double percentage;

  const ViewSource({
    required this.source,
    required this.count,
    required this.percentage,
  });

  factory ViewSource.fromJson(Map<String, dynamic> json) {
    return ViewSource(
      source: json['source'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'count': count,
      'percentage': percentage,
    };
  }
}

class UserDemographic {
  final String category;
  final String value;
  final int count;
  final double percentage;

  const UserDemographic({
    required this.category,
    required this.value,
    required this.count,
    required this.percentage,
  });

  factory UserDemographic.fromJson(Map<String, dynamic> json) {
    return UserDemographic(
      category: json['category'] ?? '',
      value: json['value'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'value': value,
      'count': count,
      'percentage': percentage,
    };
  }
}

class OverallAnalytics {
  final int totalProperties;
  final int totalUsers;
  final int totalViews;
  final int totalUnlocks;
  final double totalRevenue;
  final double averageConversionRate;
  final Map<String, int> propertiesByType;
  final Map<String, int> usersByCity;
  final Map<String, double> revenueByMonth;
  final List<TopProperty> topProperties;
  final List<RecentActivity> recentActivities;

  const OverallAnalytics({
    required this.totalProperties,
    required this.totalUsers,
    required this.totalViews,
    required this.totalUnlocks,
    required this.totalRevenue,
    required this.averageConversionRate,
    required this.propertiesByType,
    required this.usersByCity,
    required this.revenueByMonth,
    required this.topProperties,
    required this.recentActivities,
  });

  factory OverallAnalytics.fromJson(Map<String, dynamic> json) {
    return OverallAnalytics(
      totalProperties: json['totalProperties'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      totalUnlocks: json['totalUnlocks'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      averageConversionRate: (json['averageConversionRate'] ?? 0.0).toDouble(),
      propertiesByType: Map<String, int>.from(json['propertiesByType'] ?? {}),
      usersByCity: Map<String, int>.from(json['usersByCity'] ?? {}),
      revenueByMonth: Map<String, double>.from(json['revenueByMonth'] ?? {}),
      topProperties: (json['topProperties'] as List<dynamic>?)
          ?.map((e) => TopProperty.fromJson(e))
          .toList() ?? [],
      recentActivities: (json['recentActivities'] as List<dynamic>?)
          ?.map((e) => RecentActivity.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProperties': totalProperties,
      'totalUsers': totalUsers,
      'totalViews': totalViews,
      'totalUnlocks': totalUnlocks,
      'totalRevenue': totalRevenue,
      'averageConversionRate': averageConversionRate,
      'propertiesByType': propertiesByType,
      'usersByCity': usersByCity,
      'revenueByMonth': revenueByMonth,
      'topProperties': topProperties.map((e) => e.toJson()).toList(),
      'recentActivities': recentActivities.map((e) => e.toJson()).toList(),
    };
  }
}

class TopProperty {
  final String id;
  final String title;
  final String image;
  final int views;
  final int unlocks;
  final double revenue;
  final double rating;

  const TopProperty({
    required this.id,
    required this.title,
    required this.image,
    required this.views,
    required this.unlocks,
    required this.revenue,
    required this.rating,
  });

  factory TopProperty.fromJson(Map<String, dynamic> json) {
    return TopProperty(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      views: json['views'] ?? 0,
      unlocks: json['unlocks'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'views': views,
      'unlocks': unlocks,
      'revenue': revenue,
      'rating': rating,
    };
  }
}

class RecentActivity {
  final String id;
  final String type;
  final String description;
  final String userId;
  final String userName;
  final String propertyId;
  final String propertyTitle;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.userId,
    required this.userName,
    required this.propertyId,
    required this.propertyTitle,
    required this.timestamp,
    required this.metadata,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      propertyId: json['propertyId'] ?? '',
      propertyTitle: json['propertyTitle'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'userId': userId,
      'userName': userName,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

enum AnalyticsTimeRange {
  today,
  week,
  month,
  quarter,
  year,
  custom,
}

class AnalyticsFilter {
  final AnalyticsTimeRange timeRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? propertyType;
  final String? city;
  final List<String>? propertyIds;

  const AnalyticsFilter({
    this.timeRange = AnalyticsTimeRange.month,
    this.startDate,
    this.endDate,
    this.propertyType,
    this.city,
    this.propertyIds,
  });

  AnalyticsFilter copyWith({
    AnalyticsTimeRange? timeRange,
    DateTime? startDate,
    DateTime? endDate,
    String? propertyType,
    String? city,
    List<String>? propertyIds,
  }) {
    return AnalyticsFilter(
      timeRange: timeRange ?? this.timeRange,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      propertyType: propertyType ?? this.propertyType,
      city: city ?? this.city,
      propertyIds: propertyIds ?? this.propertyIds,
    );
  }
}