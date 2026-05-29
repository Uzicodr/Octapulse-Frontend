import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FighterAvatar extends StatelessWidget {
  const FighterAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.borderColor,
    this.borderWidth = 2,
  });

  static const String _baseImageUrl =
      'https://ik.imagekit.io/ohgsl5bks/fighterimages';

  final String name;
  final double radius;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final initial = _initialFor(name);

    return Container(
      padding: borderColor == null
          ? EdgeInsets.zero
          : EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withValues(alpha: 0.3),
        foregroundImage: NetworkImage(_imageUrlFor(name)),
        onForegroundImageError: (_, __) {},
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static String _imageUrlFor(String name) {
    return '$_baseImageUrl/${_slugFor(name)}.png';
  }

  static String _slugFor(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), '-')
        .replaceAll(RegExp(r"(^-|-$)"), '');
  }

  static String _initialFor(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return '?';
    }

    return trimmedName[0].toUpperCase();
  }
}
