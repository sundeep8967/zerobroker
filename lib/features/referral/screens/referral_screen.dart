import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/services/referral_service.dart';
import '../../../core/models/referral_model.dart';
import '../../auth/providers/auth_provider.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  UserReferralStats? _userStats;
  List<Referral> _userReferrals = [];
  bool _isLoading = true;
  final TextEditingController _referralCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadReferralData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? 'demo_user';

    try {
      final stats = await ReferralService.getUserReferralStats(userId);
      final referrals = await ReferralService.getUserReferrals(userId);

      setState(() {
        _userStats = stats;
        _userReferrals = referrals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load referral data');
    }
  }

  Future<void> _shareReferralCode() async {
    if (_userStats == null) return;

    HapticFeedback.mediumImpact();
    
    final authProvider = context.read<AuthProvider>();
    final userName = authProvider.currentUser?.name ?? 'ZeroBroker User';

    await ReferralService.shareReferralCode(
      _userStats!.personalReferralCode,
      userName,
    );
  }

  Future<void> _copyReferralCode() async {
    if (_userStats == null) return;

    HapticFeedback.lightImpact();
    
    await Clipboard.setData(
      ClipboardData(text: _userStats!.personalReferralCode),
    );

    _showSuccessSnackBar('Referral code copied to clipboard!');
  }

  Future<void> _enterReferralCode() async {
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Enter Referral Code'),
        content: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Enter a friend\'s referral code to get bonus unlocks!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _referralCodeController,
              placeholder: 'e.g., ABC1234',
              textCapitalization: TextCapitalization.characters,
              maxLength: 7,
              onChanged: (value) {
                _referralCodeController.text = value.toUpperCase();
                _referralCodeController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _referralCodeController.text.length),
                );
              },
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(_referralCodeController.text.trim());
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _processReferralCode(result);
    }
  }

  Future<void> _processReferralCode(String referralCode) async {
    if (!ReferralService.isValidReferralCode(referralCode)) {
      _showErrorSnackBar('Invalid referral code format');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? 'demo_user';

    final success = await ReferralService.processReferral(userId, referralCode);

    if (success) {
      _showSuccessSnackBar('Referral code applied! You earned 1 free unlock!');
      _loadReferralData(); // Refresh data
    } else {
      _showErrorSnackBar('Invalid referral code or already used');
    }

    _referralCodeController.clear();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CupertinoColors.systemGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CupertinoColors.systemRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: const Text('Referral Program'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _enterReferralCode,
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 20),
            )
          : RefreshIndicator(
              onRefresh: _loadReferralData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 20),
                    _buildReferralCodeCard(),
                    const SizedBox(height: 20),
                    _buildHowItWorksCard(),
                    const SizedBox(height: 20),
                    _buildReferralHistoryCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    if (_userStats == null) return const SizedBox.shrink();

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Referral Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Free Unlocks',
                    '${_userStats!.availableFreeUnlocks}',
                    CupertinoIcons.gift,
                    CupertinoColors.systemGreen,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Successful Referrals',
                    '${_userStats!.successfulReferrals}',
                    CupertinoIcons.person_2,
                    CupertinoColors.systemBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Rewards',
                    '${_userStats!.totalRewardsEarned}',
                    CupertinoIcons.star,
                    CupertinoColors.systemOrange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Referrals',
                    '${_userStats!.totalReferrals}',
                    CupertinoIcons.chart_bar,
                    CupertinoColors.systemPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard() {
    if (_userStats == null) return const SizedBox.shrink();

    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              CupertinoColors.systemBlue,
              CupertinoColors.systemPurple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Referral Code',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _userStats!.personalReferralCode,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _copyReferralCode,
                    child: const Icon(
                      CupertinoIcons.doc_on_clipboard,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: CupertinoColors.white,
                onPressed: _shareReferralCode,
                child: const Text(
                  'Share with Friends',
                  style: TextStyle(
                    color: CupertinoColors.systemBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How It Works',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildHowItWorksStep(
              '1',
              'Share Your Code',
              'Share your unique referral code with friends',
              CupertinoIcons.share,
            ),
            _buildHowItWorksStep(
              '2',
              'Friend Signs Up',
              'Your friend downloads the app and enters your code',
              CupertinoIcons.person_add,
            ),
            _buildHowItWorksStep(
              '3',
              'Earn Rewards',
              'Both of you get 1 free contact unlock!',
              CupertinoIcons.gift,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksStep(String number, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            icon,
            color: CupertinoColors.systemBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralHistoryCard() {
    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Referral History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (_userReferrals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No referrals yet. Start sharing your code!',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userReferrals.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final referral = _userReferrals[index];
                  return _buildReferralHistoryItem(referral);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralHistoryItem(Referral referral) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(referral.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getStatusIcon(referral.status),
              color: _getStatusColor(referral.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral ${referral.referralCode}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(referral.createdAt),
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(referral.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${referral.rewardAmount}',
              style: TextStyle(
                color: _getStatusColor(referral.status),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ReferralStatus status) {
    switch (status) {
      case ReferralStatus.completed:
        return CupertinoColors.systemGreen;
      case ReferralStatus.pending:
        return CupertinoColors.systemOrange;
      case ReferralStatus.expired:
        return CupertinoColors.systemRed;
    }
  }

  IconData _getStatusIcon(ReferralStatus status) {
    switch (status) {
      case ReferralStatus.completed:
        return CupertinoIcons.checkmark_circle;
      case ReferralStatus.pending:
        return CupertinoIcons.clock;
      case ReferralStatus.expired:
        return CupertinoIcons.xmark_circle;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}