import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/models/review_model.dart';
import '../../../core/services/review_service.dart';
import '../../../core/theme/app_theme.dart';

class PropertyReviewsWidget extends StatefulWidget {
  final String propertyId;

  const PropertyReviewsWidget({
    super.key,
    required this.propertyId,
  });

  @override
  State<PropertyReviewsWidget> createState() => _PropertyReviewsWidgetState();
}

class _PropertyReviewsWidgetState extends State<PropertyReviewsWidget> {
  PropertyRating? _propertyRating;
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    
    final rating = await ReviewService.getPropertyRating(widget.propertyId);
    final reviews = await ReviewService.getPropertyReviews(widget.propertyId);
    
    setState(() {
      _propertyRating = rating;
      _reviews = reviews;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_propertyRating == null || _reviews.isEmpty) {
      return _buildNoReviewsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingSummary(),
        const SizedBox(height: 20),
        _buildReviewsList(),
        const SizedBox(height: 16),
        _buildAddReviewButton(),
      ],
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Text(
                _propertyRating!.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStarRating(_propertyRating!.averageRating),
                  const SizedBox(height: 4),
                  Text(
                    '${_propertyRating!.totalReviews} reviews',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRatingDistribution(),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() 
            ? CupertinoIcons.star_fill
            : index < rating 
              ? CupertinoIcons.star_lefthalf_fill
              : CupertinoIcons.star,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildRatingDistribution() {
    return Column(
      children: List.generate(5, (index) {
        int star = 5 - index;
        int count = _propertyRating!.ratingDistribution[star] ?? 0;
        double percentage = _propertyRating!.totalReviews > 0 
          ? count / _propertyRating!.totalReviews 
          : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text('$star'),
              const SizedBox(width: 8),
              Icon(CupertinoIcons.star_fill, size: 12, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...(_reviews.take(3).map((review) => _buildReviewCard(review))),
        if (_reviews.length > 3)
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showAllReviews(),
            child: const Text('View all reviews'),
          ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (review.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            color: AppTheme.secondaryColor,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        _buildStarRating(review.rating),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(review.photos[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoReviewsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.star,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to review this property',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          _buildAddReviewButton(),
        ],
      ),
    );
  }

  Widget _buildAddReviewButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: () => _showAddReviewDialog(),
        child: const Text('Write a Review'),
      ),
    );
  }

  void _showAllReviews() {
    // Navigate to full reviews screen
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => AllReviewsScreen(
          propertyId: widget.propertyId,
          propertyRating: _propertyRating!,
        ),
      ),
    );
  }

  void _showAddReviewDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddReviewDialog(
        propertyId: widget.propertyId,
        onReviewAdded: _loadReviews,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}

// Placeholder screens - to be implemented
class AllReviewsScreen extends StatelessWidget {
  final String propertyId;
  final PropertyRating propertyRating;

  const AllReviewsScreen({
    super.key,
    required this.propertyId,
    required this.propertyRating,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('All Reviews'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PropertyReviewsWidget(propertyId: propertyId),
        ),
      ),
    );
  }
}

class AddReviewDialog extends StatefulWidget {
  final String propertyId;
  final VoidCallback onReviewAdded;

  const AddReviewDialog({
    super.key,
    required this.propertyId,
    required this.onReviewAdded,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('Write a Review'),
      message: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _rating = index + 1.0),
                child: Icon(
                  index < _rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _commentController,
            placeholder: 'Share your experience...',
            maxLines: 3,
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting 
            ? const CupertinoActivityIndicator()
            : const Text('Submit Review'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      propertyId: widget.propertyId,
      userId: 'current_user_id', // TODO: Get from auth service
      userName: 'Current User', // TODO: Get from auth service
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await ReviewService.addReview(review);

    if (mounted) {
      Navigator.of(context).pop();
      
      if (success) {
        widget.onReviewAdded();
        // Show success message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Review Submitted'),
            content: const Text('Thank you for your feedback!'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Show error message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to submit review. Please try again.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}