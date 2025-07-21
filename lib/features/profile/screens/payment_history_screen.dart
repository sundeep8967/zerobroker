import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';

class PaymentTransaction {
  final String id;
  final String type;
  final String description;
  final double amount;
  final DateTime timestamp;
  final PaymentStatus status;
  final String? propertyTitle;
  final String? transactionId;

  const PaymentTransaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.timestamp,
    required this.status,
    this.propertyTitle,
    this.transactionId,
  });
}

enum PaymentStatus {
  success,
  failed,
  pending,
  refunded,
}

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<PaymentTransaction> _transactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Success', 'Failed', 'Pending', 'Refunded'];

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate loading payment history
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock data - in real app this would come from Firebase/payment service
      final mockTransactions = <PaymentTransaction>[
        PaymentTransaction(
          id: '1',
          type: 'Contact Unlock',
          description: 'Unlocked contact for Luxury 2BHK Apartment',
          amount: 10.0,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: PaymentStatus.success,
          propertyTitle: 'Luxury 2BHK Apartment',
          transactionId: 'TXN123456789',
        ),
        PaymentTransaction(
          id: '2',
          type: 'Contact Unlock',
          description: 'Unlocked contact for Spacious 3BHK Villa',
          amount: 10.0,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          status: PaymentStatus.success,
          propertyTitle: 'Spacious 3BHK Villa',
          transactionId: 'TXN123456788',
        ),
        PaymentTransaction(
          id: '3',
          type: 'Contact Unlock',
          description: 'Failed payment for Modern Studio',
          amount: 10.0,
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          status: PaymentStatus.failed,
          propertyTitle: 'Modern Studio Apartment',
          transactionId: 'TXN123456787',
        ),
        PaymentTransaction(
          id: '4',
          type: 'Bundle Purchase',
          description: '5 Contact Unlocks Bundle',
          amount: 40.0,
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          status: PaymentStatus.success,
          transactionId: 'TXN123456786',
        ),
        PaymentTransaction(
          id: '5',
          type: 'Refund',
          description: 'Refund for duplicate payment',
          amount: -10.0,
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
          status: PaymentStatus.refunded,
          transactionId: 'TXN123456785',
        ),
      ];

      setState(() {
        _transactions = mockTransactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load payment history');
    }
  }

  List<PaymentTransaction> get _filteredTransactions {
    if (_selectedFilter == 'All') {
      return _transactions;
    }
    
    final status = PaymentStatus.values.firstWhere(
      (s) => s.toString().split('.').last.toLowerCase() == _selectedFilter.toLowerCase(),
      orElse: () => PaymentStatus.success,
    );
    
    return _transactions.where((t) => t.status == status).toList();
  }

  double get _totalSpent {
    return _transactions
        .where((t) => t.status == PaymentStatus.success && t.amount > 0)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _totalRefunded {
    return _transactions
        .where((t) => t.status == PaymentStatus.refunded)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CupertinoColors.systemRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTransactionDetails(PaymentTransaction transaction) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Transaction Details'),
        message: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Transaction ID', transaction.transactionId ?? 'N/A'),
            _buildDetailRow('Type', transaction.type),
            _buildDetailRow('Amount', '₹${transaction.amount.abs().toStringAsFixed(2)}'),
            _buildDetailRow('Status', _getStatusText(transaction.status)),
            _buildDetailRow('Date', _formatDateTime(transaction.timestamp)),
            if (transaction.propertyTitle != null)
              _buildDetailRow('Property', transaction.propertyTitle!),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: const Text('Payment History'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showFilterOptions,
          child: const Icon(CupertinoIcons.slider_horizontal_3),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 20),
            )
          : RefreshIndicator(
              onRefresh: _loadPaymentHistory,
              child: _transactions.isEmpty
                  ? _buildEmptyState()
                  : _buildPaymentHistory(),
            ),
    );
  }

  void _showFilterOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter Transactions'),
        actions: _filterOptions.map((filter) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _selectedFilter = filter;
              });
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(filter),
                if (_selectedFilter == filter)
                  const Icon(
                    CupertinoIcons.checkmark,
                    color: CupertinoColors.systemBlue,
                  ),
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

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  CupertinoIcons.creditcard,
                  size: 60,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Payment History',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your payment transactions will appear here when you unlock property contacts.',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Browse Properties'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHistory() {
    final filteredTransactions = _filteredTransactions;
    
    return Column(
      children: [
        // Summary Cards
        Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Spent',
                  '₹${_totalSpent.toStringAsFixed(0)}',
                  CupertinoIcons.money_dollar_circle,
                  CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Transactions',
                  '${_transactions.length}',
                  CupertinoIcons.creditcard,
                  CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
        ),
        
        // Filter Indicator
        if (_selectedFilter != 'All')
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filtered by: $_selectedFilter',
                  style: const TextStyle(
                    color: CupertinoColors.systemBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'All';
                    });
                  },
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: CupertinoColors.systemBlue,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Transactions List
        Expanded(
          child: filteredTransactions.isEmpty
              ? Center(
                  child: Text(
                    'No transactions found for $_selectedFilter',
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return FadeInUp(
                      duration: Duration(milliseconds: 600 + (index * 100)),
                      child: _buildTransactionCard(transaction),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PaymentTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showTransactionDetails(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getTransactionIcon(transaction.type),
                  color: _getStatusColor(transaction.status),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(transaction.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey2,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.amount >= 0 ? '+' : ''}₹${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: transaction.amount >= 0 
                          ? CupertinoColors.systemRed 
                          : CupertinoColors.systemGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getStatusText(transaction.status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(transaction.status),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'contact unlock':
        return CupertinoIcons.phone_circle;
      case 'bundle purchase':
        return CupertinoIcons.bag;
      case 'refund':
        return CupertinoIcons.arrow_counterclockwise_circle;
      default:
        return CupertinoIcons.creditcard;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return CupertinoColors.systemGreen;
      case PaymentStatus.failed:
        return CupertinoColors.systemRed;
      case PaymentStatus.pending:
        return CupertinoColors.systemOrange;
      case PaymentStatus.refunded:
        return CupertinoColors.systemBlue;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
}