import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../reviews/models/review_model.dart';
import '../../reviews/providers/review_provider.dart';
import '../../auth/providers/auth_provider.dart';

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
  ReviewSummary? _reviewSummary;
  List<PropertyReview> _reviews = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    
    final reviewProvider = context.read<ReviewProvider>();
    await reviewProvider.loadPropertyReviews(widget.propertyId);
    
    setState(() {
      _reviewSummary = reviewProvider.getPropertyReviewSummary(widget.propertyId);
      _reviews = reviewProvider.getPropertyReviews(widget.propertyId);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviews Header
        _buildReviewsHeader(),
        
        // Reviews List
        if (_reviews.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._reviews.take(3).map((review) => _buildReviewCard(review)),
          if (_reviews.length > 3) _buildViewAllButton(),
        ] else
          _buildNoReviewsState(),
        
        const SizedBox(height: 16),
        _buildAddReviewButton(),
      ],
    );
  }

  Widget _buildReviewsHeader() {
    final averageRating = _reviewSummary?.averageRating ?? 0.0;
    final totalReviews = _reviewSummary?.totalReviews ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < averageRating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                    color: CupertinoColors.systemYellow,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews review${totalReviews != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
          const Spacer(),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showAddReviewDialog,
            child: const Icon(
              CupertinoIcons.add_circled,
              color: CupertinoColors.systemBlue,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(PropertyReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                    color: CupertinoColors.systemYellow,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          if (review.title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.label,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(review.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReviewsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(
            CupertinoIcons.chat_bubble_text,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Be the first to share your experience with this property.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return CupertinoButton(
      onPressed: () {
        // Navigate to full reviews screen
      },
      child: Text('View all ${_reviews.length} reviews'),
    );
  }

  Widget _buildAddReviewButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: _showAddReviewDialog,
        child: const Text('Write a Review'),
      ),
    );
  }

  void _showAddReviewDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Write a Review'),
        message: Column(
          children: [
            const SizedBox(height: 16),
            // Rating selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                      color: CupertinoColors.systemYellow,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Title input
            CupertinoTextField(
              controller: _titleController,
              placeholder: 'Review title...',
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            // Comment input
            CupertinoTextField(
              controller: _commentController,
              placeholder: 'Share your experience...',
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: _isSubmitting ? () {} : () => _submitReview(),
            child: _isSubmitting 
              ? const CupertinoActivityIndicator()
              : const Text('Submit Review'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final reviewProvider = context.read<ReviewProvider>();
      
      final review = PropertyReview(
        id: 'review_${DateTime.now().millisecondsSinceEpoch}',
        propertyId: widget.propertyId,
        userId: authProvider.currentUser?.id ?? 'demo_user',
        userName: authProvider.currentUser?.name ?? 'Demo User',
        userAvatar: authProvider.currentUser?.profilePicture ?? '',
        rating: _rating,
        title: _titleController.text.trim(),
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      final success = await reviewProvider.addReview(review);
      
      if (success && mounted) {
        Navigator.pop(context);
        _titleController.clear();
        _commentController.clear();
        _rating = 5.0;
        _loadReviews();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}