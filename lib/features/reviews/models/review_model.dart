class PropertyReview {
  final String id;
  final String propertyId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String title;
  final String comment;
  final DateTime createdAt;
  final List<String> images;
  final List<String> helpfulUserIds;
  final ReviewType type;
  final Map<String, double> aspectRatings;

  const PropertyReview({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
    this.images = const [],
    this.helpfulUserIds = const [],
    this.type = ReviewType.general,
    this.aspectRatings = const {},
  });

  factory PropertyReview.fromJson(Map<String, dynamic> json) {
    return PropertyReview(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      images: List<String>.from(json['images'] ?? []),
      helpfulUserIds: List<String>.from(json['helpfulUserIds'] ?? []),
      type: ReviewType.values.firstWhere(
        (e) => e.toString() == 'ReviewType.${json['type']}',
        orElse: () => ReviewType.general,
      ),
      aspectRatings: Map<String, double>.from(json['aspectRatings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'title': title,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
      'helpfulUserIds': helpfulUserIds,
      'type': type.toString().split('.').last,
      'aspectRatings': aspectRatings,
    };
  }

  PropertyReview copyWith({
    String? id,
    String? propertyId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? title,
    String? comment,
    DateTime? createdAt,
    List<String>? images,
    List<String>? helpfulUserIds,
    ReviewType? type,
    Map<String, double>? aspectRatings,
  }) {
    return PropertyReview(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
      helpfulUserIds: helpfulUserIds ?? this.helpfulUserIds,
      type: type ?? this.type,
      aspectRatings: aspectRatings ?? this.aspectRatings,
    );
  }

  bool get isHelpful => helpfulUserIds.isNotEmpty;
  int get helpfulCount => helpfulUserIds.length;
}

enum ReviewType {
  general,
  tenant,
  buyer,
  visitor,
}

class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final Map<String, double> aspectAverages;
  final List<PropertyReview> recentReviews;

  const ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.aspectAverages,
    required this.recentReviews,
  });

  factory ReviewSummary.fromReviews(List<PropertyReview> reviews) {
    if (reviews.isEmpty) {
      return const ReviewSummary(
        averageRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {},
        aspectAverages: {},
        recentReviews: [],
      );
    }

    // Calculate average rating
    final totalRating = reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
    final averageRating = totalRating / reviews.length;

    // Calculate rating distribution
    final ratingDistribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i] = reviews.where((r) => r.rating.round() == i).length;
    }

    // Calculate aspect averages
    final aspectAverages = <String, double>{};
    final aspectCounts = <String, int>{};
    
    for (final review in reviews) {
      review.aspectRatings.forEach((aspect, rating) {
        aspectAverages[aspect] = (aspectAverages[aspect] ?? 0.0) + rating;
        aspectCounts[aspect] = (aspectCounts[aspect] ?? 0) + 1;
      });
    }
    
    aspectAverages.forEach((aspect, total) {
      aspectAverages[aspect] = total / aspectCounts[aspect]!;
    });

    // Get recent reviews (last 5)
    final sortedReviews = List<PropertyReview>.from(reviews)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentReviews = sortedReviews.take(5).toList();

    return ReviewSummary(
      averageRating: averageRating,
      totalReviews: reviews.length,
      ratingDistribution: ratingDistribution,
      aspectAverages: aspectAverages,
      recentReviews: recentReviews,
    );
  }
}

class ReviewFilter {
  final ReviewType? type;
  final double? minRating;
  final double? maxRating;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? hasImages;
  final String? sortBy; // 'newest', 'oldest', 'highest', 'lowest', 'helpful'

  const ReviewFilter({
    this.type,
    this.minRating,
    this.maxRating,
    this.startDate,
    this.endDate,
    this.hasImages,
    this.sortBy = 'newest',
  });

  ReviewFilter copyWith({
    ReviewType? type,
    double? minRating,
    double? maxRating,
    DateTime? startDate,
    DateTime? endDate,
    bool? hasImages,
    String? sortBy,
  }) {
    return ReviewFilter(
      type: type ?? this.type,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      hasImages: hasImages ?? this.hasImages,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool matches(PropertyReview review) {
    if (type != null && review.type != type) return false;
    if (minRating != null && review.rating < minRating!) return false;
    if (maxRating != null && review.rating > maxRating!) return false;
    if (startDate != null && review.createdAt.isBefore(startDate!)) return false;
    if (endDate != null && review.createdAt.isAfter(endDate!)) return false;
    if (hasImages != null && (review.images.isNotEmpty) != hasImages!) return false;
    
    return true;
  }
}