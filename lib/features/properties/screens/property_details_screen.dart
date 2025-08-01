import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/property_model.dart';
import '../providers/property_provider.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/services/favorites_service.dart';
import '../widgets/enhanced_photo_gallery.dart';
import '../widgets/report_property_dialog.dart';
import '../widgets/property_comparison_widget.dart';
import '../widgets/property_reviews_widget.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;
  
  const PropertyDetailsScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late PageController _photoController;
  int _currentPhotoIndex = 0;
  bool _isContactUnlocked = false;
  bool _isFavorite = false;
  final PropertyComparisonManager _comparisonManager = PropertyComparisonManager();

  @override
  void initState() {
    super.initState();
    _photoController = PageController();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = FavoritesService.isFavorite(widget.propertyId);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite(Property property) async {
    HapticFeedback.lightImpact();
    
    if (_isFavorite) {
      FavoritesService.removeFromFavorites(property.id);
      _showSnackBar('Removed from favorites');
    } else {
      FavoritesService.addToFavorites(property.id);
      _showSnackBar('Added to favorites');
    }
    
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _unlockContact(Property property) async {
    // Add haptic feedback for iOS-style interaction
    HapticFeedback.mediumImpact();
    
    // Check if already unlocked to prevent duplicate payments
    if (_isContactUnlocked) {
      _showSnackBar('Contact already unlocked!');
      return;
    }

    await PaymentService.showPaymentDialog(
      context: context,
      propertyTitle: property.title,
      onSuccess: () {
        setState(() {
          _isContactUnlocked = true;
        });
        // Update property unlock count
        context.read<PropertyProvider>().unlockContact(property.id);
        _showSnackBar('Contact unlocked successfully!');
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackBar('Could not launch phone dialer');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // Remove any formatting from phone number
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('WhatsApp not installed');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleComparison(Property property) {
    // Add haptic feedback for iOS-style interaction
    HapticFeedback.lightImpact();
    
    if (_comparisonManager.isInComparison(property.id)) {
      _comparisonManager.removeFromComparison(property.id);
      _showSnackBar('Removed from comparison');
    } else {
      if (_comparisonManager.isFull) {
        _showSnackBar('Maximum 3 properties can be compared');
        return;
      }
      if (_comparisonManager.addToComparison(property)) {
        _showSnackBar('Added to comparison');
        setState(() {}); // Refresh to update button state
      }
    }
  }

  void _showReportDialog(Property property) {
    showDialog(
      context: context,
      builder: (context) => ReportPropertyDialog(
        propertyId: property.id,
        userId: 'current_user_id', // TODO: Get from auth service
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final property = propertyProvider.getPropertyById(widget.propertyId);

    if (property == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Property Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 64,
                color: AppTheme.secondaryTextColor,
              ),
              SizedBox(height: 16),
              Text(
                'Property not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'The property you\'re looking for doesn\'t exist',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // iOS-style scroll physics
        slivers: [
          // Photo Gallery App Bar with iOS-style navigation
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.back,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
            actions: [
              // Comparison button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _toggleComparison(property),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _comparisonManager.isInComparison(property.id)
                        ? CupertinoIcons.arrow_right_arrow_left
                        : CupertinoIcons.arrow_right_arrow_left,
                    color: _comparisonManager.isInComparison(property.id)
                        ? AppTheme.primaryColor
                        : Colors.black,
                    size: 20,
                  ),
                ),
              ),
              // Report button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showReportDialog(property),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.flag,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Photo PageView with enhanced tap functionality
                  GestureDetector(
                    onTap: () {
                      // Open enhanced photo gallery
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              EnhancedPhotoGallery(
                            photos: property.photos,
                            initialIndex: _currentPhotoIndex,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                          opaque: false,
                        ),
                      );
                    },
                    child: PageView.builder(
                      controller: _photoController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPhotoIndex = index;
                        });
                      },
                      itemCount: property.photos.length,
                      itemBuilder: (context, index) {
                        return Hero(
                          tag: 'photo_${property.photos[index]}',
                          child: CachedNetworkImage(
                            imageUrl: property.photos[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.backgroundColor,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.backgroundColor,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Enhanced photo indicators with animation
                  if (property.photos.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          property.photos.length,
                          (index) => AnimatedContainer(
                            duration: AppAnimations.medium,
                            curve: AppAnimations.springCurve, // iOS-style spring animation
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPhotoIndex == index ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPhotoIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              boxShadow: _currentPhotoIndex == index
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Photo count overlay
                  if (property.photos.length > 1)
                    Positioned(
                      top: 60,
                      left: 16,
                      child: FadeInLeft(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.photo_on_rectangle,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_currentPhotoIndex + 1}/${property.photos.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Verified badge
                  if (property.isVerified)
                    Positioned(
                      top: 60,
                      right: 16,
                      child: FadeInRight(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Property Details
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  FadeInUp(
                    delay: Duration(milliseconds: 100),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.location,
                                    size: 16,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      property.location.address,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${property.rent.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'per month',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Property Type and Stats
                  FadeInUp(
                    delay: Duration(milliseconds: 200),
                    child: Row(
                      children: [
                        _buildStatCard(
                          icon: CupertinoIcons.house,
                          label: property.propertyType,
                        ),
                        SizedBox(width: 12),
                        _buildStatCard(
                          icon: CupertinoIcons.eye,
                          label: '${property.views} views',
                        ),
                        SizedBox(width: 12),
                        _buildStatCard(
                          icon: CupertinoIcons.phone,
                          label: '${property.unlocks} unlocks',
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Description
                  FadeInUp(
                    delay: Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          property.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Amenities
                  if (property.amenities.isNotEmpty)
                    FadeInUp(
                      delay: Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amenities',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: property.amenities.map((amenity) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  amenity,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  
                  SizedBox(height: 24),
                  
                  // Deposit Info
                  if (property.deposit != null)
                    FadeInUp(
                      delay: Duration(milliseconds: 500),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.creditcard,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Security Deposit',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₹${property.deposit!.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Action Buttons
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Contact Button
              Expanded(
                child: _isContactUnlocked
                    ? Column(
                        children: [
                          // Phone Number Display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.secondaryColor),
                            ),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.phone_fill, color: AppTheme.secondaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  property.ownerPhone,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Call and WhatsApp Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _makePhoneCall(property.ownerPhone),
                                  icon: const Icon(CupertinoIcons.phone_fill, size: 18),
                                  label: const Text('Call'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.secondaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _openWhatsApp(property.ownerPhone),
                                  icon: const Icon(CupertinoIcons.chat_bubble_fill, size: 18),
                                  label: const Text('WhatsApp'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _unlockContact(property),
                        icon: const Icon(CupertinoIcons.lock_open),
                        label: const Text('Unlock Contact - ₹10'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              ),
              
              SizedBox(width: 12),
              
              // Favorite Button
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _toggleFavorite(property),
                  icon: Icon(
                    _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    color: _isFavorite ? CupertinoColors.systemRed : AppTheme.primaryColor,
                  ),
                  padding: EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}