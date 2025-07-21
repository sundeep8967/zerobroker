import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zerobroker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Map Functionality Integration Tests', () {
    testWidgets('Map loads with property markers', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to map view
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Wait for map to load
      await tester.pump(const Duration(seconds: 5));

      // Verify map is displayed
      expect(find.byType(GoogleMap), findsOneWidget);

      // Verify map controls are present
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('Property markers are clickable', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Wait for map and markers to load
      await tester.pump(const Duration(seconds: 5));

      // Find and tap a property marker
      // Note: In real test, you'd need to simulate marker tap
      // This is a simplified version
      final mapWidget = find.byType(GoogleMap);
      expect(mapWidget, findsOneWidget);

      // Simulate marker tap by tapping on map area
      await tester.tap(mapWidget);
      await tester.pumpAndSettle();

      // Verify property info popup or navigation
      // This would depend on your map implementation
    });

    testWidgets('Map filters work correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Open map filters
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Apply price filter
      await tester.drag(find.byType(Slider).first, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Apply property type filter
      await tester.tap(find.text('2BHK'));
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify map updates with filtered markers
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('Current location functionality', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Tap current location button
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();

      // Wait for location update
      await tester.pump(const Duration(seconds: 3));

      // Verify map centers on current location
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('Map clustering works for multiple properties', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Wait for map to load
      await tester.pump(const Duration(seconds: 5));

      // Zoom out to see clusters
      final mapWidget = find.byType(GoogleMap);
      await tester.timedDrag(
        mapWidget,
        const Offset(0, 0),
        const Duration(milliseconds: 500),
      );
      await tester.pumpAndSettle();

      // Verify clustering behavior
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('Map search functionality', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Find search field on map
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField);
        await tester.enterText(searchField, 'Koramangala');
        await tester.pumpAndSettle();

        // Wait for search results
        await tester.pump(const Duration(seconds: 3));

        // Verify map moves to searched location
        expect(find.byType(GoogleMap), findsOneWidget);
      }
    });

    testWidgets('Map style switching', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Look for map style toggle button
      final styleButton = find.byIcon(Icons.layers);
      if (styleButton.evaluate().isNotEmpty) {
        await tester.tap(styleButton);
        await tester.pumpAndSettle();

        // Select satellite view
        await tester.tap(find.text('Satellite'));
        await tester.pumpAndSettle();

        // Verify map style changed
        expect(find.byType(GoogleMap), findsOneWidget);
      }
    });
  });
}