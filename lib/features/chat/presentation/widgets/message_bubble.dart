import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:renal_care_app/core/di/chat_providers.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class MessageBubble extends ConsumerStatefulWidget {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? attachmentUrl;
  final String? attachmentName;
  final String? attachmentType; // mime-type
  final VoidCallback? onDelete;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentType,
    this.onDelete,
  });

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Descarcă fișierul în folderul Download/RenalCare din Android
  Future<void> _saveToRenalCare(String url, String filename) async {
    // creează folderul Download/RenalCare dacă nu există
    final renalDir = Directory('/storage/emulated/0/Download/RenalCare');
    if (!await renalDir.exists()) {
      await renalDir.create(recursive: true);
    }

    final targetPath = p.join(renalDir.path, filename);

    try {
      // descarcă
      await Dio().download(url, targetPath);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved in: $targetPath')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  // Afișează bottom-sheet cu opțiuni „Deschide”, "Adaugă în profilȚ" sau „Salvează” pentru un document
  void _showAttachmentOptions(
    BuildContext ctx,
    String url,
    String filename,
    String mimeType,
  ) {
    showModalBottomSheet(
      context: ctx,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Open'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openDocument(url);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Save'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _saveToRenalCare(
                      url,
                      widget.attachmentName ?? p.basename(url),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.person_add_alt_1),
                  title: const Text('Add to profile'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _addToProfile(url: url, name: filename, type: mimeType);
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// Descarcă temporar și deschide documentul
  Future<void> _openDocument(String url) async {
    final dir = await getTemporaryDirectory();
    final localPath = '${dir.path}/${p.basename(url)}';
    final file = File(localPath);
    if (!await file.exists()) {
      await Dio().download(url, localPath);
    }
    await OpenFile.open(localPath);
  }

  /// Salvează metadatele și URL-ul fișierului în colecția
  /// `users/{uid}/profile_documents/{docId}` din Firestore.
  Future<void> _addToProfile({
    required String url,
    required String name,
    required String type,
  }) async {
    // Obținem user-ul curent din authViewModelProvider
    final authState = ref.read(authViewModelProvider);
    final currentUser = authState.user;
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to save to profile.'),
        ),
      );
      return;
    }

    final uid = currentUser.uid;
    try {
      final firestore = ref.read(firestoreProvider);
      await firestore
          .collection('users')
          .doc(uid)
          .collection('profile_documents')
          .doc()
          .set({
            'name': name,
            'url': url,
            'type': type,
            'addedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File added to profile successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving to profile: $e')));
    }
  }

  /// Afișează imaginea fullscreen și permite salvarea ei și adăugarea în profil
  void _showImageViewer(String imageUrl, String imageName, String mimeType) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.black87,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                Center(
                  child: Hero(tag: imageUrl, child: Image.network(imageUrl)),
                ),

                // buton „Salvează” în colțul dreapta-sus
                Positioned(
                  top: 24,
                  right: 24,
                  child: IconButton(
                    icon: const Icon(Icons.download, size: 28),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop(); // închide dialogul
                      _saveToRenalCare(
                        imageUrl,
                        widget.attachmentName ?? p.basename(imageUrl),
                      );
                    },
                  ),
                ),

                // buton de de adăugare în profil
                Positioned(
                  top: 24,
                  right: 80,
                  child: IconButton(
                    icon: const Icon(Icons.person_add_alt_1, size: 28),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addToProfile(
                        url: imageUrl,
                        name: imageName,
                        type: mimeType,
                      );
                    },
                  ),
                ),

                //buton închide
                Positioned(
                  top: 24,
                  left: 24,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isMe ? AppColors.gradient3 : Colors.grey[300];
    final textColor = widget.isMe ? Colors.white : Colors.black87;

    return FadeTransition(
      opacity: _fade,
      child: Stack(
        children: [
          Container(
            // aliniere & spaţiu exterior diferit
            margin: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: widget.isMe ? 50 : 8,
              right: widget.isMe ? 8 : 50,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(widget.isMe ? 12 : 0),
                bottomRight: Radius.circular(widget.isMe ? 0 : 12),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  widget.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                // Textul mesajului, dacă există
                if (widget.text.isNotEmpty)
                  Text(widget.text, style: TextStyle(color: textColor)),

                // Dacă există un atașament (URL)
                if (widget.attachmentUrl != null) ...[
                  const SizedBox(height: 8),

                  // Dacă e imagine, afișăm thumbnail și la tap deschidem fullscreen
                  if (widget.attachmentType?.startsWith('image/') == true)
                    GestureDetector(
                      onTap:
                          () => _showImageViewer(
                            widget.attachmentUrl!,
                            widget.attachmentName ??
                                p.basename(widget.attachmentUrl!),
                            widget.attachmentType!,
                          ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.attachmentUrl!,
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                      ),
                    )
                  else
                    // altfel, e document → arătăm link de descărcare și bottom-sheet opțiuni
                    InkWell(
                      onTap:
                          () => _showAttachmentOptions(
                            context,
                            widget.attachmentUrl!,
                            widget.attachmentName ??
                                p.basename(widget.attachmentUrl!),
                            widget.attachmentType ?? 'application/octet-stream',
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.insert_drive_file, color: textColor),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.attachmentName ??
                                  p.basename(widget.attachmentUrl!),
                              style: TextStyle(
                                color: textColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 6),

                // timestamp
                Text(
                  '${widget.timestamp.hour.toString().padLeft(2, '0')}:'
                  '${widget.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withAlpha((0.7 * 255).round()),
                  ),
                ),
              ],
            ),
          ),

          // Iconul de ștergere (apare doar dacă onDelete nu e null)
          if (widget.onDelete != null)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.delete, size: 16, color: textColor),
                onPressed: widget.onDelete,
              ),
            ),
        ],
      ),
    );
  }
}
