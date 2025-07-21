import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../properties/providers/property_provider.dart';
import '../../properties/screens/property_details_screen.dart';

class UnlockedContact {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyImage;
  final String ownerName;
  final String phoneNumber;
  final DateTime unlockedAt;
  final double amountPaid;

  const UnlockedContact({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyImage,
    required this.ownerName,
    required this.phoneNumber,
    required this.unlockedAt,
    required this.amountPaid,
  });
}

class UnlockedContactsScreen extends StatefulWidget {
  const UnlockedContactsScreen({super.key});

  @override
  State<UnlockedContactsScreen> createState() => _UnlockedContactsScreenState();
}

class _UnlockedContactsScreenState extends State<UnlockedContactsScreen> {
  List<UnlockedContact> _unlockedContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnlockedContacts();
  }

  Future<void> _loadUnlockedContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate loading unlocked contacts
      // In a real app, this would fetch from Firebase
      await Future.delayed(const Duration(milliseconds: 800));
      
      final propertyProvider = context.read<PropertyProvider>();
      final properties = propertyProvider.properties;
      
      // Mock data - in real app this would come from user's unlock history
      final mockUnlockedContacts = <UnlockedContact>[
        UnlockedContact(
          id: '1',
          propertyId: properties.isNotEmpty ? properties[0].id : 'demo1',
          propertyTitle: properties.isNotEmpty ? properties[0].title : 'Luxury 2BHK Apartment',
          propertyImage: properties.isNotEmpty ? (properties[0].images.isNotEmpty ? properties[0].images.first : '') : '',
          ownerName: 'Rajesh Kumar',
          phoneNumber: '+91 98765 43210',
          unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
          amountPaid: 10.0,
        ),
        UnlockedContact(
          id: '2',
          propertyId: properties.length > 1 ? properties[1].id : 'demo2',
          propertyTitle: properties.length > 1 ? properties[1].title : 'Spacious 3BHK Villa',
          propertyImage: properties.length > 1 ? (properties[1].images.isNotEmpty ? properties[1].images.first : '') : '',
          ownerName: 'Priya Sharma',
          phoneNumber: '+91 87654 32109',
          unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
          amountPaid: 10.0,
        ),
        UnlockedContact(
          id: '3',
          propertyId: properties.length > 2 ? properties[2].id : 'demo3',
          propertyTitle: properties.length > 2 ? properties[2].title : 'Modern Studio Apartment',
          propertyImage: properties.length > 2 ? (properties[2].images.isNotEmpty ? properties[2].images.first : '') : '',
          ownerName: 'Amit Patel',
          phoneNumber: '+91 76543 21098',
          unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
          amountPaid: 10.0,
        ),
      ];

      setState(() {
        _unlockedContacts = mockUnlockedContacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load unlocked contacts');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorSnackBar('Could not launch phone dialer');
    }
  }

  Future<void> _sendWhatsAppMessage(String phoneNumber, String propertyTitle) async {
    final message = Uri.encodeComponent(
      'Hi! I found your property "$propertyTitle" on ZeroBroker and I\'m interested in viewing it. Could you please share more details?'
    );
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$message';
    
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      _showErrorSnackBar('WhatsApp is not installed');
    }
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
        middle: const Text('Unlocked Contacts'),
      ),
      body: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 20),
            )
          : RefreshIndicator(
              onRefresh: _loadUnlockedContacts,
              child: _unlockedContacts.isEmpty
                  ? _buildEmptyState()
                  : _buildContactsList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  CupertinoIcons.phone,
                  size: 60,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Unlocked Contacts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'When you unlock property owner contacts, they\'ll appear here for easy access.',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Browse Properties'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return Column(
      children: [
        // Summary Card
        Container(
          margin: const EdgeInsets.all(16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total Unlocked',
                '${_unlockedContacts.length}',
                CupertinoIcons.phone_circle,
                CupertinoColors.systemBlue,
              ),
              Container(
                width: 1,
                height: 40,
                color: CupertinoColors.systemGrey4,
              ),
              _buildSummaryItem(
                'Total Spent',
                '₹${(_unlockedContacts.length * 10).toStringAsFixed(0)}',
                CupertinoIcons.money_dollar_circle,
                CupertinoColors.systemGreen,
              ),
            ],
          ),
        ),
        
        // Contacts List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _unlockedContacts.length,
            itemBuilder: (context, index) {
              final contact = _unlockedContacts[index];
              return FadeInUp(
                duration: Duration(milliseconds: 600 + (index * 100)),
                child: _buildContactCard(contact),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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
        ),
      ],
    );
  }

  Widget _buildContactCard(UnlockedContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Property Info Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: contact.propertyImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: contact.propertyImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: CupertinoColors.systemGrey5,
                              child: const Icon(
                                CupertinoIcons.photo,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: CupertinoColors.systemGrey5,
                              child: const Icon(
                                CupertinoIcons.photo,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          )
                        : Container(
                            color: CupertinoColors.systemGrey5,
                            child: const Icon(
                              CupertinoIcons.photo,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.propertyTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlocked ${_formatDate(contact.unlockedAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => PropertyDetailsScreen(
                          propertyId: contact.propertyId,
                        ),
                      ),
                    );
                  },
                  child: const Icon(
                    CupertinoIcons.arrow_right_circle,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Contact Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.person_circle,
                      size: 20,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      contact.ownerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.phone,
                      size: 20,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      contact.phoneNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.systemGreen,
                        onPressed: () => _makePhoneCall(contact.phoneNumber),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(CupertinoIcons.phone, size: 18),
                            SizedBox(width: 8),
                            Text('Call'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.systemBlue,
                        onPressed: () => _sendWhatsAppMessage(
                          contact.phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''),
                          contact.propertyTitle,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(CupertinoIcons.chat_bubble, size: 18),
                            SizedBox(width: 8),
                            Text('WhatsApp'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}