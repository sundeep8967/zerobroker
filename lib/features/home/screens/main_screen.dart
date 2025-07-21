import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../properties/screens/properties_list_screen.dart';
import '../../properties/screens/map_screen.dart';
import '../../properties/screens/add_property_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../properties/providers/property_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;

  final List<Widget> _screens = [
    const PropertiesListScreen(),
    const MapScreen(),
    const AddPropertyScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.house),
      activeIcon: Icon(CupertinoIcons.house_fill),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.map),
      activeIcon: Icon(CupertinoIcons.map_fill),
      label: 'Map',
    ),
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.add_circled),
      activeIcon: Icon(CupertinoIcons.add_circled_solid),
      label: 'Add Property',
    ),
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.person),
      activeIcon: Icon(CupertinoIcons.person_fill),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Initialize properties
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().initializeProperties();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    // Add haptic feedback for iOS-style interaction
    HapticFeedback.lightImpact();
    
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut, // iOS-style spring animation
    );
    
    // Animate FAB based on selected tab
    if (index == 2) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // iOS-style scroll physics
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          if (index == 2) {
            _fabController.forward();
          } else {
            _fabController.reverse();
          }
        },
        children: _screens,
      ),
      
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: item.icon,
            activeIcon: item.activeIcon,
            label: item.label,
          );
        }).toList(),
        activeColor: AppTheme.primaryColor,
        inactiveColor: AppTheme.secondaryTextColor,
      ),
      
      // Floating Action Button for quick add property
      floatingActionButton: _currentIndex != 2 
          ? AnimatedFAB(
              onPressed: () => _onTabTapped(2),
              icon: CupertinoIcons.add,
              tooltip: 'Add Property',
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}