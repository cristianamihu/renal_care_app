import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/core/di/chat_providers.dart';
import 'package:renal_care_app/features/chat/presentation/widgets/patient_search_bar.dart';

class ChatRoomListScreen extends ConsumerStatefulWidget {
  const ChatRoomListScreen({super.key});

  @override
  ConsumerState<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends ConsumerState<ChatRoomListScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user!;
    final isDoctor = user.role == 'doctor';
    final roomsAsync = ref.watch(chatRoomsStreamProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        context.go('/home');
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradient1,
                  AppColors.gradient2,
                  AppColors.gradient3,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: BackButton(onPressed: () => context.go('/home')),
          title: const Text('Messages'),
        ),

        body: roomsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Eroare: $e')),
          data:
              (rooms) => Column(
                children: [
                  if (isDoctor) const PatientSearchBar(),
                  Expanded(
                    child:
                        rooms.isEmpty
                            ? Center(
                              child: Text(
                                isDoctor
                                    ? 'Start a conversation by searching for a patient'
                                    : 'No conversations yet',
                              ),
                            )
                            : ListView.builder(
                              itemCount: rooms.length,
                              itemBuilder: (ctx, i) {
                                final room = rooms[i];
                                final me = user.uid;
                                final otherUid = room.participants.firstWhere(
                                  (u) => u != me,
                                );

                                final messagesAsync = ref.watch(
                                  messagesProvider(room.id),
                                );
                                final roomWithReadAsync = ref.watch(
                                  chatRoomStreamProvider(room.id),
                                );

                                return messagesAsync.when(
                                  loading:
                                      () => const ListTile(
                                        title: Text('Loading messages…'),
                                      ),
                                  error:
                                      (e, _) =>
                                          ListTile(title: Text('Error: $e')),
                                  data: (msgs) {
                                    return roomWithReadAsync.when(
                                      loading:
                                          () => const ListTile(
                                            title: Text('Loading room…'),
                                          ),
                                      error:
                                          (e, _) => ListTile(
                                            title: Text('Error: $e'),
                                          ),
                                      data: (roomWithRead) {
                                        // număr de mesaje necitite
                                        final lastRead =
                                            roomWithRead.lastRead[me] ??
                                            DateTime.fromMillisecondsSinceEpoch(
                                              0,
                                            );
                                        final unreadCount =
                                            msgs
                                                .where(
                                                  (m) => m.timestamp.isAfter(
                                                    lastRead,
                                                  ),
                                                )
                                                .length;

                                        // calcul label timp
                                        final when =
                                            roomWithRead.room.lastMessageAt;
                                        final now = DateTime.now();
                                        final label =
                                            now.difference(when).inHours < 24
                                                ? DateFormat(
                                                  'HH:mm',
                                                ).format(when)
                                                : DateFormat(
                                                  'dd MMM yyyy',
                                                ).format(when);

                                        return ListTile(
                                          title: ref
                                              .watch(userProvider(otherUid))
                                              .when(
                                                loading:
                                                    () => const Text(
                                                      'Loading user…',
                                                    ),
                                                error:
                                                    (_, __) => Text(otherUid),
                                                data:
                                                    (other) => Text(
                                                      other.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                              ),
                                          subtitle:
                                              msgs.isEmpty
                                                  ? const Text(
                                                    'No messages yet',
                                                  )
                                                  : (msgs.last.text.isNotEmpty
                                                      ? Text(
                                                        msgs.last.text,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      )
                                                      : Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: const [
                                                          Icon(
                                                            Icons.attach_file,
                                                            size: 16,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            'Attachment',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // ora / data
                                              Text(
                                                label,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),

                                              // badge doar la mesaje necitite
                                              if (unreadCount > 0) ...[
                                                const SizedBox(width: 8),
                                                CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      AppColors.gradient3,
                                                  child: Text(
                                                    '$unreadCount',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          onTap:
                                              () => context.go(
                                                '/chat/${room.id}',
                                              ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
