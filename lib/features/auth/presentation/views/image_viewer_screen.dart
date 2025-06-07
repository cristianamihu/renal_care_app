import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String filename;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    required this.filename,
  });

  Future<void> _saveImage(BuildContext context) async {
    try {
      // Obține folderul Downloads/RenalCare
      final downloadsDir = Directory('/storage/emulated/0/Download/RenalCare');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      // Construiește calea completă unde să salvezi
      final targetPath = p.join(downloadsDir.path, filename);
      // Descarcă fișierul
      await Dio().download(imageUrl, targetPath);
      // Afișează SnackBar cu ruta salvării
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image saved in: $targetPath')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(filename),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Save the image',
            onPressed: () => _saveImage(context),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          // Pentru pinch-to-zoom/pan
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (context, error, stack) {
              return const Text(
                'The image could not be loaded.',
                style: TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
