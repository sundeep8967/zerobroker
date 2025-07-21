import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/review_model.dart';
import '../providers/review_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AddReviewScreen extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;
  final PropertyReview? existingReview;

  const AddReviewScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    this.existingReview,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  double _rating = 5.0;
  ReviewType _selectedType = ReviewType.general;
  bool _isSubmitting = false;
  
  final Map<String, double> _aspectRatings = {
    'Location': 5.0,
    'Cleanliness': 5.0,
    'Value': 5.0,
    'Amenities': 5.0,
  };

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _populateExistingReview();
    }
  }

  void _populateExistingReview() {
    final review = widget.existingReview!;
    _titleController.text = review.title;
    _commentController.text = review.comment;
    _rating = review.rating;
    _selectedType = review.type;
    
    // Update aspect ratings if they exist
    review.aspectRatings.forEach((aspect, rating) {
      if (_aspectRatings.containsKey(aspect)) {
        _aspectRatings[aspect] = rating;
      }
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
    final isEditing = widget.existingReview != null;
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: Text(isEditing ? 'Edit Review' : 'Write Review'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const CupertinoActivityIndicator()
              : Text(isEditing ? 'Update' : 'Submit'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Property Info
            FadeInDown(
              duration: const Duration(milliseconds: 300),
              child: _buildPropertyInfo(),
            ),
            
            const SizedBox(height: 20),
            
            // Overall Rating
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: _buildOverallRating(),
            ),
            
            const SizedBox(height: 20),
            
            // Review Type
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: _buildReviewType(),
            ),
            
            const SizedBox(height: 20),
            
            // Aspect Ratings
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: _buildAspectRatings(),
            ),
            
            const SizedBox(height: 20),
            
            // Review Title
            FadeInDown(
              duration: const Duration(milliseconds: 700),
              child: _buildReviewTitle(),
            ),
            
            const SizedBox(height: 20),
            
            // Review Comment
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: _buildReviewComment(),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyInfo() {
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.home,
              color: CupertinoColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Writing review for:',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.propertyTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRating() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1.0),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        index < _rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
                        color: CupertinoColors.systemYellow,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              Text(
                '${_rating.toInt()}/5',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewType() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoSlidingSegmentedControl<ReviewType>(
            groupValue: _selectedType,
            onValueChanged: (value) => setState(() => _selectedType = value!),
            children: const {
              ReviewType.general: Text('General'),
              ReviewType.tenant: Text('Tenant'),
              ReviewType.buyer: Text('Buyer'),
              ReviewType.visitor: Text('Visitor'),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAspectRatings() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Ratings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),
          ..._aspectRatings.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.label,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _aspectRatings[entry.key] = index + 1.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            index < entry.value ? CupertinoIcons.star_fill : CupertinoIcons.star,
                            color: CupertinoColors.systemYellow,
                            size: 20,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewTitle() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Title',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _titleController,
            placeholder: 'Give your review a title...',
            maxLines: 1,
            decoration: BoxDecoration(
              color: CupertinoColors.systemFill,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewComment() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _commentController,
            placeholder: 'Share your experience with this property...',
            maxLines: 6,
            decoration: BoxDecoration(
              color: CupertinoColors.systemFill,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_titleController.text.trim().isEmpty || _commentController.text.trim().isEmpty) {
      _showAlert('Please fill in all required fields');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final reviewProvider = context.read<ReviewProvider>();
      final user = authProvider.currentUser;

      final review = PropertyReview(
        id: widget.existingReview?.id ?? 'review_${DateTime.now().millisecondsSinceEpoch}',
        propertyId: widget.propertyId,
        userId: user?.id ?? 'demo_user',
        userName: user?.name ?? 'Demo User',
        userAvatar: user?.profilePicture ?? 'https://ui-avatars.com/api/?name=Demo+User&background=random',
        rating: _rating,
        title: _titleController.text.trim(),
        comment: _commentController.text.trim(),
        createdAt: widget.existingReview?.createdAt ?? DateTime.now(),
        type: _selectedType,
        aspectRatings: Map.from(_aspectRatings),
        helpfulUserIds: widget.existingReview?.helpfulUserIds ?? [],
      );

      bool success;
      if (widget.existingReview != null) {
        success = await reviewProvider.updateReview(review);
      } else {
        success = await reviewProvider.addReview(review);
      }

      if (success && mounted) {
        Navigator.pop(context);
        _showSnackBar(widget.existingReview != null 
            ? 'Review updated successfully' 
            : 'Review submitted successfully');
      } else if (mounted) {
        _showAlert('Failed to submit review. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showAlert('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Notice'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}