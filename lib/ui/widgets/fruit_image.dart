import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'fruit_vector_icon.dart';

class FruitImage extends StatelessWidget {
  const FruitImage({
    super.key,
    this.imagePath,
    this.fruitLabel,
    this.width,
    this.height,
    this.radius = AppDimens.rHero,
    this.fit = BoxFit.cover,
  });

  final String? imagePath;
  final String? fruitLabel;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final harvest = context.harvest;

    Widget childWidget;
    final path = imagePath;
    final file = path != null && path.isNotEmpty ? File(path) : null;

    if (file != null && file.existsSync()) {
      childWidget = Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildFallback(harvest),
      );
    } else {
      childWidget = _buildFallback(harvest);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: childWidget,
    );
  }

  Widget _buildFallback(HarvestColors harvest) {
    return Container(
      width: width,
      height: height,
      color: harvest.primarySoft.withValues(alpha: 0.5),
      alignment: Alignment.center,
      child: FruitVectorIcon(
        fruitLabel: fruitLabel ?? '',
        size: (height != null && height! < 70) ? (height! * 0.65) : 56,
      ),
    );
  }
}
