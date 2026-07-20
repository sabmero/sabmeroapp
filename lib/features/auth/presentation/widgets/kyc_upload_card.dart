import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';

class KycUploadCard extends StatelessWidget {
  const KycUploadCard({
    super.key,
    required this.onFilePicked,
    this.filePath,
  });

  final void Function(String path) onFilePicked;
  final String? filePath;

  Future<void> _pickFile(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        onFilePicked(picked.path);
      }
    } catch (e, st) {
      AppLogger.error('KYC pick failed', tag: 'KycUploadCard', error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickFile(context),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: filePath != null
                ? AppColors.successColor
                : Theme.of(context).colorScheme.outline,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: filePath != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.successColor, size: 28),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Document attached',
                      style: TextStyle(
                        color: AppColors.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file_outlined,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload Citizenship / Passport',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}
