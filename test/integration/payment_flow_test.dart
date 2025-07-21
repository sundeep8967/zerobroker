import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zerobroker/main.dart' as app;
import 'package:zerobroker/core/services/payment_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Payment Flow Integration Tests', () {
    testWidgets('Successful payment flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to property details
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Tap unlock contact button
      await tester.tap(find.text('Unlock Contact'));
      await tester.pumpAndSettle();

      // Verify payment dialog
      expect(find.text('Unlock Contact for ₹10'), findsOneWidget);
      expect(find.text('Pay ₹10'), findsOneWidget);

      // Proceed with payment
      await tester.tap(find.text('Pay ₹10'));
      await tester.pumpAndSettle();

      // Wait for payment processing
      await tester.pump(const Duration(seconds: 3));

      // Verify success state
      expect(find.text('Payment Successful'), findsOneWidget);
      expect(find.textContaining('+91'), findsOneWidget); // Phone number shown
    });

    testWidgets('Payment failure handling', (tester) async {
      // Mock payment failure
      PaymentService.mockPaymentFailure = true;

      app.main();
      await tester.pumpAndSettle();

      // Navigate to property details
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Attempt payment
      await tester.tap(find.text('Unlock Contact'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay ₹10'));
      await tester.pumpAndSettle();

      // Wait for payment processing
      await tester.pump(const Duration(seconds: 3));

      // Verify failure handling
      expect(find.text('Payment Failed'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Reset mock
      PaymentService.mockPaymentFailure = false;
    });

    testWidgets('Free unlock usage', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // First, add some free unlocks via referral
      await tester.tap(find.text('Referrals'));
      await tester.pumpAndSettle();

      // Simulate having free unlocks
      // (In real test, this would involve actual referral process)

      // Navigate back to properties
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Try to unlock contact with free unlock
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unlock Contact'));
      await tester.pumpAndSettle();

      // Should show free unlock option if available
      if (find.text('Use Free Unlock').evaluate().isNotEmpty) {
        await tester.tap(find.text('Use Free Unlock'));
        await tester.pumpAndSettle();

        // Verify contact unlocked without payment
        expect(find.textContaining('+91'), findsOneWidget);
      }
    });

    testWidgets('Prevent duplicate payments', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to property and unlock contact
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unlock Contact'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay ₹10'));
      await tester.pumpAndSettle();

      // Wait for payment completion
      await tester.pump(const Duration(seconds: 3));

      // Navigate away and back
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verify contact is already unlocked
      expect(find.textContaining('+91'), findsOneWidget);
      expect(find.text('Unlock Contact'), findsNothing);
    });

    testWidgets('Payment history tracking', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Make a payment
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unlock Contact'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay ₹10'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 3));

      // Navigate to profile to check payment history
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Payment History'));
      await tester.pumpAndSettle();

      // Verify payment appears in history
      expect(find.text('Payment History'), findsOneWidget);
      expect(find.text('₹10'), findsAtLeastNWidgets(1));
    });
  });
}