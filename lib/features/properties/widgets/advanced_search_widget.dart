import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearchChanged;
  final Map<String, dynamic> currentFilters;

  const AdvancedSearchWidget({
    Key? key,
    required this.onSearchChanged,
    this.currentFilters = const {},
  }) : super(key: key);

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<String> _recentSearches = [];
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;

  final List<String> _popularAreas = [
    'Koramangala',
    'Indiranagar',
    'Whitefield',
    'Electronic City',
    'HSR Layout',
    'BTM Layout',
    'Marathahalli',
    'Jayanagar',
    'Rajajinagar',
    'Yelahanka',
  ];

  final List<String> _landmarks = [
    'Near Metro Station',
    'Near IT Park',
    'Near Hospital',
    'Near School',
    'Near Mall',
    'Near Airport',
    'Near Railway Station',
    'Near Bus Stop',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
    _locationController.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // In a real app, load from SharedPreferences
    _recentSearches = [
      '2 BHK Koramangala',
      'Furnished apartment',
      'Near Metro',
      'Pet friendly',
    ];
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _searchSuggestions = [];
      });
      return;
    }

    // Generate suggestions based on query
    final suggestions = <String>[];
    
    // Add area suggestions
    for (final area in _popularAreas) {
      if (area.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(area);
      }
    }
    
    // Add landmark suggestions
    for (final landmark in _landmarks) {
      if (landmark.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(landmark);
      }
    }
    
    // Add property type suggestions
    final propertyTypes = ['1 BHK', '2 BHK', '3 BHK', 'Studio', 'Villa'];
    for (final type in propertyTypes) {
      if (type.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(type);
      }
    }

    setState(() {
      _searchSuggestions = suggestions.take(5).toList();
      _showSuggestions = suggestions.isNotEmpty;
    });
  }

  void _onLocationChanged() {
    // Similar logic for location suggestions
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    // Add to recent searches
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    }

    // Hide suggestions
    setState(() {
      _showSuggestions = false;
    });

    // Perform search
    widget.onSearchChanged({
      'query': query,
      'location': _locationController.text,
      ...widget.currentFilters,
    });
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          FadeInDown(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search properties, areas...',
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: AppTheme.secondaryTextColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _performSearch,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Location',
                        prefixIcon: Icon(
                          CupertinoIcons.location,
                          color: AppTheme.secondaryTextColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Suggestions
          if (_showSuggestions) ...[
            const SizedBox(height: 12),
            FadeInUp(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: _searchSuggestions.map((suggestion) {
                    return ListTile(
                      leading: Icon(
                        CupertinoIcons.search,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      title: Text(
                        suggestion,
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () => _selectSuggestion(suggestion),
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          // Recent Searches
          if (!_showSuggestions && _recentSearches.isNotEmpty) ...[
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Searches',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _recentSearches.clear();
                          });
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentSearches.take(5).map((search) {
                      return GestureDetector(
                        onTap: () => _selectSuggestion(search),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.time,
                                size: 12,
                                color: AppTheme.secondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                search,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          // Popular Areas
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Areas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularAreas.take(6).map((area) {
                    return GestureDetector(
                      onTap: () => _selectSuggestion(area),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          area,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}