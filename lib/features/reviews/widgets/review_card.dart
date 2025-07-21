import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final PropertyReview review;
  final VoidCallback? onHelpfulPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const ReviewCard({
    super.key,
    required this.review,
    this.onHelpfulPressed,
    this.onEditPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Header with user info and rating
          _buildHeader(),
          
          // Review title
          if (review.title.isNotEmpty) _buildTitle(),
          
          // Review comment
          _buildComment(),
          
          // Aspect ratings
          if (review.aspectRatings.isNotEmpty) _buildAspectRatings(),
          
          // Review images
          if (review.images.isNotEmpty) _buildImages(),
          
          // Footer with actions
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: CupertinoColors.systemGrey5,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: review.userAvatar,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: CupertinoColors.systemGrey5,
                  child: const Icon(
                    CupertinoIcons.person,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: CupertinoColors.systemGrey5,
                  child: const Icon(
                    CupertinoIcons.person,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // User info and rating
          Expanded(
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
                    const SizedBox(width: 8),
                    _buildReviewTypeBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStarRating(review.rating),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions menu
          if (onEditPressed != null || onDeletePressed != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showActionsMenu(context),
              child: const Icon(
                CupertinoIcons.ellipsis,
                color: CupertinoColors.systemGrey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewTypeBadge() {
    String typeText;
    Color backgroundColor;
    
    switch (review.type) {
      case ReviewType.tenant:
        typeText = 'Tenant';
        backgroundColor = CupertinoColors.systemBlue;
        break;
      case ReviewType.buyer:
        typeText = 'Buyer';
        backgroundColor = CupertinoColors.systemGreen;
        break;
      case ReviewType.visitor:
        typeText = 'Visitor';
        backgroundColor = CupertinoColors.systemOrange;
        break;
      default:
        typeText = 'General';
        backgroundColor = CupertinoColors.systemGrey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        typeText,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.white,
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
          color: CupertinoColors.systemYellow,
          size: 16,
        );
      }),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        review.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label,
        ),
      ),
    );
  }

  Widget _buildComment() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, review.title.isNotEmpty ? 8 : 0, 16, 16),
      child: Text(
        review.comment,
        style: const TextStyle(
          fontSize: 14,
          color: CupertinoColors.label,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAspectRatings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Ratings',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          ...review.aspectRatings.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.label,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < entry.value ? CupertinoIcons.star_fill : CupertinoIcons.star,
                        color: CupertinoColors.systemYellow,
                        size: 12,
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

  Widget _buildImages() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: review.images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: CupertinoColors.systemGrey5,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: review.images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: CupertinoColors.systemGrey5,
                  child: const Icon(
                    CupertinoIcons.photo,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: CupertinoColors.systemGrey5,
                  child: const Icon(
                    CupertinoIcons.photo,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Helpful button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onHelpfulPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  review.isHelpful ? CupertinoIcons.hand_thumbsup_fill : CupertinoIcons.hand_thumbsup,
                  color: review.isHelpful ? CupertinoColors.systemBlue : CupertinoColors.systemGrey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Helpful${review.helpfulCount > 0 ? ' (${review.helpfulCount})' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: review.isHelpful ? CupertinoColors.systemBlue : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Share button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _shareReview(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.share,
                  color: CupertinoColors.systemGrey,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActionsMenu(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (modalContext) => CupertinoActionSheet(
        actions: [
          if (onEditPressed != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(modalContext);
                onEditPressed!();
              },
              child: const Text('Edit Review'),
            ),
          if (onDeletePressed != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(modalContext);
                onDeletePressed!();
              },
              isDestructiveAction: true,
              child: const Text('Delete Review'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(modalContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _shareReview() {
    // Implement share functionality
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
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}