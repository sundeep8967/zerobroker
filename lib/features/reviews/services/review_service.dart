import 'dart:math';
import '../models/review_model.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final Map<String, List<PropertyReview>> _propertyReviews = {};
  final Map<String, PropertyReview> _userReviews = {};

  // Initialize with mock data
  void initializeMockData() {
    final mockReviews = _generateMockReviews();
    
    for (final review in mockReviews) {
      _propertyReviews.putIfAbsent(review.propertyId, () => []).add(review);
    }
  }

  // Get reviews for a property
  Future<List<PropertyReview>> getPropertyReviews(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return _propertyReviews[propertyId] ?? [];
  }

  // Get review summary for a property
  Future<ReviewSummary> getPropertyReviewSummary(String propertyId) async {
    final reviews = await getPropertyReviews(propertyId);
    return ReviewSummary.fromReviews(reviews);
  }

  // Add a new review
  Future<bool> addReview(PropertyReview review) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    
    try {
      _propertyReviews.putIfAbsent(review.propertyId, () => []).add(review);
      _userReviews[review.userId] = review;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update a review
  Future<bool> updateReview(PropertyReview review) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      final propertyReviews = _propertyReviews[review.propertyId] ?? [];
      final index = propertyReviews.indexWhere((r) => r.id == review.id);
      
      if (index != -1) {
        propertyReviews[index] = review;
        _userReviews[review.userId] = review;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String reviewId, String propertyId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    try {
      final propertyReviews = _propertyReviews[propertyId] ?? [];
      propertyReviews.removeWhere((r) => r.id == reviewId);
      _userReviews.remove(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Mark review as helpful
  Future<bool> markReviewHelpful(String reviewId, String propertyId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      final propertyReviews = _propertyReviews[propertyId] ?? [];
      final reviewIndex = propertyReviews.indexWhere((r) => r.id == reviewId);
      
      if (reviewIndex != -1) {
        final review = propertyReviews[reviewIndex];
        final helpfulUserIds = List<String>.from(review.helpfulUserIds);
        
        if (helpfulUserIds.contains(userId)) {
          helpfulUserIds.remove(userId);
        } else {
          helpfulUserIds.add(userId);
        }
        
        propertyReviews[reviewIndex] = review.copyWith(helpfulUserIds: helpfulUserIds);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user's review for a property
  Future<PropertyReview?> getUserReview(String propertyId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final propertyReviews = _propertyReviews[propertyId] ?? [];
    try {
      return propertyReviews.firstWhere((r) => r.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Filter reviews
  List<PropertyReview> filterReviews(List<PropertyReview> reviews, ReviewFilter filter) {
    var filteredReviews = reviews.where((review) => filter.matches(review)).toList();
    
    // Sort reviews
    switch (filter.sortBy) {
      case 'newest':
        filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filteredReviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        filteredReviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        filteredReviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'helpful':
        filteredReviews.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        break;
      default:
        filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return filteredReviews;
  }

  // Generate mock reviews for testing
  List<PropertyReview> _generateMockReviews() {
    final random = Random();
    final reviews = <PropertyReview>[];
    
    final propertyIds = ['1', '2', '3', '4', '5'];
    final userNames = ['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Wilson', 'David Brown', 'Lisa Davis', 'Tom Anderson', 'Emily Taylor'];
    final reviewTitles = [
      'Great property!',
      'Excellent location',
      'Good value for money',
      'Nice amenities',
      'Spacious and clean',
      'Perfect for families',
      'Well maintained',
      'Convenient location',
      'Beautiful view',
      'Peaceful neighborhood'
    ];
    final reviewComments = [
      'This property exceeded my expectations. The location is perfect and the amenities are top-notch.',
      'I really enjoyed staying here. The space is well-designed and very comfortable.',
      'Great value for the price. The property is clean and well-maintained.',
      'The neighborhood is quiet and safe. Perfect for families with children.',
      'Excellent property with all modern amenities. Highly recommended!',
      'The property is exactly as described. Clean, spacious, and in a great location.',
      'I had a wonderful experience. The property is beautiful and the area is very convenient.',
      'This place is perfect for anyone looking for comfort and convenience.',
      'Amazing property with great facilities. The view is absolutely stunning.',
      'Very satisfied with this property. Everything was clean and well-organized.'
    ];

    for (int i = 0; i < 50; i++) {
      final propertyId = propertyIds[random.nextInt(propertyIds.length)];
      final userName = userNames[random.nextInt(userNames.length)];
      final title = reviewTitles[random.nextInt(reviewTitles.length)];
      final comment = reviewComments[random.nextInt(reviewComments.length)];
      final rating = (random.nextInt(5) + 1).toDouble();
      final createdAt = DateTime.now().subtract(Duration(days: random.nextInt(365)));
      
      final aspectRatings = <String, double>{};
      if (random.nextBool()) {
        aspectRatings['Location'] = (random.nextInt(5) + 1).toDouble();
        aspectRatings['Cleanliness'] = (random.nextInt(5) + 1).toDouble();
        aspectRatings['Value'] = (random.nextInt(5) + 1).toDouble();
        aspectRatings['Amenities'] = (random.nextInt(5) + 1).toDouble();
      }

      final review = PropertyReview(
        id: 'review_$i',
        propertyId: propertyId,
        userId: 'user_$i',
        userName: userName,
        userAvatar: 'https://ui-avatars.com/api/?name=${userName.replaceAll(' ', '+')}&background=random',
        rating: rating,
        title: title,
        comment: comment,
        createdAt: createdAt,
        images: random.nextBool() ? ['https://picsum.photos/400/300?random=$i'] : [],
        helpfulUserIds: List.generate(random.nextInt(10), (index) => 'user_helpful_$index'),
        type: ReviewType.values[random.nextInt(ReviewType.values.length)],
        aspectRatings: aspectRatings,
      );
      
      reviews.add(review);
    }
    
    return reviews;
  }
}