class AppConstants {
  // App Info
  static const String appName = 'ZeroBroker';
  static const String appVersion = '1.0.0';
  
  // Pricing
  static const double unlockPrice = 10.0;
  static const String currency = '₹';
  
  // Bundle Offers
  static const Map<String, dynamic> bundleOffers = {
    'basic': {'price': 50.0, 'unlocks': 6, 'savings': 10.0},
    'premium': {'price': 100.0, 'unlocks': 15, 'savings': 50.0},
  };
  
  // API Endpoints
  static const String baseUrl = 'https://api.zerobroker.com';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String propertiesCollection = 'properties';
  static const String unlocksCollection = 'unlocks';
  static const String reportsCollection = 'reports';
  
  // Shared Preferences Keys
  static const String userIdKey = 'user_id';
  static const String userTokenKey = 'user_token';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String selectedCityKey = 'selected_city';
  
  // Property Types
  static const List<String> propertyTypes = [
    '1 RK',
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4+ BHK',
    'Villa',
    'Plot',
    'Shop',
    'Office',
    'Warehouse',
  ];
  
  // Amenities
  static const List<String> amenities = [
    'Parking',
    'Lift',
    'Security',
    'Power Backup',
    'Water Supply',
    'Gym',
    'Swimming Pool',
    'Garden',
    'Club House',
    'Children Play Area',
    'Intercom',
    'Gas Pipeline',
    'Maintenance Staff',
    'Waste Disposal',
    'Rainwater Harvesting',
  ];
  
  // Cities (Initial Launch Cities)
  static const List<Map<String, dynamic>> cities = [
    {'name': 'Bangalore', 'state': 'Karnataka', 'lat': 12.9716, 'lng': 77.5946},
    {'name': 'Mumbai', 'state': 'Maharashtra', 'lat': 19.0760, 'lng': 72.8777},
    {'name': 'Delhi', 'state': 'Delhi', 'lat': 28.7041, 'lng': 77.1025},
    {'name': 'Pune', 'state': 'Maharashtra', 'lat': 18.5204, 'lng': 73.8567},
    {'name': 'Hyderabad', 'state': 'Telangana', 'lat': 17.3850, 'lng': 78.4867},
    {'name': 'Chennai', 'state': 'Tamil Nadu', 'lat': 13.0827, 'lng': 80.2707},
  ];
  
  // Validation
  static const int minRent = 1000;
  static const int maxRent = 500000;
  static const int maxPhotos = 10;
  static const int maxDescriptionLength = 1000;
  
  // Animation Durations (in milliseconds)
  static const int fastAnimation = 200;
  static const int mediumAnimation = 300;
  static const int slowAnimation = 500;
  
  // Error Messages
  static const String networkError = 'Please check your internet connection';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String paymentError = 'Payment failed. Please try again.';
  static const String locationError = 'Unable to get your location';
  
  // Success Messages
  static const String propertyAddedSuccess = 'Property added successfully!';
  static const String paymentSuccess = 'Payment successful!';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';
}