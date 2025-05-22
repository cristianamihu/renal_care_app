import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/features/auth/data/models/user_model.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/chat/data/models/chat_room_model.dart';

import 'package:renal_care_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:renal_care_app/features/chat/data/services/chat_remote_service.dart';
import 'package:renal_care_app/features/chat/domain/entities/chat_room.dart';
import 'package:renal_care_app/features/chat/domain/entities/chat_room_with_read.dart';
import 'package:renal_care_app/features/chat/domain/entities/message.dart';
import 'package:renal_care_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:renal_care_app/features/chat/domain/usecases/delete_message.dart';
import 'package:renal_care_app/features/chat/domain/usecases/list_chat_rooms.dart';
import 'package:renal_care_app/features/chat/domain/usecases/mark_room_read.dart';
import 'package:renal_care_app/features/chat/domain/usecases/search_patients.dart';
import 'package:renal_care_app/features/chat/domain/usecases/send_message.dart';
import 'package:renal_care_app/features/chat/domain/usecases/watch_chat_rooms.dart';
import 'package:renal_care_app/features/chat/domain/usecases/watch_messages.dart';
import 'package:renal_care_app/features/chat/domain/usecases/create_chat_room.dart';

/// Stream de chat rooms pentru utilizatorul curent
final chatRoomsStreamProvider = StreamProvider.autoDispose<List<ChatRoom>>((
  ref,
) {
  // Ia UID-ul din starea de autentificare
  final uid = ref.watch(authViewModelProvider).user!.uid;
  // Ia instanţa de WatchChatRooms
  final watchUC = ref.watch(watchChatRoomsUseCaseProvider);
  // Apelează-o cu uid
  return watchUC.call(uid);
});

/// Provider pentru FirebaseFirestore. Firestore singleton
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Îţi aduce entitatea User după uid
final userProvider = FutureProvider.family<User, String>((ref, uid) async {
  final doc =
      await ref.watch(firestoreProvider).collection('users').doc(uid).get();
  return UserModel.fromDocument(doc).toEntity();
});

/// StreamProvider.family care expune lista de mesaje pentru un roomId
final messagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  roomId,
) {
  final watchUC = ref.watch(watchMessagesUseCaseProvider);
  return watchUC.call(roomId);
});

// serviciul remote
final chatRemoteServiceProvider = Provider<ChatRemoteService>((ref) {
  return ChatRemoteService(firestore: FirebaseFirestore.instance);
});

// repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(chatRemoteServiceProvider));
});

// use-cases
final createChatRoomUseCaseProvider = Provider<CreateChatRoom>(
  (ref) => CreateChatRoom(ref.watch(chatRepositoryProvider)),
);

final watchChatRoomsUseCaseProvider = Provider<WatchChatRooms>(
  (ref) => WatchChatRooms(ref.watch(chatRepositoryProvider)),
);

// List chat rooms
final listChatRoomsUseCaseProvider = Provider<ListChatRooms>(
  (ref) => ListChatRooms(ref.watch(chatRepositoryProvider)),
);

// Send message use-case
final sendMessageUseCaseProvider = Provider<SendMessage>(
  (ref) => SendMessage(ref.watch(chatRepositoryProvider)),
);

// Watch messages per room
final watchMessagesUseCaseProvider = Provider<WatchMessages>(
  (ref) => WatchMessages(ref.watch(chatRepositoryProvider)),
);

// Search patients (doctor only)
final searchPatientsUseCaseProvider = Provider<SearchPatients>(
  (ref) => SearchPatients(ref.watch(chatRepositoryProvider)),
);

/// Întoarce viitorul cu ultimul mesaj (sau null dacă nu există)
final lastMessageProvider = FutureProvider.family<Message?, String>((
  ref,
  roomId,
) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getLastMessage(roomId);
});

/// Stream de ChatRoomWithRead (cu lastRead mereu actualizat)
final chatRoomStreamProvider = StreamProvider.family<ChatRoomWithRead, String>((
  ref,
  roomId,
) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('chat_rooms').doc(roomId).snapshots().map((doc) {
    final room = ChatRoomModel.fromDocument(doc).toEntity();
    final data = doc.data()!;
    final raw = data['lastRead'] as Map<String, dynamic>? ?? {};
    final lastRead = <String, DateTime>{};
    raw.forEach((u, ts) {
      if (ts is Timestamp) lastRead[u] = ts.toDate();
    });
    return ChatRoomWithRead(room: room, lastRead: lastRead);
  });
});

final deleteMessageUseCaseProvider = Provider<DeleteMessage>(
  (ref) => DeleteMessage(ref.watch(chatRepositoryProvider)),
);

final markRoomReadUseCaseProvider = Provider<MarkRoomRead>(
  (ref) => MarkRoomRead(ref.watch(chatRepositoryProvider)),
);

final unreadCountProvider = Provider.family<int, String>((ref, roomId) {
  final me = ref.watch(authViewModelProvider).user!.uid;

  // ia lista de mesaje (ultima valoare)
  final msgs = ref.watch(messagesProvider(roomId)).value ?? [];

  // ia ultima valoare de lastRead din stream (sau null dacă încă nu a venit)
  final roomWithRead = ref
      .watch(chatRoomStreamProvider(roomId))
      .maybeWhen(data: (r) => r, orElse: () => null);

  // dacă n-ai încă lastRead, considerăm că nu ai citit nimic
  final lastRead =
      roomWithRead?.lastRead[me] ?? DateTime.fromMillisecondsSinceEpoch(0);

  // numărăm doar mesajele cu timestamp > lastRead
  return msgs.where((m) => m.timestamp.isAfter(lastRead)).length;
});
