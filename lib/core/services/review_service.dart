import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _reviewsCollection = 'reviews';
  static const String _ratingsCollection = 'property_ratings';

  // Add a new review
  static Future<bool> addReview(Review review) async {
    try {
      // Add review to reviews collection
      await _firestore.collection(_reviewsCollection).doc(review.id).set(review.toJson());
      
      // Update property rating
      await _updatePropertyRating(review.propertyId);
      
      return true;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  // Get reviews for a property
  static Future<List<Review>> getPropertyReviews(String propertyId, {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting property reviews: $e');
      return [];
    }
  }

  // Get property rating summary
  static Future<PropertyRating?> getPropertyRating(String propertyId) async {
    try {
      final doc = await _firestore.collection(_ratingsCollection).doc(propertyId).get();
      
      if (doc.exists) {
        return PropertyRating.fromJson(doc.data()!);
      }
      
      return null;
    } catch (e) {
      print('Error getting property rating: $e');
      return null;
    }
  }

  // Update property rating (called when new review is added)
  static Future<void> _updatePropertyRating(String propertyId) async {
    try {
      // Get all reviews for this property
      final reviews = await getPropertyReviews(propertyId, limit: 1000);
      
      if (reviews.isEmpty) return;

      // Calculate average rating
      double totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
      double averageRating = totalRating / reviews.length;

      // Calculate rating distribution
      Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (var review in reviews) {
        int starRating = review.rating.round();
        distribution[starRating] = (distribution[starRating] ?? 0) + 1;
      }

      // Get recent reviews (last 5)
      List<Review> recentReviews = reviews.take(5).toList();

      // Create rating summary
      PropertyRating rating = PropertyRating(
        averageRating: averageRating,
        totalReviews: reviews.length,
        ratingDistribution: distribution,
        recentReviews: recentReviews,
      );

      // Save to Firestore
      await _firestore.collection(_ratingsCollection).doc(propertyId).set(rating.toJson());
    } catch (e) {
      print('Error updating property rating: $e');
    }
  }

  // Check if user has already reviewed a property
  static Future<bool> hasUserReviewed(String propertyId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user review: $e');
      return false;
    }
  }

  // Delete a review
  static Future<bool> deleteReview(String reviewId, String propertyId) async {
    try {
      await _firestore.collection(_reviewsCollection).doc(reviewId).delete();
      await _updatePropertyRating(propertyId);
      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  // Report a review
  static Future<bool> reportReview(String reviewId, String reason) async {
    try {
      await _firestore.collection('reported_reviews').add({
        'reviewId': reviewId,
        'reason': reason,
        'reportedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error reporting review: $e');
      return false;
    }
  }
}