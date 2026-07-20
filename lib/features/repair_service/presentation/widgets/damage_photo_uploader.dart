import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';

class DamagePhotoUploader extends StatelessWidget {
  const DamagePhotoUploader({
    super.key,
    required this.photoPaths,
    required this.onPhotoAdded,
    required this.onPhotoRemoved,
  });

  final List<String> photoPaths;
  final void Function(String path) onPhotoAdded;
  final void Function(int index) onPhotoRemoved;

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) onPhotoAdded(picked.path);
    } catch (e, st) {
      AppLogger.error('Photo pick failed', tag: 'DamagePhotoUploader', error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: _addPhoto,
            child: Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 4),
                  Text('Add', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          ...photoPaths.asMap().entries.map((entry) {
            return Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(File(entry.value)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onPhotoRemoved(entry.key),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.errorColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
