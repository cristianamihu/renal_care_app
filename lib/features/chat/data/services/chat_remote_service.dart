import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:renal_care_app/features/chat/data/models/chat_room_model.dart';
import 'package:renal_care_app/features/chat/data/models/message_model.dart';
import 'package:renal_care_app/features/chat/domain/entities/patient_info.dart';

class ChatRemoteService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Constructor care permite injectarea unui FirebaseFirestore (utile la testare)
  ChatRemoteService({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  // Listare chat rooms pentru un user (pacient sau doctor)
  Future<List<ChatRoomModel>> listChatRooms(String uid) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .get()
        .then((snap) => snap.docs.map(ChatRoomModel.fromDocument).toList());
  }

  Stream<List<ChatRoomModel>> watchChatRooms(String uid) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ChatRoomModel.fromDocument).toList());
  }

  // Creare chat room nou între doctor și pacient — variantă tipată
  Future<ChatRoomModel> createChatRoom({
    required String doctorUid,
    required String patientUid,
  }) async {
    final ref = _firestore.collection('chat_rooms').doc();

    // construim modelul cu toate câmpurile
    final room = ChatRoomModel(
      id: ref.id,
      participants: [doctorUid, patientUid],
      createdAt: DateTime.now(),
      createdBy: doctorUid,
    );

    // salvăm JSON-ul modelului în Firestore
    await ref.set(room.toJson());

    // returnăm modelul complet
    return room;
  }

  // Flux de mesaje dintr-un chat room
  Stream<List<MessageModel>> watchMessages(String roomId) => _firestore
      .collection('chat_rooms')
      .doc(roomId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map(
        (snap) =>
            // aici poți adăuga transformări, filtrări, logging etc.
            snap.docs.map(MessageModel.fromDocument).toList(),
      );

  // Trimitere mesaj
  Future<MessageModel> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
    String? attachmentPath,
    String? attachmentName,
    String? attachmentType,
  }) async {
    // Creăm referința cu un ID nou
    final docRef =
        _firestore
            .collection('chat_rooms')
            .doc(roomId)
            .collection('messages')
            .doc();
    String? url;
    if (attachmentPath != null) {
      url = await uploadFile(
        roomId: roomId,
        messageId: docRef.id,
        localPath: attachmentPath,
        filename: attachmentName!,
      );
    }
    // Pregătim timestamp-ul și modelul
    final model = MessageModel(
      id: docRef.id,
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
      attachmentUrl: url,
      attachmentName: attachmentName,
      attachmentType: attachmentType,
    );

    // Salvăm JSON-ul modelului
    await docRef.set(model.toJson());

    // Returnăm modelul complet (utile pentru UI)
    return model;
  }

  /// Caută pacienți al căror email începe cu [query],
  /// întoarce lista de UID + email (+ opțional nume)
  Future<List<PatientInfo>> searchPatients(String query) async {
    final snap =
        await _firestore
            .collection('users')
            .where('role', isEqualTo: 'patient')
            // prefix search pe câmpul email
            .where('email', isGreaterThanOrEqualTo: query)
            .where('email', isLessThanOrEqualTo: '$query\uf8ff')
            .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return PatientInfo(
        uid: doc.id,
        email: data['email'] as String,
        name: data['name'] as String?, // dacă vrei să afișezi și numele
      );
    }).toList();
  }

  /// Firestore: Ia ultimul mesaj (DTO) sau null dacă nu există
  Future<MessageModel?> getLastMessage(String roomId) async {
    final snap =
        await _firestore
            .collection('chat_rooms')
            .doc(roomId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
    if (snap.docs.isEmpty) return null;
    return MessageModel.fromDocument(snap.docs.first);
  }

  /// Upload generic file în Storage și returnează URL-ul
  Future<String> uploadFile({
    required String roomId,
    required String messageId,
    required String localPath,
    required String filename,
  }) async {
    final ref = _storage.ref().child(
      'chat_rooms/$roomId/messages/$messageId/$filename',
    );
    await ref.putFile(File(localPath));
    return await ref.getDownloadURL();
  }

  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> markRoomRead({required String roomId, required String userId}) {
    return _firestore.collection('chat_rooms').doc(roomId).update({
      'lastRead.$userId': FieldValue.serverTimestamp(),
    });
  }
}
