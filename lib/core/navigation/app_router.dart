import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/properties/screens/property_details_screen.dart';
import '../../features/properties/screens/add_property_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Main App
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScreen(),
        routes: [
          // Property Details
          GoRoute(
            path: '/property/:id',
            name: 'property-details',
            builder: (context, state) {
              final propertyId = state.pathParameters['id']!;
              return PropertyDetailsScreen(propertyId: propertyId);
            },
          ),
          
          // Add Property
          GoRoute(
            path: '/add-property',
            name: 'add-property',
            builder: (context, state) => const AddPropertyScreen(),
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    
    // Custom error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}