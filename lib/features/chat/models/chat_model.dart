import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String propertyId;
  final String propertyOwnerId;
  final String interestedUserId;
  final String propertyTitle;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, bool> readStatus;
  final bool isActive;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.propertyId,
    required this.propertyOwnerId,
    required this.interestedUserId,
    required this.propertyTitle,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.readStatus,
    required this.isActive,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      propertyOwnerId: json['propertyOwnerId'] ?? '',
      interestedUserId: json['interestedUserId'] ?? '',
      propertyTitle: json['propertyTitle'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readStatus: Map<String, bool>.from(json['readStatus'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'propertyOwnerId': propertyOwnerId,
      'interestedUserId': interestedUserId,
      'propertyTitle': propertyTitle,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'readStatus': readStatus,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ChatRoom copyWith({
    String? id,
    String? propertyId,
    String? propertyOwnerId,
    String? interestedUserId,
    String? propertyTitle,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, bool>? readStatus,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyOwnerId: propertyOwnerId ?? this.propertyOwnerId,
      interestedUserId: interestedUserId ?? this.interestedUserId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      readStatus: readStatus ?? this.readStatus,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String message;
  final MessageType type;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.type,
    this.imageUrl,
    required this.timestamp,
    required this.isRead,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      chatRoomId: json['chatRoomId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      imageUrl: json['imageUrl'],
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? message,
    MessageType? type,
    String? imageUrl,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum MessageType {
  text,
  image,
  system,
  propertyInfo,
}

class QuickReply {
  final String text;
  final String? action;

  QuickReply({
    required this.text,
    this.action,
  });

  static List<QuickReply> getPropertyQuickReplies() {
    return [
      QuickReply(text: "Is this property still available?"),
      QuickReply(text: "Can I schedule a visit?"),
      QuickReply(text: "What's included in the rent?"),
      QuickReply(text: "Are pets allowed?"),
      QuickReply(text: "When is the earliest move-in date?"),
      QuickReply(text: "Can you share more photos?"),
    ];
  }

  static List<QuickReply> getOwnerQuickReplies() {
    return [
      QuickReply(text: "Yes, it's available!"),
      QuickReply(text: "Sure, when would you like to visit?"),
      QuickReply(text: "Let me share the details..."),
      QuickReply(text: "I'll send you more photos"),
      QuickReply(text: "You can move in immediately"),
    ];
  }
}