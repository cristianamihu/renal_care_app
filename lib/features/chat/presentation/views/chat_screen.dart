import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';

import 'package:renal_care_app/core/di/chat_providers.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/features/chat/domain/entities/message.dart';
import 'package:renal_care_app/features/chat/presentation/widgets/chat_list_item.dart';
import 'package:renal_care_app/features/chat/presentation/widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSending = false;
  bool _profileLinkPressed = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();

    // mark room as read once on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(authViewModelProvider).user!.uid;
      ref
          .read(markRoomReadUseCaseProvider)
          .call(roomId: widget.roomId, userId: uid);
    });

    // show/hide “scroll to bottom” button
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final curScroll = _scrollController.offset;
      const threshold = 200.0;
      final shouldShow = (maxScroll - curScroll) > threshold;
      if (shouldShow != _showScrollToBottom) {
        setState(() => _showScrollToBottom = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Metoda apelată când dai tap pe icon-ul de atașare document
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = result.files.single;
    final path = file.path!;
    final name = file.name;
    final mimeType = lookupMimeType(path) ?? 'application/octet-stream';

    await _sendWithAttachment(path, name, mimeType);
  }

  /// Metoda apelată când dai tap pe icon-ul de cameră
  Future<void> _pickImageFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final path = picked.path;
    final name = p.basename(path);
    final mimeType = lookupMimeType(path) ?? 'image/jpeg';

    await _sendWithAttachment(path, name, mimeType);
  }

  /// Helper care trimite fie mesajul gol (pentru atașament), fie cu text
  Future<void> _sendWithAttachment(
    String path,
    String name,
    String mimeType,
  ) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSending = true);
    final uid = ref.read(authViewModelProvider).user!.uid;
    try {
      await ref
          .read(sendMessageUseCaseProvider)
          .call(
            roomId: widget.roomId,
            senderId: uid,
            text: '',
            attachmentPath: path,
            attachmentName: name,
            attachmentType: mimeType,
          );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Loading error: \$e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  List<ChatListItem> _flattenMessagesWithSeparators(List<Message> msgs) {
    final List<ChatListItem> items = [];
    DateTime? lastDate;
    for (var m in msgs) {
      // doar data, fără oră
      final day = DateTime(
        m.timestamp.year,
        m.timestamp.month,
        m.timestamp.day,
      );
      if (lastDate == null || day != lastDate) {
        items.add(DateSeparator(m.timestamp));
        lastDate = day;
      }
      items.add(MessageItem(m));
    }
    return items;
  }

  // A helper that returns your tappable name widget:
  Widget _buildProfileLink(String userId, {String? display}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/profile/$userId'),
        onHighlightChanged: (isPressed) {
          setState(() {
            _profileLinkPressed = isPressed;
          });
        },
        child: Text(
          display ?? userId,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color:
                _profileLinkPressed
                    ? Colors
                        .grey // culoarea când e apăsat
                    : Colors.white, // culoarea normală
          ),
        ),
      ),
    );
  }

  /// Construieste corpul ecranului de chat (lista + input)
  Widget _buildChatBody(AsyncValue<List<Message>> messagesAsync) {
    final uid = ref.read(authViewModelProvider).user!.uid;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (msgs) {
                  // După ce primiţi mesajele, marcaţi-le ca citite:
                  if (msgs.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref
                          .read(markRoomReadUseCaseProvider)
                          .call(roomId: widget.roomId, userId: uid);
                    });
                  }

                  // Flattenăm cu separatori
                  final items = _flattenMessagesWithSeparators(msgs);

                  // Afișăm lista combinată
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      // pentru reverse, luăm elementul de la coadă
                      final item = items[items.length - 1 - i];

                      if (item is DateSeparator) {
                        // Separator de dată
                        final when = item.when;
                        final now = DateTime.now();
                        final diff = now.difference(when);
                        final label =
                            diff.inHours < 24
                                ? DateFormat('HH:mm').format(when)
                                : DateFormat('dd MMM yyyy').format(when);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }

                      // Mesaj
                      final msg = (item as MessageItem).message;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress:
                            msg.senderId == uid
                                ? () async {
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text('Delete message'),
                                          content: const Text(
                                            'Are you sure you want to delete this message?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx,
                                                  ).pop(false),
                                              child: const Text('Cancel'),
                                            ),

                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx,
                                                  ).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (shouldDelete != true) return;
                                  try {
                                    await ref
                                        .read(deleteMessageUseCaseProvider)
                                        .call(
                                          roomId: widget.roomId,
                                          messageId: msg.id,
                                        );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error deleting: \$e'),
                                      ),
                                    );
                                  }
                                }
                                : null,
                        child: Column(
                          crossAxisAlignment:
                              msg.senderId == uid
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            MessageBubble(
                              text: msg.text,
                              isMe: msg.senderId == uid,
                              timestamp: msg.timestamp,
                              attachmentUrl: msg.attachmentUrl,
                              attachmentName: msg.attachmentName,
                              attachmentType: msg.attachmentType,
                              onDelete: null,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Message error: \$e')),
              ),
            ),

            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _pickDocument,
                  ),

                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickImageFromCamera,
                  ),

                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Write a message',
                      ),
                    ),
                  ),
                  _isSending
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final text = _controller.text.trim();
                          if (text.isEmpty) return;
                          setState(() => _isSending = true);
                          try {
                            await ref
                                .read(sendMessageUseCaseProvider)
                                .call(
                                  roomId: widget.roomId,
                                  senderId: uid,
                                  text: text,
                                );
                            if (!mounted) return;
                            _controller.clear();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error sending: \$e')),
                            );
                          } finally {
                            if (mounted) setState(() => _isSending = false);
                          }
                        },
                      ),
                ],
              ),
            ),
          ],
        ),

        // Butonul “scroll to bottom”
        if (_showScrollToBottom)
          Positioned(
            bottom: 80, // ridică puțin peste input
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // listen for new messages and scroll when they arrive
    ref.listen<AsyncValue<List<Message>>>(
      messagesProvider(widget.roomId),
      (_, messages) => messages.whenData((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }),
    );

    final roomAsync = ref.watch(chatRoomStreamProvider(widget.roomId));
    final messagesAsync = ref.watch(messagesProvider(widget.roomId));

    return PopScope<dynamic>(
      canPop: false, // prevent default pop
      onPopInvokedWithResult: (_, __) {
        // always navigate back to the chat list
        context.go('/chat');
      },
      child: roomAsync.when(
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (e, _) => Scaffold(body: Center(child: Text('Room error: $e'))),
        data: (roomWithRead) {
          // figure out the other user's name
          final otherUid = roomWithRead.room.participants.firstWhere(
            (u) => u != ref.read(authViewModelProvider).user!.uid,
          );
          final otherUserAsync = ref.watch(userProvider(otherUid));

          return otherUserAsync.when(
            loading:
                () => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
            error:
                (e, _) => Scaffold(
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
                    leading: BackButton(onPressed: () => context.go('/chat')),
                    title: _buildProfileLink(otherUid),
                  ),
                  body: _buildChatBody(messagesAsync),
                ),
            data:
                (other) => Scaffold(
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
                    leading: BackButton(onPressed: () => context.go('/chat')),
                    title: _buildProfileLink(otherUid, display: other.name),
                  ),
                  body: _buildChatBody(messagesAsync),
                ),
          );
        },
      ),
    );
  }
}
