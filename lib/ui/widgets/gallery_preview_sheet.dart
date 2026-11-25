import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'primary_button.dart';

/// Action returned by [showGalleryPreviewSheet].
enum GalleryPreviewAction { analyze, repick }

/// Editorial confirmation bottom sheet showing the selected gallery photo
/// before running AI ripeness analysis.
Future<GalleryPreviewAction?> showGalleryPreviewSheet(
  BuildContext context,
  String imagePath,
) {
  return showModalBottomSheet<GalleryPreviewAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _GalleryPreviewSheet(imagePath: imagePath),
  );
}

class _GalleryPreviewSheet extends StatelessWidget {
  const _GalleryPreviewSheet({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.rSheet),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.s20,
        AppDimens.s12,
        AppDimens.s20,
        AppDimens.s24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimens.s16),
                  decoration: BoxDecoration(
                    color: harvest.muted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                  ),
                ),
              ),
              Text(
                'Pratinjau Foto Pisang',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimens.s4),
              Text(
                'Pastikan buah pisang terlihat jelas sebelum dianalisis.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: harvest.muted,
                ),
              ),
              const SizedBox(height: AppDimens.s16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.rCard),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: harvest.primarySoft,
                        border: Border.all(color: harvest.border),
                      ),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: harvest.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.s20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(GalleryPreviewAction.repick),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Pilih Ulang'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ink,
                        side: BorderSide(color: harvest.border, width: 1.4),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.rButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.s12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Lanjut Analisis',
                      icon: Icons.auto_awesome_rounded,
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(GalleryPreviewAction.analyze),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
