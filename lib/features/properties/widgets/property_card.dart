import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/property_model.dart';
import '../../../core/services/favorites_service.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({
    Key? key,
    required this.property,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/home/property/${property.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Image
              _buildPropertyImage(),
              
              // Property Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Verified Badge
                    _buildTitleRow(),
                    
                    const SizedBox(height: 8),
                    
                    // Location
                    _buildLocationRow(),
                    
                    const SizedBox(height: 12),
                    
                    // Rent and Deposit
                    _buildPriceRow(),
                    
                    const SizedBox(height: 12),
                    
                    // Amenities
                    _buildAmenities(),
                    
                    const SizedBox(height: 12),
                    
                    // Stats and Contact Button
                    _buildBottomRow(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Stack(
        children: [
          // Main Image
          Container(
            height: 200,
            width: double.infinity,
            child: property.photos.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: property.photos.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.backgroundColor,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.backgroundColor,
                      child: const Icon(
                        Icons.home,
                        size: 50,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  )
                : Container(
                    color: AppTheme.backgroundColor,
                    child: const Icon(
                      Icons.home,
                      size: 50,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
          ),
          
          // Property Type Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                property.propertyType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Featured Badge
          if (property.isFeatured)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Photo Count
          if (property.photos.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${property.photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Favorite Button
          Positioned(
            top: 12,
            right: 12,
            child: Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, child) {
                final isFavorite = favoritesProvider.isFavorite(property.id);
                return GestureDetector(
                  onTap: () {
                    final isNowFavorite = favoritesProvider.toggleFavorite(property.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isNowFavorite 
                            ? 'Added to favorites' 
                            : 'Removed from favorites'
                        ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: isNowFavorite 
                          ? AppTheme.secondaryColor 
                          : AppTheme.secondaryTextColor,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : AppTheme.secondaryTextColor,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            property.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (property.isVerified)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified,
              color: AppTheme.secondaryColor,
              size: 16,
            ),
          ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: AppTheme.secondaryTextColor,
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${property.location.address}, ${property.location.city}',
            style: const TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Text(
          '${AppConstants.currency}${property.rent.toInt()}/month',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        if (property.deposit != null) ...[
          const SizedBox(width: 8),
          Text(
            '• ${AppConstants.currency}${property.deposit!.toInt()} deposit',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmenities() {
    final displayAmenities = property.amenities.take(3).toList();
    final remainingCount = property.amenities.length - 3;
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...displayAmenities.map((amenity) => _buildAmenityChip(amenity)),
        if (remainingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remainingCount more',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        amenity,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      children: [
        // Views and Unlocks Stats
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${property.views}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${property.unlocks} unlocks',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        
        // Contact Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.phone,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${AppConstants.currency}${AppConstants.unlockPrice.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}