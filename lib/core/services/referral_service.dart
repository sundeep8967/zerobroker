import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/referral_model.dart';

class ReferralService {
  static const String _collectionName = 'referrals';
  static const int _referralRewardCredits = 1; // 1 free unlock per referral
  static const int _refereeRewardCredits = 1; // 1 free unlock for new user
  
  // Generate referral code for user
  static String generateReferralCode(String userId) {
    // Create a unique 6-character code based on user ID
    final hash = userId.hashCode.abs();
    return 'ZB${hash.toString().substring(0, 4).padLeft(4, '0')}';
  }
  
  // Share referral link
  static Future<void> shareReferralLink(String userId, String userName) async {
    final referralCode = generateReferralCode(userId);
    final referralLink = 'https://zerobroker.app/ref/$referralCode';
    
    final message = '''Hey! I'm using ZeroBroker - the smartest way to find rental properties!

No Rs.4000 broker fees - just pay Rs.10 to unlock contact details
Use my referral code: $referralCode and get 1 FREE contact unlock!

Download now: $referralLink

- $userName''';
    
    await Share.share(message, subject: 'Join ZeroBroker with my referral!');
  }
  
  // Apply referral code when user signs up
  static Future<bool> applyReferralCode(String newUserId, String referralCode) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Find the referrer by code
      final usersQuery = await firestore
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();
      
      if (usersQuery.docs.isEmpty) {
        return false; // Invalid referral code
      }
      
      final referrerId = usersQuery.docs.first.id;
      
      // Check if this user already used a referral code
      final existingReferral = await firestore
          .collection(_collectionName)
          .where('refereeId', isEqualTo: newUserId)
          .get();
      
      if (existingReferral.docs.isNotEmpty) {
        return false; // User already used a referral code
      }
      
      // Create referral record
      await firestore.collection(_collectionName).add({
        'referrerId': referrerId,
        'refereeId': newUserId,
        'referralCode': referralCode,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'completed',
        'referrerReward': _referralRewardCredits,
        'refereeReward': _refereeRewardCredits,
      });
      
      // Update both users' credits
      final batch = firestore.batch();
      
      // Add credits to referrer
      final referrerRef = firestore.collection('users').doc(referrerId);
      batch.update(referrerRef, {
        'freeUnlocks': FieldValue.increment(_referralRewardCredits),
        'totalReferrals': FieldValue.increment(1),
      });
      
      // Add credits to referee (new user)
      final refereeRef = firestore.collection('users').doc(newUserId);
      batch.update(refereeRef, {
        'freeUnlocks': FieldValue.increment(_refereeRewardCredits),
        'usedReferralCode': referralCode,
      });
      
      await batch.commit();
      return true;
      
    } catch (e) {
      debugPrint('Error applying referral code: $e');
      return false;
    }
  }
  
  // Get user's referral stats
  static Future<UserReferralStats> getUserReferralStats(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Get referrals made by this user
      final referralsQuery = await firestore
          .collection(_collectionName)
          .where('referrerId', isEqualTo: userId)
          .get();
      
      final totalReferrals = referralsQuery.docs.length;
      final totalEarned = totalReferrals * _referralRewardCredits;
      
      // Get recent referrals (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentReferrals = referralsQuery.docs.where((doc) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        return createdAt != null && createdAt.isAfter(thirtyDaysAgo);
      }).length;
      
      return UserReferralStats(
        userId: userId,
        personalReferralCode: generateReferralCode(userId),
        totalReferrals: totalReferrals,
        successfulReferrals: totalReferrals,
        totalRewardsEarned: totalEarned,
        availableFreeUnlocks: totalEarned,
        lastReferralDate: referralsQuery.docs.isNotEmpty 
            ? (referralsQuery.docs.last.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()
            : DateTime.now(),
      );
      
    } catch (e) {
      debugPrint('Error getting referral stats: $e');
      return UserReferralStats(
        userId: userId,
        personalReferralCode: generateReferralCode(userId),
        totalReferrals: 0,
        successfulReferrals: 0,
        totalRewardsEarned: 0,
        availableFreeUnlocks: 0,
        lastReferralDate: DateTime.now(),
      );
    }
  }
  
  // Get user's referrals
  static Future<List<Referral>> getUserReferrals(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      final referralsQuery = await firestore
          .collection(_collectionName)
          .where('referrerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return referralsQuery.docs.map((doc) => Referral.fromFirestore(doc)).toList();
      
    } catch (e) {
      debugPrint('Error getting user referrals: $e');
      return [];
    }
  }
  
  // Validate referral code format
  static bool isValidReferralCode(String code) {
    // ZeroBroker referral codes are 6 characters: ZB + 4 digits
    final regex = RegExp(r'^ZB\d{4}$');
    return regex.hasMatch(code);
  }

  // Process referral code
  static Future<bool> processReferral(String userId, String referralCode) async {
    return await applyReferralCode(userId, referralCode);
  }
  
  // Use free unlock
  static Future<bool> useFreeUnlock(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(userId);
      
      // Get current user data
      final userDoc = await userRef.get();
      if (!userDoc.exists) return false;
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final currentUnlocks = userData['freeUnlocks'] ?? 0;
      
      if (currentUnlocks <= 0) return false;
      
      // Decrement free unlocks
      await userRef.update({
        'freeUnlocks': FieldValue.increment(-1),
      });
      
      return true;
    } catch (e) {
      debugPrint('Error using free unlock: $e');
      return false;
    }
  }
  
  // Share referral code
  static Future<void> shareReferralCode(String referralCode, String userName) async {
    final referralLink = 'https://zerobroker.app/ref/$referralCode';
    
    final message = '''Hey! I'm using ZeroBroker - the smartest way to find rental properties!

No Rs.4000 broker fees - just pay Rs.10 to unlock contact details
Use my referral code: $referralCode and get 1 FREE contact unlock!

Download now: $referralLink

- $userName''';
    
    await Share.share(message, subject: 'Join ZeroBroker with my referral!');
  }
  
  // Get leaderboard of top referrers
  static Future<List<ReferralLeaderboardEntry>> getReferralLeaderboard({int limit = 10}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      final usersQuery = await firestore
          .collection('users')
          .where('totalReferrals', isGreaterThan: 0)
          .orderBy('totalReferrals', descending: true)
          .limit(limit)
          .get();
      
      return usersQuery.docs.map((doc) {
        final data = doc.data();
        return ReferralLeaderboardEntry(
          userId: doc.id,
          userName: data['name'] ?? 'Anonymous',
          totalReferrals: data['totalReferrals'] ?? 0,
          profilePicture: data['profilePicture'],
        );
      }).toList();
      
    } catch (e) {
      debugPrint('Error getting referral leaderboard: $e');
      return [];
    }
  }
}

class ReferralStats {
  final int totalReferrals;
  final int totalCreditsEarned;
  final int recentReferrals;
  final String referralCode;
  
  ReferralStats({
    required this.totalReferrals,
    required this.totalCreditsEarned,
    required this.recentReferrals,
    required this.referralCode,
  });
}

class ReferralLeaderboardEntry {
  final String userId;
  final String userName;
  final int totalReferrals;
  final String? profilePicture;
  
  ReferralLeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.totalReferrals,
    this.profilePicture,
  });
}