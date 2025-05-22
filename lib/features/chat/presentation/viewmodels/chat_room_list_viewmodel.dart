import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renal_care_app/core/di/chat_providers.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/chat/domain/entities/chat_room.dart';

final chatRoomListProvider = StreamProvider.autoDispose<List<ChatRoom>>((ref) {
  final uid = ref.watch(authViewModelProvider).user!.uid;
  final uc = ref.watch(watchChatRoomsUseCaseProvider);
  return uc(uid);
});
