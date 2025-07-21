import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize notification service
  static Future<void> initialize() async {
    // Request permission for iOS
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get initial message if app was opened from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Get and save FCM token
    await _saveFCMToken();
  }

  // Save FCM token to user document
  static Future<void> _saveFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final token = await _messaging.getToken();
      if (token == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmTokens': FieldValue.arrayUnion([newToken]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // Show local notification
    await _showLocalNotification(message);
    
    // Save notification to Firestore
    await _saveNotificationToFirestore(message);
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'zerobroker_channel',
      'ZeroBroker Notifications',
      channelDescription: 'Notifications for ZeroBroker app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'ZeroBroker',
      message.notification?.body ?? 'You have a new notification',
      details,
      payload: message.data['propertyId'],
    );
  }

  // Save notification to Firestore
  static Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('notifications').add({
        'userId': user.uid,
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': message.data,
        'type': message.data['type'] ?? 'general',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    
    // Navigate based on notification type
    final type = message.data['type'];
    final propertyId = message.data['propertyId'];
    
    if (type == 'property' && propertyId != null) {
      // Navigate to property details
      // This would be handled by your navigation service
      NavigationService.navigateToProperty(propertyId);
    }
  }

  // Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      // Navigate to property details
      NavigationService.navigateToProperty(response.payload!);
    }
  }

  // Get user notifications
  static Stream<List<NotificationModel>> getUserNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  static Future<void> markAllAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('read', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Get unread notification count
  static Stream<int> getUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Subscribe to property updates for a specific area
  static Future<void> subscribeToAreaUpdates(String area) async {
    try {
      await _messaging.subscribeToTopic('area_${area.toLowerCase().replaceAll(' ', '_')}');
    } catch (e) {
      debugPrint('Error subscribing to area updates: $e');
    }
  }

  // Unsubscribe from property updates for a specific area
  static Future<void> unsubscribeFromAreaUpdates(String area) async {
    try {
      await _messaging.unsubscribeFromTopic('area_${area.toLowerCase().replaceAll(' ', '_')}');
    } catch (e) {
      debugPrint('Error unsubscribing from area updates: $e');
    }
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background message processing here
}

// Navigation service (you would implement this based on your routing)
class NavigationService {
  static void navigateToProperty(String propertyId) {
    // Implement navigation to property details
    debugPrint('Navigate to property: $propertyId');
  }
}

// Notification model
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String type;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      type: json['type'] ?? 'general',
      read: json['read'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}