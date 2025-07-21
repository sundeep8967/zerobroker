import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/property_model.dart';
import '../../../core/services/favorites_service.dart';

class AnimatedPropertyCard extends StatefulWidget {
  final Property property;
  final int index;
  final VoidCallback? onTap;

  const AnimatedPropertyCard({
    Key? key,
    required this.property,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedPropertyCard> createState() => _AnimatedPropertyCardState();
}

class _AnimatedPropertyCardState extends State<AnimatedPropertyCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _favoriteController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _favoriteAnimation;
  
  bool _isPressed = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));
    
    // Check if property is already favorited
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final favorites = await FavoritesService.getFavorites();
    setState(() {
      _isFavorite = favorites.any((fav) => fav.id == widget.property.id);
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      FavoritesService.removeFavorite(widget.property.id);
    } else {
      FavoritesService.addToFavorites(widget.property.id);
    }
    
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: widget.index * 100),
      duration: const Duration(milliseconds: 600),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap ?? () {
                context.push('/property/${widget.property.id}');
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.withOpacity(0.5),
                      blurRadius: _isPressed ? 5 : 10,
                      offset: Offset(0, _isPressed ? 2 : 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with favorite button
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: CachedNetworkImage(
                              imageUrl: widget.property.photos.isNotEmpty 
                                  ? widget.property.photos.first 
                                  : '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: CupertinoColors.systemGrey6,
                                child: const Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: CupertinoColors.systemGrey6,
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.photo,
                                    size: 40,
                                    color: CupertinoColors.systemGrey3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Verified badge
                        if (widget.property.isVerified)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: SlideInLeft(
                              delay: Duration(milliseconds: widget.index * 100 + 200),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.checkmark_seal_fill,
                                      color: CupertinoColors.white,
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        
                        // Favorite button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: SlideInRight(
                            delay: Duration(milliseconds: widget.index * 100 + 300),
                            child: AnimatedBuilder(
                              animation: _favoriteAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _favoriteAnimation.value,
                                  child: GestureDetector(
                                    onTap: _toggleFavorite,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CupertinoColors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isFavorite 
                                            ? CupertinoIcons.heart_fill 
                                            : CupertinoIcons.heart,
                                        color: _isFavorite 
                                            ? CupertinoColors.systemRed 
                                            : CupertinoColors.systemGrey,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Property details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.property.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.label,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${widget.property.rent.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.systemBlue,
                                    ),
                                  ),
                                  const Text(
                                    'per month',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.secondaryLabel,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Location
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.location,
                                size: 14,
                                color: CupertinoColors.secondaryLabel,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.property.location.address,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Property stats
                          Row(
                            children: [
                              _buildStatChip(
                                icon: CupertinoIcons.home,
                                label: widget.property.propertyType,
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                icon: CupertinoIcons.eye,
                                label: '${widget.property.views}',
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                icon: CupertinoIcons.phone,
                                label: '${widget.property.unlocks}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: CupertinoColors.secondaryLabel,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}