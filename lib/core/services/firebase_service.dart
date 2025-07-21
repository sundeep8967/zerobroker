import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/property_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _propertiesCollection = 'properties';
  static const String _unlocksCollection = 'unlocks';
  static const String _reportsCollection = 'reports';

  // User Management
  static Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  static Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Property Management
  static Future<String> createProperty(Property property) async {
    try {
      final docRef = await _firestore.collection(_propertiesCollection).add(property.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create property: $e');
    }
  }

  static Future<List<Property>> getProperties({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      Query query = _firestore.collection(_propertiesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      // Apply filters
      if (filters != null) {
        if (filters['propertyType'] != null) {
          query = query.where('propertyType', isEqualTo: filters['propertyType']);
        }
        if (filters['minRent'] != null) {
          query = query.where('rent', isGreaterThanOrEqualTo: filters['minRent']);
        }
        if (filters['maxRent'] != null) {
          query = query.where('rent', isLessThanOrEqualTo: filters['maxRent']);
        }
      }

      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Property.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get properties: $e');
    }
  }

  static Future<Property?> getProperty(String propertyId) async {
    try {
      final doc = await _firestore.collection(_propertiesCollection).doc(propertyId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Property.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get property: $e');
    }
  }

  static Future<void> updateProperty(Property property) async {
    try {
      await _firestore.collection(_propertiesCollection).doc(property.id).update(property.toJson());
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  static Future<void> deleteProperty(String propertyId) async {
    try {
      await _firestore.collection(_propertiesCollection).doc(propertyId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  // Contact Unlock Management
  static Future<void> recordUnlock({
    required String userId,
    required String propertyId,
    required String paymentId,
    required double amount,
  }) async {
    try {
      await _firestore.collection(_unlocksCollection).add({
        'userId': userId,
        'propertyId': propertyId,
        'paymentId': paymentId,
        'amount': amount,
        'unlockedAt': FieldValue.serverTimestamp(),
      });

      // Update property unlock count
      await _firestore.collection(_propertiesCollection).doc(propertyId).update({
        'unlocks': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to record unlock: $e');
    }
  }

  static Future<bool> hasUserUnlockedProperty(String userId, String propertyId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_unlocksCollection)
          .where('userId', isEqualTo: userId)
          .where('propertyId', isEqualTo: propertyId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check unlock status: $e');
    }
  }

  static Future<List<String>> getUserUnlockedProperties(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_unlocksCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()['propertyId'] as String).toList();
    } catch (e) {
      throw Exception('Failed to get unlocked properties: $e');
    }
  }

  // File Upload
  static Future<String> uploadImage(String filePath, String fileName) async {
    try {
      final ref = _storage.ref().child('property_images/$fileName');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<List<String>> uploadMultipleImages(List<String> filePaths) async {
    try {
      final List<String> downloadUrls = [];
      
      for (int i = 0; i < filePaths.length; i++) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final url = await uploadImage(filePaths[i], fileName);
        downloadUrls.add(url);
      }
      
      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  // Search functionality
  static Future<List<Property>> searchProperties(String searchQuery) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // For production, consider using Algolia or ElasticSearch
      final querySnapshot = await _firestore
          .collection(_propertiesCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final properties = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Property.fromJson(data);
      }).toList();

      // Client-side filtering for demo
      final searchLower = searchQuery.toLowerCase();
      return properties.where((property) {
        return property.title.toLowerCase().contains(searchLower) ||
               property.description.toLowerCase().contains(searchLower) ||
               property.location.address.toLowerCase().contains(searchLower) ||
               property.propertyType.toLowerCase().contains(searchLower);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search properties: $e');
    }
  }

  // Analytics
  static Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final propertiesSnapshot = await _firestore.collection(_propertiesCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      final usersSnapshot = await _firestore.collection(_usersCollection).get();
      
      final unlocksSnapshot = await _firestore.collection(_unlocksCollection).get();

      double totalRevenue = 0;
      for (final doc in unlocksSnapshot.docs) {
        totalRevenue += (doc.data()['amount'] as num).toDouble();
      }

      return {
        'totalProperties': propertiesSnapshot.docs.length,
        'totalUsers': usersSnapshot.docs.length,
        'totalUnlocks': unlocksSnapshot.docs.length,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('Failed to get analytics: $e');
    }
  }

  // Reporting
  static Future<void> reportProperty({
    required String propertyId,
    required String userId,
    required String reason,
    String? description,
  }) async {
    try {
      await _firestore.collection(_reportsCollection).add({
        'propertyId': propertyId,
        'userId': userId,
        'reason': reason,
        'description': description,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to report property: $e');
    }
  }
}