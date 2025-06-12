import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/chat/domain/entities/chat_room.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final String createdBy;
  final DateTime lastMessageAt;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.createdBy,
    required this.lastMessageAt,
  });

  factory ChatRoomModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] as List),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] as String,
      lastMessageAt:
          (data['lastMessageAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'participants': participants,
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
    'lastMessageAt': Timestamp.fromDate(lastMessageAt),
  };

  /// Convertește DTO-ul în entitatea de domain
  ChatRoom toEntity() {
    return ChatRoom(
      id: id,
      participants: participants,
      createdAt: createdAt,
      createdBy: createdBy,
      lastMessageAt: lastMessageAt,
    );
  }
}
