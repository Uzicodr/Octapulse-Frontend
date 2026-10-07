import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../config/env.dart';
import '../../../data/models/fighter.dart';
import '../theme/app_colors.dart';

/// Circular headshot with an optional ring (green for winners, red for picks).
class FighterAvatar extends StatelessWidget {
  const FighterAvatar({
    super.key,
    required this.fighter,
    this.size = 44,
    this.ringColor,
    this.dimmed = false,
  });

  final Fighter? fighter;
  final double size;
  final Color? ringColor;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final ring = ringColor;
    final inner = ring == null ? size : size - 6;

    Widget avatar = ClipOval(
      child: Container(
        width: inner,
        height: inner,
        color: AppColors.surfaceHigh,
        child: fighter == null
            ? _initials()
            : CachedNetworkImage(
                imageUrl: Env.fighterImageUrl(fighter!.slug),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, __) => _initials(),
                errorWidget: (_, __, ___) => _initials(),
              ),
      ),
    );

    if (dimmed) {
      avatar = Opacity(opacity: 0.45, child: avatar);
    }

    if (ring == null) return avatar;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2),
      ),
      child: avatar,
    );
  }

  Widget _initials() {
    final name = fighter?.name.trim() ?? '';
    final letters = name.isEmpty
        ? '?'
        : name.split(RegExp(r'\s+')).take(2).map((p) => p[0]).join().toUpperCase();
    return Center(
      child: Text(
        letters,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.3,
        ),
      ),
    );
  }
}

/// Large frameless headshot used in hero cards. With [fadeEdge] the side
/// facing the opponent fades out so two portraits can sit side by side.
class FighterPortrait extends StatelessWidget {
  const FighterPortrait({
    super.key,
    required this.fighter,
    required this.height,
    this.width,
    this.flip = false,
    this.fadeEdge,
  });

  final Fighter? fighter;
  final double height;
  final double? width;
  final bool flip;
  final AxisDirection? fadeEdge;

  @override
  Widget build(BuildContext context) {
    if (fighter == null) return SizedBox(height: height, width: width);
    Widget image = CachedNetworkImage(
      imageUrl: Env.fighterImageUrl(fighter!.slug),
      height: height,
      width: width,
      fit: width == null ? BoxFit.contain : BoxFit.cover,
      alignment: Alignment.topCenter,
      fadeInDuration: const Duration(milliseconds: 250),
      errorWidget: (_, __, ___) => SizedBox(height: height, width: width),
      placeholder: (_, __) => SizedBox(height: height, width: width),
    );
    if (flip) image = Transform.flip(flipX: true, child: image);

    final edge = fadeEdge;
    if (edge == null) return image;
    final toRight = edge == AxisDirection.right;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => LinearGradient(
        begin: toRight ? Alignment.centerLeft : Alignment.centerRight,
        end: toRight ? Alignment.centerRight : Alignment.centerLeft,
        stops: const [0.55, 1],
        colors: const [Colors.white, Colors.transparent],
      ).createShader(rect),
      child: image,
    );
  }
}
