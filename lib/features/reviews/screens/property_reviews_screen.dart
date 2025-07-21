import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/review_model.dart';
import '../providers/review_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'add_review_screen.dart';
import '../widgets/review_card.dart';
import '../widgets/review_summary_widget.dart';
import '../widgets/review_filter_widget.dart';

class PropertyReviewsScreen extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const PropertyReviewsScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<PropertyReviewsScreen> createState() => _PropertyReviewsScreenState();
}

class _PropertyReviewsScreenState extends State<PropertyReviewsScreen> {
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final reviewProvider = context.read<ReviewProvider>();
    await reviewProvider.loadPropertyReviews(widget.propertyId);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: Text('Reviews - ${widget.propertyTitle}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(() => _showFilters = !_showFilters),
              child: Icon(
                _showFilters ? CupertinoIcons.xmark : CupertinoIcons.slider_horizontal_3,
                color: CupertinoColors.systemBlue,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _navigateToAddReview,
              child: const Icon(
                CupertinoIcons.add,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Consumer<ReviewProvider>(
          builder: (context, reviewProvider, child) {
            if (reviewProvider.isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(radius: 20),
              );
            }

            if (reviewProvider.error != null) {
              return _buildErrorState(reviewProvider.error!);
            }

            final summary = reviewProvider.getPropertyReviewSummary(widget.propertyId);
            final reviews = reviewProvider.getFilteredReviews(widget.propertyId);

            return CustomScrollView(
              slivers: [
                // Review Summary
                if (summary != null)
                  SliverToBoxAdapter(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 300),
                      child: ReviewSummaryWidget(summary: summary),
                    ),
                  ),

                // Filter Widget
                if (_showFilters)
                  SliverToBoxAdapter(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: ReviewFilterWidget(
                        filter: reviewProvider.currentFilter,
                        onFilterChanged: (filter) {
                          reviewProvider.updateFilter(filter);
                        },
                        onClearFilter: () {
                          reviewProvider.clearFilter();
                        },
                      ),
                    ),
                  ),

                // Reviews Header
                SliverToBoxAdapter(
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: _buildReviewsHeader(reviews.length),
                  ),
                ),

                // Reviews List
                if (reviews.isEmpty)
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildEmptyState(),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return FadeInUp(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: ReviewCard(
                            review: reviews[index],
                            onHelpfulPressed: () => _markReviewHelpful(reviews[index]),
                            onEditPressed: () => _editReview(reviews[index]),
                            onDeletePressed: () => _deleteReview(reviews[index]),
                          ),
                        );
                      },
                      childCount: reviews.length,
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewsHeader(int reviewCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Reviews ($reviewCount)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          Consumer<ReviewProvider>(
            builder: (context, reviewProvider, child) {
              final filter = reviewProvider.currentFilter;
              final hasActiveFilter = filter.type != null ||
                  filter.minRating != null ||
                  filter.maxRating != null ||
                  filter.hasImages != null ||
                  filter.sortBy != 'newest';

              if (hasActiveFilter) {
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => reviewProvider.clearFilter(),
                  child: const Text(
                    'Clear Filters',
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
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
        children: [
          const Icon(
            CupertinoIcons.chat_bubble_text,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to share your experience with this property.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _navigateToAddReview,
            child: const Text('Write a Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
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
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Reviews',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: _loadReviews,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddReview() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddReviewScreen(
          propertyId: widget.propertyId,
          propertyTitle: widget.propertyTitle,
        ),
      ),
    );
  }

  void _editReview(PropertyReview review) {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? 'demo_user';

    if (review.userId == currentUserId) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => AddReviewScreen(
            propertyId: widget.propertyId,
            propertyTitle: widget.propertyTitle,
            existingReview: review,
          ),
        ),
      );
    }
  }

  void _deleteReview(PropertyReview review) {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? 'demo_user';

    if (review.userId == currentUserId) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Delete Review'),
          content: const Text('Are you sure you want to delete this review?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.pop(context);
                final reviewProvider = context.read<ReviewProvider>();
                final success = await reviewProvider.deleteReview(
                  review.id,
                  widget.propertyId,
                  currentUserId,
                );

                if (success && mounted) {
                  _showSnackBar('Review deleted successfully');
                } else if (mounted) {
                  _showSnackBar('Failed to delete review');
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  void _markReviewHelpful(PropertyReview review) async {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? 'demo_user';
    final reviewProvider = context.read<ReviewProvider>();

    final success = await reviewProvider.markReviewHelpful(
      review.id,
      widget.propertyId,
      currentUserId,
    );

    if (success && mounted) {
      final isHelpful = review.helpfulUserIds.contains(currentUserId);
      _showSnackBar(isHelpful ? 'Marked as helpful' : 'Removed helpful mark');
    } else if (mounted) {
      _showSnackBar('Failed to update helpful status');
    }
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