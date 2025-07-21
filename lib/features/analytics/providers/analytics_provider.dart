import 'package:flutter/foundation.dart';
import '../models/analytics_model.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  OverallAnalytics? _overallAnalytics;
  Map<String, PropertyAnalytics> _propertyAnalytics = {};
  List<PropertyAnalytics> _userPropertiesAnalytics = [];
  Map<String, dynamic> _analyticsSummary = {};
  List<Map<String, dynamic>> _performanceInsights = [];
  
  bool _isLoading = false;
  String? _error;
  AnalyticsFilter _currentFilter = const AnalyticsFilter();

  // Getters
  OverallAnalytics? get overallAnalytics => _overallAnalytics;
  Map<String, PropertyAnalytics> get propertyAnalytics => _propertyAnalytics;
  List<PropertyAnalytics> get userPropertiesAnalytics => _userPropertiesAnalytics;
  Map<String, dynamic> get analyticsSummary => _analyticsSummary;
  List<Map<String, dynamic>> get performanceInsights => _performanceInsights;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AnalyticsFilter get currentFilter => _currentFilter;

  PropertyAnalytics? getPropertyAnalytics(String propertyId) {
    return _propertyAnalytics[propertyId];
  }

  // Initialize mock data
  Future<void> initializeMockData() async {
    _analyticsService.initializeMockData();
  }

  // Load overall analytics
  Future<void> loadOverallAnalytics([AnalyticsFilter? filter]) async {
    _setLoading(true);
    _clearError();

    try {
      final filterToUse = filter ?? _currentFilter;
      _overallAnalytics = await _analyticsService.getOverallAnalytics(filterToUse);
      
      if (filter != null) {
        _currentFilter = filter;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load overall analytics: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load property analytics
  Future<void> loadPropertyAnalytics(String propertyId, [AnalyticsFilter? filter]) async {
    _setLoading(true);
    _clearError();

    try {
      final filterToUse = filter ?? _currentFilter;
      final analytics = await _analyticsService.getPropertyAnalytics(propertyId, filterToUse);
      
      if (analytics != null) {
        _propertyAnalytics[propertyId] = analytics;
      }
      
      if (filter != null) {
        _currentFilter = filter;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load property analytics: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load user properties analytics
  Future<void> loadUserPropertiesAnalytics(String userId, [AnalyticsFilter? filter]) async {
    _setLoading(true);
    _clearError();

    try {
      final filterToUse = filter ?? _currentFilter;
      _userPropertiesAnalytics = await _analyticsService.getUserPropertiesAnalytics(userId, filterToUse);
      
      if (filter != null) {
        _currentFilter = filter;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user properties analytics: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load analytics summary
  Future<void> loadAnalyticsSummary([AnalyticsFilter? filter]) async {
    try {
      final filterToUse = filter ?? _currentFilter;
      _analyticsSummary = await _analyticsService.getAnalyticsSummary(filterToUse);
      
      if (filter != null) {
        _currentFilter = filter;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load analytics summary: ${e.toString()}');
    }
  }

  // Load performance insights
  Future<void> loadPerformanceInsights([AnalyticsFilter? filter]) async {
    try {
      final filterToUse = filter ?? _currentFilter;
      _performanceInsights = await _analyticsService.getPerformanceInsights(filterToUse);
      
      if (filter != null) {
        _currentFilter = filter;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load performance insights: ${e.toString()}');
    }
  }

  // Load all analytics data
  Future<void> loadAllAnalytics(String? userId, [AnalyticsFilter? filter]) async {
    _setLoading(true);
    _clearError();

    try {
      final filterToUse = filter ?? _currentFilter;
      
      // Load all data concurrently
      await Future.wait([
        loadOverallAnalytics(filterToUse),
        if (userId != null) loadUserPropertiesAnalytics(userId, filterToUse),
        loadAnalyticsSummary(filterToUse),
        loadPerformanceInsights(filterToUse),
      ]);
      
      if (filter != null) {
        _currentFilter = filter;
      }
    } catch (e) {
      _setError('Failed to load analytics: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update filter
  void updateFilter(AnalyticsFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Export analytics data
  Future<Map<String, dynamic>?> exportAnalyticsData() async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _analyticsService.exportAnalyticsData(_currentFilter);
      return data;
    } catch (e) {
      _setError('Failed to export analytics data: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh all data
  Future<void> refresh(String? userId) async {
    await loadAllAnalytics(userId, _currentFilter);
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
    _overallAnalytics = null;
    _propertyAnalytics.clear();
    _userPropertiesAnalytics.clear();
    _analyticsSummary.clear();
    _performanceInsights.clear();
    _isLoading = false;
    _error = null;
    _currentFilter = const AnalyticsFilter();
    notifyListeners();
  }

  // Get analytics insights
  Map<String, dynamic> getAnalyticsInsights() {
    if (_overallAnalytics == null) return {};

    final overall = _overallAnalytics!;
    
    return {
      'totalEngagement': overall.totalViews + overall.totalUnlocks,
      'revenueGrowth': _calculateRevenueGrowth(),
      'topPerformingCity': _getTopPerformingCity(),
      'mostPopularPropertyType': _getMostPopularPropertyType(),
      'averageViewsPerProperty': overall.totalProperties > 0 
          ? (overall.totalViews / overall.totalProperties).round() 
          : 0,
      'conversionTrend': _getConversionTrend(),
    };
  }

  double _calculateRevenueGrowth() {
    if (_overallAnalytics?.revenueByMonth.isEmpty ?? true) return 0.0;
    
    final revenues = _overallAnalytics!.revenueByMonth.values.toList();
    if (revenues.length < 2) return 0.0;
    
    final currentMonth = revenues.last;
    final previousMonth = revenues[revenues.length - 2];
    
    if (previousMonth == 0) return 0.0;
    
    return ((currentMonth - previousMonth) / previousMonth) * 100;
  }

  String _getTopPerformingCity() {
    if (_overallAnalytics?.usersByCity.isEmpty ?? true) return 'N/A';
    
    final cities = _overallAnalytics!.usersByCity;
    final topCity = cities.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    return topCity.key;
  }

  String _getMostPopularPropertyType() {
    if (_overallAnalytics?.propertiesByType.isEmpty ?? true) return 'N/A';
    
    final types = _overallAnalytics!.propertiesByType;
    final topType = types.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    return topType.key;
  }

  String _getConversionTrend() {
    // Mock trend calculation
    final conversionRate = _overallAnalytics?.averageConversionRate ?? 0.0;
    
    if (conversionRate > 6.0) return 'Increasing';
    if (conversionRate > 4.0) return 'Stable';
    return 'Decreasing';
  }
}