import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_radius.dart';

/// Renders a high-definition 3D fruit illustration from bundled local assets
/// (`assets/images/fruits/*.png`) inside a soft pastel container.
class FruitVectorIcon extends StatelessWidget {
  const FruitVectorIcon({
    required this.fruitLabel,
    this.size = 48,
    this.iconSize,
    this.isCircular = true,
    super.key,
  });

  final String fruitLabel;
  final double size;
  final double? iconSize;
  final bool isCircular;

  static _FruitAssetStyle _styleFor(String rawLabel) {
    return switch (rawLabel.toLowerCase()) {
      'banana' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/banana.png',
        bgColor: Color(0xFFFFF8E1),
        borderColor: Color(0xFFFBC02D),
      ),
      'apple' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/apple.png',
        bgColor: Color(0xFFFFEBEE),
        borderColor: Color(0xFFE53935),
      ),
      'avocado' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/avocado.png',
        bgColor: Color(0xFFE8F5E9),
        borderColor: Color(0xFF43A047),
      ),
      'orange' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/orange.png',
        bgColor: Color(0xFFFFF3E0),
        borderColor: Color(0xFFFB8C00),
      ),
      'mango' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/mango.png',
        bgColor: Color(0xFFFFF3E0),
        borderColor: Color(0xFFFFB300),
      ),
      'watermelon' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/watermelon.png',
        bgColor: Color(0xFFFFEBEE),
        borderColor: Color(0xFFE53935),
      ),
      'strawberry' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/strawberry.png',
        bgColor: Color(0xFFFCE4EC),
        borderColor: Color(0xFFD81B60),
      ),
      'pineapple' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/pineapple.png',
        bgColor: Color(0xFFFFFDE7),
        borderColor: Color(0xFFFBC02D),
      ),
      'papaya' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/papaya.png',
        bgColor: Color(0xFFFFF3E0),
        borderColor: Color(0xFFFF7043),
      ),
      'grape' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/grape.png',
        bgColor: Color(0xFFF3E5F5),
        borderColor: Color(0xFF8E24AA),
      ),
      'tomato' => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/tomato.png',
        bgColor: Color(0xFFFFEBEE),
        borderColor: Color(0xFFE53935),
      ),
      _ => const _FruitAssetStyle(
        assetPath: 'assets/images/fruits/default.png',
        bgColor: Color(0xFFE8F5E9),
        borderColor: Color(0xFF2E7D32),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(fruitLabel);
    final innerSize = iconSize ?? (size * 0.66);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.bgColor,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : AppRadius.roundedMd,
        border: Border.all(
          color: style.borderColor.withValues(alpha: 0.22),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: style.borderColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          style.assetPath,
          width: innerSize,
          height: innerSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => Icon(
            Icons.eco_rounded,
            size: innerSize * 0.75,
            color: style.borderColor,
          ),
        ),
      ),
    );
  }
}

class _FruitAssetStyle {
  const _FruitAssetStyle({
    required this.assetPath,
    required this.bgColor,
    required this.borderColor,
  });

  final String assetPath;
  final Color bgColor;
  final Color borderColor;
}
