import 'package:flutter/material.dart';

class PaymentService {
  static const double unlockPrice = 10.0;
  
  // Mock payment processing
  static Future<PaymentResult> processPayment({
    required String propertyId,
    required String userId,
    required double amount,
  }) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock success (90% success rate for demo)
    final isSuccess = DateTime.now().millisecond % 10 != 0;
    
    if (isSuccess) {
      return PaymentResult(
        success: true,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        propertyId: propertyId,
        userId: userId,
        timestamp: DateTime.now(),
      );
    } else {
      return PaymentResult(
        success: false,
        error: 'Payment failed. Please try again.',
        propertyId: propertyId,
        userId: userId,
        timestamp: DateTime.now(),
      );
    }
  }
  
  // Show payment dialog
  static Future<bool> showPaymentDialog({
    required BuildContext context,
    required String propertyTitle,
    required VoidCallback onSuccess,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(
        propertyTitle: propertyTitle,
        amount: unlockPrice,
        onSuccess: onSuccess,
      ),
    ) ?? false;
  }
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? error;
  final double? amount;
  final String propertyId;
  final String userId;
  final DateTime timestamp;
  
  PaymentResult({
    required this.success,
    this.transactionId,
    this.error,
    this.amount,
    required this.propertyId,
    required this.userId,
    required this.timestamp,
  });
}

class PaymentDialog extends StatefulWidget {
  final String propertyTitle;
  final double amount;
  final VoidCallback onSuccess;
  
  const PaymentDialog({
    super.key,
    required this.propertyTitle,
    required this.amount,
    required this.onSuccess,
  });
  
  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool _isProcessing = false;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unlock Contact'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Property: ${widget.propertyTitle}'),
          const SizedBox(height: 8),
          Text('Amount: ₹${widget.amount.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          const Text(
            'Pay ₹10 to unlock the owner\'s contact number for this property.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processPayment,
          child: _isProcessing 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Pay Now'),
        ),
      ],
    );
  }
  
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final result = await PaymentService.processPayment(
        propertyId: 'demo_property',
        userId: 'demo_user',
        amount: widget.amount,
      );
      
      if (result.success) {
        widget.onSuccess();
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful! Contact unlocked.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Payment failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}