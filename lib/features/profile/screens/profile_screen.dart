import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../properties/screens/favorites_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/models/user_model.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: const Text('Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Navigate to settings screen
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileHeader(user, context),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildMenuSection(context, authProvider),
          ],
        ),
      ),
    );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Logout'),
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: CupertinoColors.systemGrey4,
                width: 2,
              ),
            ),
            child: user?.profilePicture != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: Image.network(
                      user!.profilePicture!,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          CupertinoIcons.person_fill,
                          size: 40,
                          color: CupertinoColors.white,
                        );
                      },
                    ),
                  )
                : const Icon(
                    CupertinoIcons.person_fill,
                    size: 40,
                    color: CupertinoColors.white,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.phone ?? '+91 98765 43210',
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            color: CupertinoColors.systemBlue,
            borderRadius: BorderRadius.circular(20),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            child: const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Properties', '3', CupertinoIcons.house_fill),
          _buildStatItem('Unlocked', '12', CupertinoIcons.phone_fill),
          _buildStatItem('Saved', '8', CupertinoIcons.heart_fill),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color: CupertinoColors.systemBlue,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            'My Properties',
            CupertinoIcons.house,
            () {
              // Navigate to properties list filtered by current user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('My Properties feature coming soon!')),
            );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Saved Properties',
            CupertinoIcons.heart,
            () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Unlocked Contacts',
            CupertinoIcons.phone,
            () {
              // Navigate to unlocked contacts screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unlocked Contacts feature coming soon!')),
            );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Payment History',
            CupertinoIcons.creditcard,
            () {
              // Navigate to payment history screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment History feature coming soon!')),
            );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Help & Support',
            CupertinoIcons.question_circle,
            () {
              // Navigate to help & support screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help & Support feature coming soon!')),
            );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'About',
            CupertinoIcons.info_circle,
            () {
              // Navigate to about screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('About ZeroBroker v1.0.0')),
            );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Logout',
            CupertinoIcons.square_arrow_right,
            () {
              _showLogoutDialog(context, authProvider);
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive 
                ? CupertinoColors.systemRed 
                : CupertinoColors.systemGrey,
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive 
                    ? CupertinoColors.systemRed 
                    : CupertinoColors.label,
              ),
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.systemGrey3,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.only(left: 54),
      color: CupertinoColors.systemGrey4,
    );
  }
}