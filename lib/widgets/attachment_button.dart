import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AttachmentButton extends StatelessWidget {
  final Function(File) onFileSelected;

  const AttachmentButton({
    Key? key,
    required this.onFileSelected,
  }) : super(key: key);

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          debugPrint('Camera permission denied');
          return;
        }
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        onFileSelected(file);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.attach_file),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo),
              SizedBox(width: 8),
              Text('Choose from Gallery'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'camera',
          child: Row(
            children: [
              Icon(Icons.camera_alt),
              SizedBox(width: 8),
              Text('Capture an Image'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'gallery':
            _pickImage(ImageSource.gallery);
            break;
          case 'camera':
            _pickImage(ImageSource.camera);
            break;
        }
      },
    );
  }
}