import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final UserPreferences preferences;
  final List<String> unlockedProperties;
  final double walletBalance;
  final int totalUnlocks;
  final UserType userType;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePicture,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    required this.preferences,
    this.unlockedProperties = const [],
    this.walletBalance = 0.0,
    this.totalUnlocks = 0,
    this.userType = UserType.tenant,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      profilePicture: data['profilePicture'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      unlockedProperties: List<String>.from(data['unlockedProperties'] ?? []),
      walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
      totalUnlocks: data['totalUnlocks'] ?? 0,
      userType: UserType.values.firstWhere(
        (type) => type.name == data['userType'],
        orElse: () => UserType.tenant,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'preferences': preferences.toMap(),
      'unlockedProperties': unlockedProperties,
      'walletBalance': walletBalance,
      'totalUnlocks': totalUnlocks,
      'userType': userType.name,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    UserPreferences? preferences,
    List<String>? unlockedProperties,
    double? walletBalance,
    int? totalUnlocks,
    UserType? userType,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
      unlockedProperties: unlockedProperties ?? this.unlockedProperties,
      walletBalance: walletBalance ?? this.walletBalance,
      totalUnlocks: totalUnlocks ?? this.totalUnlocks,
      userType: userType ?? this.userType,
    );
  }
}

class UserPreferences {
  final String? preferredCity;
  final double? minBudget;
  final double? maxBudget;
  final List<String> preferredPropertyTypes;
  final List<String> preferredAmenities;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smsNotifications;

  UserPreferences({
    this.preferredCity,
    this.minBudget,
    this.maxBudget,
    this.preferredPropertyTypes = const [],
    this.preferredAmenities = const [],
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      preferredCity: map['preferredCity'],
      minBudget: map['minBudget']?.toDouble(),
      maxBudget: map['maxBudget']?.toDouble(),
      preferredPropertyTypes: List<String>.from(map['preferredPropertyTypes'] ?? []),
      preferredAmenities: List<String>.from(map['preferredAmenities'] ?? []),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preferredCity': preferredCity,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'preferredPropertyTypes': preferredPropertyTypes,
      'preferredAmenities': preferredAmenities,
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
    };
  }

  UserPreferences copyWith({
    String? preferredCity,
    double? minBudget,
    double? maxBudget,
    List<String>? preferredPropertyTypes,
    List<String>? preferredAmenities,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
  }) {
    return UserPreferences(
      preferredCity: preferredCity ?? this.preferredCity,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      preferredPropertyTypes: preferredPropertyTypes ?? this.preferredPropertyTypes,
      preferredAmenities: preferredAmenities ?? this.preferredAmenities,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
    );
  }
}

enum UserType {
  tenant,
  owner,
  agent,
  admin,
}

// Unlock Transaction Model
class UnlockTransaction {
  final String id;
  final String userId;
  final String propertyId;
  final double amount;
  final String paymentId;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? failureReason;

  UnlockTransaction({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.amount,
    required this.paymentId,
    required this.status,
    required this.createdAt,
    this.failureReason,
  });

  factory UnlockTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UnlockTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      paymentId: data['paymentId'] ?? '',
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      failureReason: data['failureReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'propertyId': propertyId,
      'amount': amount,
      'paymentId': paymentId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'failureReason': failureReason,
    };
  }
}

enum PaymentStatus {
  pending,
  success,
  failed,
  refunded,
}