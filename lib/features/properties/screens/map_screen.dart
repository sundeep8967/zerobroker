import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: Stack(
        children: [
          // Map placeholder - will be replaced with actual map implementation
          Container(
            width: double.infinity,
            height: double.infinity,
            color: CupertinoColors.systemGrey5,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.map,
                    size: 80,
                    color: CupertinoColors.systemGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Map View',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Search bar overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(
                    CupertinoIcons.search,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Search location...',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // TODO: Implement filter functionality
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        CupertinoIcons.slider_horizontal_3,
                        color: CupertinoColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          
          // Property pins (mock data)
          ..._buildPropertyPins(),
          
          // Bottom sheet handle
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPropertyPins() {
    // Mock property locations
    final properties = [
      {'top': 200.0, 'left': 100.0, 'price': '₹25K'},
      {'top': 300.0, 'left': 200.0, 'price': '₹30K'},
      {'top': 250.0, 'left': 300.0, 'price': '₹22K'},
      {'top': 400.0, 'left': 150.0, 'price': '₹35K'},
      {'top': 350.0, 'left': 250.0, 'price': '₹28K'},
    ];

    return properties.map((property) {
      return Positioned(
        top: property['top'] as double,
        left: property['left'] as double,
        child: GestureDetector(
          onTap: () {
            // TODO: Show property details
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              property['price'] as String,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBottomSheet() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '127 properties found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'in this area',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey.darkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(20),
                    onPressed: () {
                      // TODO: Show list view
                    },
                    child: const Text(
                      'View List',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}