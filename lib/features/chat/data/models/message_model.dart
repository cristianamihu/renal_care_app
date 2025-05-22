import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:renal_care_app/features/chat/domain/entities/message.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? attachmentUrl;
  final String? attachmentName;
  final String? attachmentType; // mime-type

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentType,
  });

  factory MessageModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String,
      text: data['text'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      attachmentUrl: data['attachmentUrl'] as String?,
      attachmentName: data['attachmentName'] as String?,
      attachmentType: data['attachmentType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
    if (attachmentUrl != null) map['attachmentUrl'] = attachmentUrl;
    if (attachmentName != null) map['attachmentName'] = attachmentName;
    if (attachmentType != null) map['attachmentType'] = attachmentType;
    return map;
  }

  Message toEntity() => Message(
    id: id,
    senderId: senderId,
    text: text,
    timestamp: timestamp,
    attachmentUrl: attachmentUrl,
    attachmentName: attachmentName,
    attachmentType: attachmentType,
  );
}
