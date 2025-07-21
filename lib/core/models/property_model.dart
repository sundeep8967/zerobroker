import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final double rent;
  final double? deposit;
  final String propertyType;
  final PropertyLocation location;
  final List<String> photos;
  final List<String> amenities;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isVerified;
  final int views;
  final int unlocks;
  final bool isFeatured;
  final DateTime? featuredUntil;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.rent,
    this.deposit,
    required this.propertyType,
    required this.location,
    required this.photos,
    required this.amenities,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isVerified = false,
    this.views = 0,
    this.unlocks = 0,
    this.isFeatured = false,
    this.featuredUntil,
  });

  // Convert from Firestore document
  factory Property.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Property(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      rent: (data['rent'] ?? 0).toDouble(),
      deposit: data['deposit']?.toDouble(),
      propertyType: data['propertyType'] ?? '',
      location: PropertyLocation.fromMap(data['location'] ?? {}),
      photos: List<String>.from(data['photos'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerPhone: data['ownerPhone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      views: data['views'] ?? 0,
      unlocks: data['unlocks'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      featuredUntil: data['featuredUntil'] != null 
          ? (data['featuredUntil'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'rent': rent,
      'deposit': deposit,
      'propertyType': propertyType,
      'location': location.toMap(),
      'photos': photos,
      'amenities': amenities,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'isVerified': isVerified,
      'views': views,
      'unlocks': unlocks,
      'isFeatured': isFeatured,
      'featuredUntil': featuredUntil != null ? Timestamp.fromDate(featuredUntil!) : null,
    };
  }

  // Alias methods for compatibility
  Map<String, dynamic> toJson() => toFirestore();
  
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      rent: (json['rent'] ?? 0).toDouble(),
      deposit: json['deposit']?.toDouble(),
      propertyType: json['propertyType'] ?? '',
      location: PropertyLocation.fromMap(json['location'] ?? {}),
      photos: List<String>.from(json['photos'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerPhone: json['ownerPhone'] ?? '',
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] is Timestamp 
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt']))
          : null,
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      views: json['views'] ?? 0,
      unlocks: json['unlocks'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      featuredUntil: json['featuredUntil'] != null 
          ? (json['featuredUntil'] is Timestamp 
              ? (json['featuredUntil'] as Timestamp).toDate()
              : DateTime.parse(json['featuredUntil']))
          : null,
    );
  }

  // Copy with method for updates
  Property copyWith({
    String? title,
    String? description,
    double? rent,
    double? deposit,
    String? propertyType,
    PropertyLocation? location,
    List<String>? photos,
    List<String>? amenities,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isVerified,
    int? views,
    int? unlocks,
    bool? isFeatured,
    DateTime? featuredUntil,
  }) {
    return Property(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      rent: rent ?? this.rent,
      deposit: deposit ?? this.deposit,
      propertyType: propertyType ?? this.propertyType,
      location: location ?? this.location,
      photos: photos ?? this.photos,
      amenities: amenities ?? this.amenities,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      views: views ?? this.views,
      unlocks: unlocks ?? this.unlocks,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredUntil: featuredUntil ?? this.featuredUntil,
    );
  }
}

class PropertyLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;

  PropertyLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
  });

  factory PropertyLocation.fromMap(Map<String, dynamic> map) {
    return PropertyLocation(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      landmark: map['landmark'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
    };
  }
}

// Property Filters
class PropertyFilters {
  final double? minRent;
  final double? maxRent;
  final List<String>? propertyTypes;
  final String? city;
  final List<String>? amenities;
  final bool? isVerified;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  PropertyFilters({
    this.minRent,
    this.maxRent,
    this.propertyTypes,
    this.city,
    this.amenities,
    this.isVerified,
    this.latitude,
    this.longitude,
    this.radiusKm,
  });

  PropertyFilters copyWith({
    double? minRent,
    double? maxRent,
    List<String>? propertyTypes,
    String? city,
    List<String>? amenities,
    bool? isVerified,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) {
    return PropertyFilters(
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      city: city ?? this.city,
      amenities: amenities ?? this.amenities,
      isVerified: isVerified ?? this.isVerified,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}