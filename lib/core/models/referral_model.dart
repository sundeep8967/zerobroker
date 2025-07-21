import 'package:cloud_firestore/cloud_firestore.dart';

class Referral {
  final String id;
  final String referrerId;
  final String referredUserId;
  final String referralCode;
  final DateTime createdAt;
  final bool isRewardClaimed;
  final int rewardAmount; // Number of free unlocks earned
  final ReferralStatus status;

  const Referral({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    required this.referralCode,
    required this.createdAt,
    this.isRewardClaimed = false,
    this.rewardAmount = 1,
    this.status = ReferralStatus.pending,
  });

  factory Referral.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Referral(
      id: doc.id,
      referrerId: data['referrerId'] ?? '',
      referredUserId: data['referredUserId'] ?? '',
      referralCode: data['referralCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRewardClaimed: data['isRewardClaimed'] ?? false,
      rewardAmount: data['rewardAmount'] ?? 1,
      status: ReferralStatus.values.firstWhere(
        (e) => e.toString() == 'ReferralStatus.${data['status']}',
        orElse: () => ReferralStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'referrerId': referrerId,
      'referredUserId': referredUserId,
      'referralCode': referralCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRewardClaimed': isRewardClaimed,
      'rewardAmount': rewardAmount,
      'status': status.toString().split('.').last,
    };
  }

  Referral copyWith({
    String? id,
    String? referrerId,
    String? referredUserId,
    String? referralCode,
    DateTime? createdAt,
    bool? isRewardClaimed,
    int? rewardAmount,
    ReferralStatus? status,
  }) {
    return Referral(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      referredUserId: referredUserId ?? this.referredUserId,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt ?? this.createdAt,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      status: status ?? this.status,
    );
  }
}

enum ReferralStatus {
  pending,
  completed,
  expired,
}

class UserReferralStats {
  final String userId;
  final String personalReferralCode;
  final int totalReferrals;
  final int successfulReferrals;
  final int totalRewardsEarned;
  final int availableFreeUnlocks;
  final DateTime lastReferralDate;

  const UserReferralStats({
    required this.userId,
    required this.personalReferralCode,
    this.totalReferrals = 0,
    this.successfulReferrals = 0,
    this.totalRewardsEarned = 0,
    this.availableFreeUnlocks = 0,
    required this.lastReferralDate,
  });

  factory UserReferralStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserReferralStats(
      userId: doc.id,
      personalReferralCode: data['personalReferralCode'] ?? '',
      totalReferrals: data['totalReferrals'] ?? 0,
      successfulReferrals: data['successfulReferrals'] ?? 0,
      totalRewardsEarned: data['totalRewardsEarned'] ?? 0,
      availableFreeUnlocks: data['availableFreeUnlocks'] ?? 0,
      lastReferralDate: data['lastReferralDate'] != null
          ? (data['lastReferralDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'personalReferralCode': personalReferralCode,
      'totalReferrals': totalReferrals,
      'successfulReferrals': successfulReferrals,
      'totalRewardsEarned': totalRewardsEarned,
      'availableFreeUnlocks': availableFreeUnlocks,
      'lastReferralDate': Timestamp.fromDate(lastReferralDate),
    };
  }

  UserReferralStats copyWith({
    String? userId,
    String? personalReferralCode,
    int? totalReferrals,
    int? successfulReferrals,
    int? totalRewardsEarned,
    int? availableFreeUnlocks,
    DateTime? lastReferralDate,
  }) {
    return UserReferralStats(
      userId: userId ?? this.userId,
      personalReferralCode: personalReferralCode ?? this.personalReferralCode,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      successfulReferrals: successfulReferrals ?? this.successfulReferrals,
      totalRewardsEarned: totalRewardsEarned ?? this.totalRewardsEarned,
      availableFreeUnlocks: availableFreeUnlocks ?? this.availableFreeUnlocks,
      lastReferralDate: lastReferralDate ?? this.lastReferralDate,
    );
  }
}