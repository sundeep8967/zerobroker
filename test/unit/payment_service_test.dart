import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Payment Validation Tests', () {
    test('should validate payment amounts correctly', () {
      // Test valid payment amounts
      expect(isValidPaymentAmount(10.0), true);
      expect(isValidPaymentAmount(50.0), true);
      expect(isValidPaymentAmount(100.0), true);
      
      // Test invalid payment amounts
      expect(isValidPaymentAmount(0.0), false);
      expect(isValidPaymentAmount(-10.0), false);
      expect(isValidPaymentAmount(5.0), false); // Below minimum
    });

    test('should generate valid payment ID format', () {
      final paymentId = generateTestPaymentId();
      
      // Payment ID should not be empty
      expect(paymentId.isNotEmpty, true);
      
      // Payment ID should start with 'pay_'
      expect(paymentId.startsWith('pay_'), true);
      
      // Payment ID should have reasonable length
      expect(paymentId.length, greaterThan(10));
    });

    test('should calculate pricing correctly', () {
      // Test individual unlock price
      expect(calculateUnlockPrice(1), 10.0);
      
      // Test bundle pricing
      expect(calculateUnlockPrice(6), 50.0);
      expect(calculateUnlockPrice(15), 100.0);
      
      // Test custom quantities
      expect(calculateUnlockPrice(3), 30.0);
    });

    test('should validate phone number format', () {
      // Valid phone numbers
      expect(isValidPhoneNumber('+919876543210'), true);
      expect(isValidPhoneNumber('9876543210'), true);
      
      // Invalid phone numbers
      expect(isValidPhoneNumber(''), false);
      expect(isValidPhoneNumber('123'), false);
      expect(isValidPhoneNumber('abcdefghij'), false);
    });
  });
}

// Helper functions for testing
bool isValidPaymentAmount(double amount) {
  return amount >= 10.0;
}

String generateTestPaymentId() {
  return 'pay_${DateTime.now().millisecondsSinceEpoch}';
}

double calculateUnlockPrice(int quantity) {
  if (quantity >= 15) return 100.0;
  if (quantity >= 6) return 50.0;
  return quantity * 10.0;
}

bool isValidPhoneNumber(String phone) {
  if (phone.isEmpty) return false;
  final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
  return cleanPhone.length >= 10;
}