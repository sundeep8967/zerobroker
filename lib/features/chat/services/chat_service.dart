import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../../../core/services/firebase_service.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create or get existing chat room
  static Future<String?> createOrGetChatRoom({
    required String propertyId,
    required String propertyOwnerId,
    required String propertyTitle,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final interestedUserId = currentUser.uid;

      // Check if chat room already exists
      final existingChatQuery = await _firestore
          .collection('chatRooms')
          .where('propertyId', isEqualTo: propertyId)
          .where('interestedUserId', isEqualTo: interestedUserId)
          .where('propertyOwnerId', isEqualTo: propertyOwnerId)
          .limit(1)
          .get();

      if (existingChatQuery.docs.isNotEmpty) {
        return existingChatQuery.docs.first.id;
      }

      // Create new chat room
      final chatRoom = ChatRoom(
        id: '',
        propertyId: propertyId,
        propertyOwnerId: propertyOwnerId,
        interestedUserId: interestedUserId,
        propertyTitle: propertyTitle,
        lastMessage: 'Chat started',
        lastMessageTime: DateTime.now(),
        readStatus: {
          interestedUserId: true,
          propertyOwnerId: false,
        },
        isActive: true,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('chatRooms').add(chatRoom.toJson());

      // Send initial system message
      await sendMessage(
        chatRoomId: docRef.id,
        message: 'Chat started for ${propertyTitle}',
        type: MessageType.system,
      );

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      return null;
    }
  }

  // Send message
  static Future<bool> sendMessage({
    required String chatRoomId,
    required String message,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Get user name
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userName = userDoc.data()?['name'] ?? 'User';

      final chatMessage = ChatMessage(
        id: '',
        chatRoomId: chatRoomId,
        senderId: currentUser.uid,
        senderName: userName,
        message: message,
        type: type,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _firestore.collection('chatMessages').add(chatMessage.toJson());

      // Update chat room with last message
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'readStatus.${currentUser.uid}': true,
      });

      // Send push notification to other user
      await _sendChatNotification(chatRoomId, message, userName);

      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  // Get chat rooms for current user
  static Stream<List<ChatRoom>> getUserChatRooms() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('chatRooms')
        .where('isActive', isEqualTo: true)
        .where(Filter.or(
          Filter('propertyOwnerId', isEqualTo: currentUser.uid),
          Filter('interestedUserId', isEqualTo: currentUser.uid),
        ))
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ChatRoom.fromJson(data);
      }).toList();
    });
  }

  // Get messages for a chat room
  static Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _firestore
        .collection('chatMessages')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ChatMessage.fromJson(data);
      }).toList();
    });
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Update chat room read status
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'readStatus.${currentUser.uid}': true,
      });

      // Mark individual messages as read
      final unreadMessages = await _firestore
          .collection('chatMessages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .where('senderId', isNotEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Get unread message count
  static Stream<int> getUnreadMessageCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection('chatRooms')
        .where('isActive', isEqualTo: true)
        .where(Filter.or(
          Filter('propertyOwnerId', isEqualTo: currentUser.uid),
          Filter('interestedUserId', isEqualTo: currentUser.uid),
        ))
        .snapshots()
        .map((snapshot) {
      int unreadCount = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final readStatus = Map<String, bool>.from(data['readStatus'] ?? {});
        if (readStatus[currentUser.uid] != true) {
          unreadCount++;
        }
      }
      return unreadCount;
    });
  }

  // Send image message
  static Future<bool> sendImageMessage({
    required String chatRoomId,
    required String imagePath,
    String? caption,
  }) async {
    try {
      // Upload image to Firebase Storage
      final fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageUrl = await FirebaseService.uploadImage(imagePath, 'chat_images/$fileName');

      if (imageUrl == null) return false;

      return await sendMessage(
        chatRoomId: chatRoomId,
        message: caption ?? 'Image',
        type: MessageType.image,
        imageUrl: imageUrl,
      );
    } catch (e) {
      debugPrint('Error sending image message: $e');
      return false;
    }
  }

  // Delete chat room
  static Future<bool> deleteChatRoom(String chatRoomId) async {
    try {
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error deleting chat room: $e');
      return false;
    }
  }

  // Block user in chat
  static Future<bool> blockUserInChat(String chatRoomId, String userId) async {
    try {
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'blockedUsers': FieldValue.arrayUnion([userId]),
      });
      return true;
    } catch (e) {
      debugPrint('Error blocking user: $e');
      return false;
    }
  }

  // Send push notification for chat
  static Future<void> _sendChatNotification(
    String chatRoomId,
    String message,
    String senderName,
  ) async {
    try {
      // Get chat room details
      final chatRoomDoc = await _firestore.collection('chatRooms').doc(chatRoomId).get();
      if (!chatRoomDoc.exists) return;

      final chatRoom = ChatRoom.fromJson({...chatRoomDoc.data()!, 'id': chatRoomDoc.id});
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Determine recipient
      final recipientId = currentUser.uid == chatRoom.propertyOwnerId
          ? chatRoom.interestedUserId
          : chatRoom.propertyOwnerId;

      // Get recipient's FCM tokens
      final recipientDoc = await _firestore.collection('users').doc(recipientId).get();
      final recipientData = recipientDoc.data();
      
      if (recipientData == null || recipientData['fcmTokens'] == null) return;

      // Create notification
      await _firestore.collection('notifications').add({
        'userId': recipientId,
        'type': 'chat_message',
        'title': 'New message from $senderName',
        'body': message,
        'data': {
          'chatRoomId': chatRoomId,
          'propertyId': chatRoom.propertyId,
          'type': 'chat',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      debugPrint('Error sending chat notification: $e');
    }
  }

  // Get chat statistics
  static Future<Map<String, dynamic>> getChatStatistics() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return {};

      final chatRoomsSnapshot = await _firestore
          .collection('chatRooms')
          .where(Filter.or(
            Filter('propertyOwnerId', isEqualTo: currentUser.uid),
            Filter('interestedUserId', isEqualTo: currentUser.uid),
          ))
          .get();

      final messagesSnapshot = await _firestore
          .collection('chatMessages')
          .where('senderId', isEqualTo: currentUser.uid)
          .get();

      return {
        'totalChats': chatRoomsSnapshot.docs.length,
        'activeChats': chatRoomsSnapshot.docs
            .where((doc) => doc.data()['isActive'] == true)
            .length,
        'totalMessagesSent': messagesSnapshot.docs.length,
        'averageResponseTime': '2 hours', // This would be calculated from actual data
      };
    } catch (e) {
      debugPrint('Error getting chat statistics: $e');
      return {};
    }
  }
}