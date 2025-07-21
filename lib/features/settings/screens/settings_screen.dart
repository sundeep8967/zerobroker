import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildSection(
              'Appearance',
              [
                _buildThemeSelector(context),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'App',
              [
                _buildSettingsItem(
                  'Notifications',
                  CupertinoIcons.bell,
                  () => _showComingSoon(context),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  'Language',
                  CupertinoIcons.globe,
                  () => _showLanguageSelector(context),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  'Privacy Policy',
                  CupertinoIcons.doc_text,
                  () => _showComingSoon(context),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  'Terms of Service',
                  CupertinoIcons.doc_checkmark,
                  () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Support',
              [
                _buildSettingsItem(
                  'Help Center',
                  CupertinoIcons.question_circle,
                  () => _showComingSoon(context),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  'Contact Us',
                  CupertinoIcons.mail,
                  () => _showComingSoon(context),
                ),
                _buildDivider(),
                _buildSettingsItem(
                  'Rate App',
                  CupertinoIcons.star,
                  () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'About',
              [
                _buildInfoItem('Version', '1.0.0'),
                _buildDivider(),
                _buildInfoItem('Build', '1'),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.moon,
                color: CupertinoColors.systemBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Theme',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showThemeSelector(context, themeProvider),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      themeProvider.currentThemeName,
                      style: const TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      color: CupertinoColors.secondaryLabel,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: CupertinoColors.systemBlue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.secondaryLabel,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: CupertinoColors.secondaryLabel,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 52),
      height: 0.5,
      color: CupertinoColors.separator,
    );
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.system);
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.device_phone_portrait),
                const SizedBox(width: 8),
                const Text('System'),
                if (themeProvider.themeMode == ThemeMode.system)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, color: CupertinoColors.systemBlue),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.light);
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.sun_max),
                const SizedBox(width: 8),
                const Text('Light'),
                if (themeProvider.themeMode == ThemeMode.light)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, color: CupertinoColors.systemBlue),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.dark);
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.moon),
                const SizedBox(width: 8),
                const Text('Dark'),
                if (themeProvider.themeMode == ThemeMode.dark)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, color: CupertinoColors.systemBlue),
                  ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Language'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🇺🇸'),
                SizedBox(width: 8),
                Text('English'),
                SizedBox(width: 8),
                Icon(CupertinoIcons.checkmark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🇮🇳'),
                SizedBox(width: 8),
                Text('हिंदी (Coming Soon)'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🇮🇳'),
                SizedBox(width: 8),
                Text('தமிழ் (Coming Soon)'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}