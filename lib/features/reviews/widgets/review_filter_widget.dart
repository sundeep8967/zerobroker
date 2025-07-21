import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/review_model.dart';

class ReviewFilterWidget extends StatefulWidget {
  final ReviewFilter filter;
  final Function(ReviewFilter) onFilterChanged;
  final VoidCallback onClearFilter;

  const ReviewFilterWidget({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onClearFilter,
  });

  @override
  State<ReviewFilterWidget> createState() => _ReviewFilterWidgetState();
}

class _ReviewFilterWidgetState extends State<ReviewFilterWidget> {
  late ReviewFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.onClearFilter,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sort by
          _buildSortSection(),

          const Divider(height: 1),

          // Review type filter
          _buildReviewTypeSection(),

          const Divider(height: 1),

          // Rating filter
          _buildRatingSection(),

          const Divider(height: 1),

          // Additional filters
          _buildAdditionalFilters(),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: () => widget.onFilterChanged(_currentFilter),
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sort By',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoSlidingSegmentedControl<String>(
            groupValue: _currentFilter.sortBy,
            onValueChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(sortBy: value);
              });
            },
            children: const {
              'newest': Text('Newest'),
              'oldest': Text('Oldest'),
              'highest': Text('Highest'),
              'lowest': Text('Lowest'),
              'helpful': Text('Helpful'),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTypeSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip('All', null),
              ...ReviewType.values.map((type) => _buildTypeChip(_getTypeDisplayName(type), type)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, ReviewType? type) {
    final isSelected = _currentFilter.type == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = _currentFilter.copyWith(type: type);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? CupertinoColors.systemBlue : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? CupertinoColors.white : CupertinoColors.label,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minimum',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildRatingSelector(
                      _currentFilter.minRating?.toInt(),
                      (rating) {
                        setState(() {
                          _currentFilter = _currentFilter.copyWith(minRating: rating?.toDouble());
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Maximum',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildRatingSelector(
                      _currentFilter.maxRating?.toInt(),
                      (rating) {
                        setState(() {
                          _currentFilter = _currentFilter.copyWith(maxRating: rating?.toDouble());
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSelector(int? selectedRating, Function(int?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedRating,
          isExpanded: true,
          icon: const Icon(CupertinoIcons.chevron_down, size: 16),
          onChanged: onChanged,
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Any'),
            ),
            ...List.generate(5, (index) {
              final rating = index + 1;
              return DropdownMenuItem<int?>(
                value: rating,
                child: Row(
                  children: [
                    Text('$rating'),
                    const SizedBox(width: 4),
                    const Icon(
                      CupertinoIcons.star_fill,
                      color: CupertinoColors.systemYellow,
                      size: 12,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CupertinoSwitch(
                      value: _currentFilter.hasImages ?? false,
                      onChanged: (value) {
                        setState(() {
                          _currentFilter = _currentFilter.copyWith(hasImages: value ? true : null);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Has Images',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(ReviewType type) {
    switch (type) {
      case ReviewType.general:
        return 'General';
      case ReviewType.tenant:
        return 'Tenant';
      case ReviewType.buyer:
        return 'Buyer';
      case ReviewType.visitor:
        return 'Visitor';
    }
  }
}