import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../properties/screens/favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: const Text('Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Implement settings navigation
          },
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              size: 40,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'John Doe',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '+91 98765 43210',
            style: TextStyle(
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
              // TODO: Implement edit profile
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

  Widget _buildMenuSection(BuildContext context) {
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
              // TODO: Navigate to my properties
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
              // TODO: Navigate to unlocked contacts
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Payment History',
            CupertinoIcons.creditcard,
            () {
              // TODO: Navigate to payment history
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Help & Support',
            CupertinoIcons.question_circle,
            () {
              // TODO: Navigate to help
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'About',
            CupertinoIcons.info_circle,
            () {
              // TODO: Navigate to about
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Logout',
            CupertinoIcons.square_arrow_right,
            () {
              // TODO: Implement logout
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