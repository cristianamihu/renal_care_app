import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:renal_care_app/core/theme/app_colors.dart';

class MessageBubble extends StatefulWidget {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? attachmentUrl;
  final String? attachmentName;
  final String? attachmentType;
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
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
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
      ).showSnackBar(SnackBar(content: Text('Salvat în: $targetPath')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Eroare la salvare: $e')));
    }
  }

  // Afișează bottom-sheet cu opțiuni „Deschide” sau „Salvează” pentru document
  void _showAttachmentOptions(BuildContext ctx, String url, String filename) {
    showModalBottomSheet(
      context: ctx,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Deschide'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openDocument(url);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Salvează'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _saveToRenalCare(
                      url,
                      widget.attachmentName ?? p.basename(url),
                    );
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

  /// Afișează imaginea fullscreen și permite salvarea ei
  void _showImageViewer(String imageUrl) {
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
                      ); //salvează imaginea
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

                // Atașament: imagine sau document
                if (widget.attachmentUrl != null) ...[
                  const SizedBox(height: 8),

                  // Dacă e imagine, afișăm thumbnail și la tap deschidem fullscreen
                  if (widget.attachmentType?.startsWith('image/') == true)
                    GestureDetector(
                      onTap: () => _showImageViewer(widget.attachmentUrl!),
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

          // ICONUL DE ȘTERGERE (apare doar dacă onDelete nu e null)
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
