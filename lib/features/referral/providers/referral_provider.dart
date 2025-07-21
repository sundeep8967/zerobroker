import 'package:flutter/foundation.dart';
import '../../../core/models/referral_model.dart';
import '../../../core/services/referral_service.dart';

class ReferralProvider with ChangeNotifier {
  UserReferralStats? _userStats;
  List<Referral> _userReferrals = [];
  bool _isLoading = false;
  String? _error;

  UserReferralStats? get userStats => _userStats;
  List<Referral> get userReferrals => _userReferrals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserReferralData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await ReferralService.getUserReferralStats(userId);
      final referrals = await ReferralService.getUserReferrals(userId);

      _userStats = stats;
      _userReferrals = referrals;
      _error = null;
    } catch (e) {
      _error = 'Failed to load referral data: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> processReferralCode(String userId, String referralCode) async {
    try {
      final success = await ReferralService.processReferral(userId, referralCode);
      if (success) {
        // Reload data to reflect changes
        await loadUserReferralData(userId);
      }
      return success;
    } catch (e) {
      _error = 'Failed to process referral code: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> useFreeUnlock(String userId) async {
    if (_userStats == null || _userStats!.availableFreeUnlocks <= 0) {
      return false;
    }

    try {
      final success = await ReferralService.useFreeUnlock(userId);
      if (success) {
        // Update local stats
        _userStats = _userStats!.copyWith(
          availableFreeUnlocks: _userStats!.availableFreeUnlocks - 1,
        );
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Failed to use free unlock: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> shareReferralCode(String userName) async {
    if (_userStats == null) return;

    try {
      await ReferralService.shareReferralCode(
        _userStats!.personalReferralCode,
        userName,
      );
    } catch (e) {
      _error = 'Failed to share referral code: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}