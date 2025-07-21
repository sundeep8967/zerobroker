import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  
  Map<String, List<PropertyReview>> _propertyReviews = {};
  Map<String, ReviewSummary> _reviewSummaries = {};
  bool _isLoading = false;
  String? _error;
  ReviewFilter _currentFilter = const ReviewFilter();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ReviewFilter get currentFilter => _currentFilter;

  List<PropertyReview> getPropertyReviews(String propertyId) {
    return _propertyReviews[propertyId] ?? [];
  }

  ReviewSummary? getPropertyReviewSummary(String propertyId) {
    return _reviewSummaries[propertyId];
  }

  List<PropertyReview> getFilteredReviews(String propertyId) {
    final reviews = getPropertyReviews(propertyId);
    return _reviewService.filterReviews(reviews, _currentFilter);
  }

  // Initialize mock data
  Future<void> initializeMockData() async {
    _reviewService.initializeMockData();
  }

  // Load reviews for a property
  Future<void> loadPropertyReviews(String propertyId) async {
    _setLoading(true);
    _clearError();

    try {
      final reviews = await _reviewService.getPropertyReviews(propertyId);
      final summary = await _reviewService.getPropertyReviewSummary(propertyId);
      
      _propertyReviews[propertyId] = reviews;
      _reviewSummaries[propertyId] = summary;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load reviews: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new review
  Future<bool> addReview(PropertyReview review) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _reviewService.addReview(review);
      
      if (success) {
        // Update local cache
        _propertyReviews.putIfAbsent(review.propertyId, () => []).add(review);
        
        // Recalculate summary
        final updatedSummary = ReviewSummary.fromReviews(_propertyReviews[review.propertyId]!);
        _reviewSummaries[review.propertyId] = updatedSummary;
        
        notifyListeners();
        return true;
      } else {
        _setError('Failed to add review');
        return false;
      }
    } catch (e) {
      _setError('Failed to add review: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update a review
  Future<bool> updateReview(PropertyReview review) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _reviewService.updateReview(review);
      
      if (success) {
        // Update local cache
        final propertyReviews = _propertyReviews[review.propertyId] ?? [];
        final index = propertyReviews.indexWhere((r) => r.id == review.id);
        
        if (index != -1) {
          propertyReviews[index] = review;
          
          // Recalculate summary
          final updatedSummary = ReviewSummary.fromReviews(propertyReviews);
          _reviewSummaries[review.propertyId] = updatedSummary;
          
          notifyListeners();
        }
        return true;
      } else {
        _setError('Failed to update review');
        return false;
      }
    } catch (e) {
      _setError('Failed to update review: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a review
  Future<bool> deleteReview(String reviewId, String propertyId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _reviewService.deleteReview(reviewId, propertyId, userId);
      
      if (success) {
        // Update local cache
        final propertyReviews = _propertyReviews[propertyId] ?? [];
        propertyReviews.removeWhere((r) => r.id == reviewId);
        
        // Recalculate summary
        final updatedSummary = ReviewSummary.fromReviews(propertyReviews);
        _reviewSummaries[propertyId] = updatedSummary;
        
        notifyListeners();
        return true;
      } else {
        _setError('Failed to delete review');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete review: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark review as helpful
  Future<bool> markReviewHelpful(String reviewId, String propertyId, String userId) async {
    try {
      final success = await _reviewService.markReviewHelpful(reviewId, propertyId, userId);
      
      if (success) {
        // Update local cache
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
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to mark review as helpful: ${e.toString()}');
      return false;
    }
  }

  // Get user's review for a property
  Future<PropertyReview?> getUserReview(String propertyId, String userId) async {
    try {
      return await _reviewService.getUserReview(propertyId, userId);
    } catch (e) {
      _setError('Failed to get user review: ${e.toString()}');
      return null;
    }
  }

  // Update filter
  void updateFilter(ReviewFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Clear filter
  void clearFilter() {
    _currentFilter = const ReviewFilter();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear all data
  void clear() {
    _propertyReviews.clear();
    _reviewSummaries.clear();
    _isLoading = false;
    _error = null;
    _currentFilter = const ReviewFilter();
    notifyListeners();
  }

  // Get review statistics
  Map<String, dynamic> getReviewStatistics(String propertyId) {
    final summary = _reviewSummaries[propertyId];
    if (summary == null) {
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': <int, int>{},
        'aspectAverages': <String, double>{},
      };
    }

    return {
      'averageRating': summary.averageRating,
      'totalReviews': summary.totalReviews,
      'ratingDistribution': summary.ratingDistribution,
      'aspectAverages': summary.aspectAverages,
    };
  }

  // Get review trends (for analytics)
  Map<String, dynamic> getReviewTrends(String propertyId) {
    final reviews = _propertyReviews[propertyId] ?? [];
    if (reviews.isEmpty) return {};

    // Group reviews by month
    final monthlyReviews = <String, List<PropertyReview>>{};
    for (final review in reviews) {
      final monthKey = '${review.createdAt.year}-${review.createdAt.month.toString().padLeft(2, '0')}';
      monthlyReviews.putIfAbsent(monthKey, () => []).add(review);
    }

    // Calculate monthly averages
    final monthlyAverages = <String, double>{};
    monthlyReviews.forEach((month, monthReviews) {
      final totalRating = monthReviews.fold<double>(0.0, (sum, review) => sum + review.rating);
      monthlyAverages[month] = totalRating / monthReviews.length;
    });

    return {
      'monthlyReviews': monthlyReviews.map((key, value) => MapEntry(key, value.length)),
      'monthlyAverages': monthlyAverages,
      'totalReviews': reviews.length,
      'averageRating': reviews.fold<double>(0.0, (sum, review) => sum + review.rating) / reviews.length,
    };
  }
}