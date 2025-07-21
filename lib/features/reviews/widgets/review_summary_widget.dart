import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/review_model.dart';

class ReviewSummaryWidget extends StatelessWidget {
  final ReviewSummary summary;

  const ReviewSummaryWidget({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          // Overall rating section
          _buildOverallRating(),
          
          const Divider(height: 1),
          
          // Rating distribution
          _buildRatingDistribution(),
          
          // Aspect ratings
          if (summary.aspectAverages.isNotEmpty) ...[
            const Divider(height: 1),
            _buildAspectRatings(),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallRating() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Large rating display
          Column(
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              _buildStarRating(summary.averageRating, size: 20),
              const SizedBox(height: 4),
              Text(
                '${summary.totalReviews} review${summary.totalReviews != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 24),
          
          // Rating bars
          Expanded(
            child: Column(
              children: [
                for (int i = 5; i >= 1; i--)
                  _buildRatingBar(i, summary.ratingDistribution[i] ?? 0, summary.totalReviews),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int rating, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$rating',
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            CupertinoIcons.star_fill,
            color: CupertinoColors.systemYellow,
            size: 12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 5; i >= 1; i--)
                _buildRatingColumn(i, summary.ratingDistribution[i] ?? 0, summary.totalReviews),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingColumn(int rating, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;
    final height = 60.0 * percentage;
    
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 20,
          height: 60,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 20,
              height: height,
              decoration: BoxDecoration(
                color: _getRatingColor(rating),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$rating',
              style: const TextStyle(
                fontSize: 10,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const Icon(
              CupertinoIcons.star_fill,
              color: CupertinoColors.systemYellow,
              size: 8,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAspectRatings() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aspect Ratings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),
          ...summary.aspectAverages.entries.map((entry) {
            return _buildAspectRating(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAspectRating(String aspect, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              aspect,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.label,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: rating / 5.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getRatingColor(rating.round()),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

  Widget _buildStarRating(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
          color: CupertinoColors.systemYellow,
          size: size,
        );
      }),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return CupertinoColors.systemGreen;
      case 4:
        return CupertinoColors.systemBlue;
      case 3:
        return CupertinoColors.systemYellow;
      case 2:
        return CupertinoColors.systemOrange;
      case 1:
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}