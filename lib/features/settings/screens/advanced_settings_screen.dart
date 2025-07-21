import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _locationServices = true;
  bool _analyticsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR';

  final List<String> _languages = ['English', 'Hindi', 'Kannada', 'Tamil', 'Telugu'];
  final List<String> _currencies = ['INR', 'USD', 'EUR'];

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
            
            // User Profile Section
            FadeInDown(
              duration: const Duration(milliseconds: 300),
              child: _buildUserProfileSection(context),
            ),
            
            const SizedBox(height: 30),
            
            // Appearance Section
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: _buildSection(
                'Appearance',
                [
                  _buildThemeSelector(context),
                  _buildLanguageSelector(context),
                  _buildCurrencySelector(context),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Notifications Section
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: _buildSection(
                'Notifications',
                [
                  _buildNotificationToggle(
                    'Push Notifications',
                    'Receive notifications about new properties and updates',
                    CupertinoIcons.bell,
                    _pushNotifications,
                    (value) => setState(() => _pushNotifications = value),
                  ),
                  _buildNotificationToggle(
                    'Email Notifications',
                    'Receive email updates about your saved properties',
                    CupertinoIcons.mail,
                    _emailNotifications,
                    (value) => setState(() => _emailNotifications = value),
                  ),
                  _buildNotificationToggle(
                    'SMS Notifications',
                    'Receive SMS alerts for important updates',
                    CupertinoIcons.chat_bubble,
                    _smsNotifications,
                    (value) => setState(() => _smsNotifications = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Privacy & Security Section
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: _buildSection(
                'Privacy & Security',
                [
                  _buildNotificationToggle(
                    'Location Services',
                    'Allow app to access your location for better property recommendations',
                    CupertinoIcons.location,
                    _locationServices,
                    (value) => setState(() => _locationServices = value),
                  ),
                  _buildNotificationToggle(
                    'Analytics',
                    'Help improve the app by sharing anonymous usage data',
                    CupertinoIcons.chart_bar,
                    _analyticsEnabled,
                    (value) => setState(() => _analyticsEnabled = value),
                  ),
                  _buildSettingsItem(
                    'Privacy Policy',
                    CupertinoIcons.doc_text,
                    () => _openPrivacyPolicy(),
                  ),
                  _buildSettingsItem(
                    'Terms of Service',
                    CupertinoIcons.doc_checkmark,
                    () => _openTermsOfService(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // App Section
            FadeInDown(
              duration: const Duration(milliseconds: 700),
              child: _buildSection(
                'App',
                [
                  _buildSettingsItem(
                    'Rate App',
                    CupertinoIcons.star,
                    () => _rateApp(),
                  ),
                  _buildSettingsItem(
                    'Share App',
                    CupertinoIcons.share,
                    () => _shareApp(),
                  ),
                  _buildSettingsItem(
                    'Help & Support',
                    CupertinoIcons.question_circle,
                    () => _openSupport(),
                  ),
                  _buildSettingsItem(
                    'About',
                    CupertinoIcons.info_circle,
                    () => _showAbout(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Account Section
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: _buildSection(
                'Account',
                [
                  _buildSettingsItem(
                    'Clear Cache',
                    CupertinoIcons.trash,
                    () => _clearCache(),
                    isDestructive: false,
                  ),
                  _buildSettingsItem(
                    'Sign Out',
                    CupertinoIcons.square_arrow_right,
                    () => _signOut(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                user?.name != null && user!.name.isNotEmpty 
                    ? user.name.substring(0, 1).toUpperCase() 
                    : 'U',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 24,
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
                  user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'user@example.com',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _editProfile(context),
            child: const Icon(
              CupertinoIcons.pencil,
              color: CupertinoColors.systemBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return _buildSettingsItem(
      'Theme',
      CupertinoIcons.moon,
      () => _showThemeSelector(context, themeProvider),
      trailing: Text(
        _getThemeName(themeProvider.themeMode),
        style: const TextStyle(
          color: CupertinoColors.secondaryLabel,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return _buildSettingsItem(
      'Language',
      CupertinoIcons.globe,
      () => _showLanguageSelector(context),
      trailing: Text(
        _selectedLanguage,
        style: const TextStyle(
          color: CupertinoColors.secondaryLabel,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return _buildSettingsItem(
      'Currency',
      CupertinoIcons.money_dollar_circle,
      () => _showCurrencySelector(context),
      trailing: Text(
        _selectedCurrency,
        style: const TextStyle(
          color: CupertinoColors.secondaryLabel,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: CupertinoColors.systemBlue,
            size: 24,
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
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? CupertinoColors.destructiveRed : CupertinoColors.systemBlue,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? CupertinoColors.destructiveRed : CupertinoColors.label,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
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

  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
            child: const Text('Light'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
            child: const Text('Dark'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
            child: const Text('System'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
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
        actions: _languages.map((language) => CupertinoActionSheetAction(
          onPressed: () {
            setState(() => _selectedLanguage = language);
            Navigator.pop(context);
            _showSnackBar('Language changed to $language');
          },
          child: Text(language),
        )).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showCurrencySelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Currency'),
        actions: _currencies.map((currency) => CupertinoActionSheetAction(
          onPressed: () {
            setState(() => _selectedCurrency = currency);
            Navigator.pop(context);
            _showSnackBar('Currency changed to $currency');
          },
          child: Text(currency),
        )).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.pushNamed(context, '/edit-profile');
  }

  void _openPrivacyPolicy() async {
    const url = 'https://zerobroker.com/privacy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showSnackBar('Could not open Privacy Policy');
    }
  }

  void _openTermsOfService() async {
    const url = 'https://zerobroker.com/terms';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showSnackBar('Could not open Terms of Service');
    }
  }

  void _rateApp() async {
    const url = 'https://play.google.com/store/apps/details?id=com.zerobroker.app';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showSnackBar('Could not open app store');
    }
  }

  void _shareApp() {
    _showSnackBar('Share functionality will be implemented with share_plus package');
  }

  void _openSupport() async {
    const url = 'mailto:support@zerobroker.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showSnackBar('Could not open email app');
    }
  }

  void _showAbout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About ZeroBroker'),
        content: const Text(
          'ZeroBroker v1.0.0\n\n'
          'Find properties without paying broker fees. '
          'Pay only ₹10 to unlock contact details.\n\n'
          'Made with ❤️ in India',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Cache cleared successfully');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              authProvider.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}