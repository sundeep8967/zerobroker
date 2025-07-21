import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zerobroker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ZeroBroker App Integration Tests', () {
    testWidgets('Complete user flow: Browse -> View -> Unlock Contact', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test 1: App launches successfully
      expect(find.text('ZeroBroker'), findsOneWidget);

      // Test 2: Navigate to properties list
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Test 3: Search for properties
      final searchField = find.byType(TextField).first;
      await tester.tap(searchField);
      await tester.enterText(searchField, 'Bangalore');
      await tester.pumpAndSettle();

      // Test 4: Apply filters
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Set price range
      await tester.drag(find.byType(Slider).first, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      // Test 5: View property details
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verify property details screen
      expect(find.text('Property Details'), findsOneWidget);
      expect(find.text('Unlock Contact'), findsOneWidget);

      // Test 6: Attempt to unlock contact
      await tester.tap(find.text('Unlock Contact'));
      await tester.pumpAndSettle();

      // Verify payment dialog appears
      expect(find.text('Unlock Contact for ₹10'), findsOneWidget);

      // Test 7: Navigate to favorites
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // Add to favorites
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();

      // Test 8: Check favorites screen
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(find.text('Your Favorites'), findsOneWidget);

      // Test 9: Test map view
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsOneWidget);

      // Test 10: Test profile screen
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Property upload flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add property
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill property form
      await tester.enterText(find.byKey(const Key('property_title')), 'Test Property');
      await tester.enterText(find.byKey(const Key('property_rent')), '25000');
      await tester.enterText(find.byKey(const Key('property_deposit')), '50000');

      // Select property type
      await tester.tap(find.text('2BHK'));
      await tester.pumpAndSettle();

      // Add description
      await tester.enterText(
        find.byKey(const Key('property_description')), 
        'Beautiful 2BHK apartment with modern amenities'
      );

      // Select amenities
      await tester.tap(find.text('Parking'));
      await tester.tap(find.text('Gym'));
      await tester.pumpAndSettle();

      // Submit property
      await tester.tap(find.text('Add Property'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Property added successfully'), findsOneWidget);
    });

    testWidgets('Search and filter functionality', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test search
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'HSR Layout');
      await tester.pumpAndSettle();

      // Verify search results
      expect(find.textContaining('HSR'), findsAtLeastNWidgets(1));

      // Test filters
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Set price range
      await tester.drag(find.byType(Slider).first, const Offset(50, 0));
      await tester.drag(find.byType(Slider).last, const Offset(-50, 0));

      // Select property type
      await tester.tap(find.text('1BHK'));
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('1BHK'), findsAtLeastNWidgets(1));
    });

    testWidgets('Offline functionality', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Browse some properties to cache them
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      await tester.pageBack();

      await tester.tap(find.byType(Card).at(1));
      await tester.pumpAndSettle();
      await tester.pageBack();

      // Navigate to offline screen
      await tester.tap(find.text('Offline'));
      await tester.pumpAndSettle();

      // Verify offline properties are shown
      expect(find.text('Offline Properties'), findsOneWidget);
      expect(find.text('Cached Properties'), findsOneWidget);
    });

    testWidgets('Referral system flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to referral screen
      await tester.tap(find.text('Referrals'));
      await tester.pumpAndSettle();

      // Verify referral screen
      expect(find.text('Referral Program'), findsOneWidget);
      expect(find.text('Your Referral Code'), findsOneWidget);

      // Test share functionality
      await tester.tap(find.text('Share with Friends'));
      await tester.pumpAndSettle();

      // Test enter referral code
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ZB1234');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
    });
  });
}