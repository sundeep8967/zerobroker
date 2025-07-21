import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  String _selectedPeriod = 'Last 7 days';
  final List<String> _periods = ['Last 7 days', 'Last 30 days', 'Last 3 months', 'Last year'];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: const Text('Analytics Dashboard'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showPeriodSelector,
          child: Text(_selectedPeriod),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildUserMetrics(),
            const SizedBox(height: 24),
            _buildPropertyMetrics(),
            const SizedBox(height: 24),
            _buildRevenueMetrics(),
            const SizedBox(height: 24),
            _buildTopProperties(),
            const SizedBox(height: 24),
            _buildUserActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Users',
                value: '12,847',
                change: '+12.5%',
                isPositive: true,
                icon: CupertinoIcons.person_2,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Properties',
                value: '3,421',
                change: '+8.2%',
                isPositive: true,
                icon: CupertinoIcons.house,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Revenue',
                value: '₹1,24,570',
                change: '+15.3%',
                isPositive: true,
                icon: CupertinoIcons.money_dollar_circle,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Unlocks',
                value: '8,234',
                change: '+22.1%',
                isPositive: true,
                icon: CupertinoIcons.lock_open,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive 
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMetrics() {
    return _buildSection(
      'User Metrics',
      [
        _buildListItem('Daily Active Users', '2,847', '+5.2%', true),
        _buildListItem('Monthly Active Users', '12,847', '+12.5%', true),
        _buildListItem('User Retention (7-day)', '68.4%', '+2.1%', true),
        _buildListItem('User Retention (30-day)', '42.8%', '-1.3%', false),
        _buildListItem('Average Session Duration', '8m 32s', '+18.7%', true),
      ],
    );
  }

  Widget _buildPropertyMetrics() {
    return _buildSection(
      'Property Metrics',
      [
        _buildListItem('New Properties', '127', '+15.4%', true),
        _buildListItem('Active Properties', '3,421', '+8.2%', true),
        _buildListItem('Property Views', '45,672', '+23.1%', true),
        _buildListItem('Contact Unlocks', '8,234', '+22.1%', true),
        _buildListItem('Conversion Rate', '18.0%', '+3.2%', true),
      ],
    );
  }

  Widget _buildRevenueMetrics() {
    return _buildSection(
      'Revenue Metrics',
      [
        _buildListItem('Total Revenue', '₹1,24,570', '+15.3%', true),
        _buildListItem('Revenue per User', '₹9.69', '+2.8%', true),
        _buildListItem('Contact Unlocks Revenue', '₹82,340', '+22.1%', true),
        _buildListItem('Premium Listings', '₹42,230', '+8.7%', true),
        _buildListItem('Average Order Value', '₹15.12', '+1.4%', true),
      ],
    );
  }

  Widget _buildTopProperties() {
    return _buildSection(
      'Top Performing Properties',
      [
        _buildPropertyItem('Luxury 3BHK in Koramangala', '234 views', '45 unlocks'),
        _buildPropertyItem('2BHK Near Metro Station', '198 views', '38 unlocks'),
        _buildPropertyItem('Studio Apartment in HSR', '187 views', '32 unlocks'),
        _buildPropertyItem('4BHK Villa in Whitefield', '156 views', '28 unlocks'),
        _buildPropertyItem('1BHK in Electronic City', '143 views', '25 unlocks'),
      ],
    );
  }

  Widget _buildUserActivity() {
    return _buildSection(
      'User Activity',
      [
        _buildActivityItem('Peak Hours', '7-9 PM', CupertinoIcons.clock),
        _buildActivityItem('Most Active Day', 'Sunday', CupertinoIcons.calendar),
        _buildActivityItem('Top Search Term', 'Koramangala', CupertinoIcons.search),
        _buildActivityItem('Popular Filter', '2BHK', CupertinoIcons.slider_horizontal_3),
        _buildActivityItem('Avg. Properties Viewed', '12.3', CupertinoIcons.eye),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(String title, String value, String change, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyItem(String title, String views, String unlocks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.house,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$views • $unlocks',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.secondaryLabel,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showPeriodSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Time Period'),
        actions: _periods.map((period) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _selectedPeriod = period);
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(period),
                if (_selectedPeriod == period) ...[
                  const SizedBox(width: 8),
                  const Icon(CupertinoIcons.checkmark, color: CupertinoColors.systemBlue),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}