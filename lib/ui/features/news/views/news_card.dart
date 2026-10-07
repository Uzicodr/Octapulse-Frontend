import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/fighter.dart';
import '../../../../data/models/news.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fighter_avatar.dart';
import 'news_tile.dart' show openStory, newsBadge;

/// Big news card: artwork of the story's fighters on top, then the credit line, the headline
/// exactly as published, and a Read more button that opens the publisher's page.
///
/// With [fill], the card takes its parent's fixed height (the Home carousel): the artwork
/// stretches and the headline keeps to two lines, so every card in the row lines up.
class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.item, this.imageHeight = 190, this.fill = false});

  final NewsItem item;
  final double imageHeight;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final badge = newsBadge(item.kind);
    final artwork = LayoutBuilder(
      builder: (_, box) => Stack(
        fit: StackFit.expand,
        children: [
          _Artwork(item: item, height: box.maxHeight),
          if (badge != null)
            Positioned(top: 12, left: 12, child: StatusChip(badge.$1, color: badge.$2, filled: true)),
        ],
      ),
    );
    return AppCard(
      padding: EdgeInsets.zero,
      radius: 22,
      onTap: () => openStory(context, item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (fill) Expanded(child: artwork) else SizedBox(height: imageHeight, child: artwork),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: fill ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, height: 1.25),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.sourceName} · ${Dates.ago(item.publishedAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    _ReadMore(onTap: () => openStory(context, item)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The feed's own image when it has one; otherwise portraits of up to two tagged fighters
/// facing each other; otherwise the source name as a watermark.
class _Artwork extends StatelessWidget {
  const _Artwork({required this.item, required this.height});

  final NewsItem item;
  final double height;

  @override
  Widget build(BuildContext context) {
    final image = item.imageUrl;
    final fighters = item.fighters
        .take(2)
        .map((f) => Fighter(id: f.id, slug: f.slug, name: f.name))
        .toList();
    final watermark = (fighters.isNotEmpty ? fighters.first.lastName : item.sourceName).toUpperCase();

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0.3),
              radius: 1.1,
              colors: [Color(0xCC7A1019), AppColors.surfaceHigh],
            ),
          ),
        ),
        Positioned(
          top: 18,
          left: 0,
          right: 0,
          child: Text(
            watermark,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: -2,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        if (image != null)
          CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          )
        else if (fighters.length == 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: FighterPortrait(fighter: fighters[0], height: height - 8, fadeEdge: AxisDirection.right)),
              Expanded(
                child: FighterPortrait(
                  fighter: fighters[1],
                  height: height - 8,
                  flip: true,
                  fadeEdge: AxisDirection.left,
                ),
              ),
            ],
          )
        else if (fighters.length == 1)
          Align(alignment: Alignment.bottomCenter, child: FighterPortrait(fighter: fighters[0], height: height - 8))
        else
          const Center(child: Icon(Icons.newspaper_rounded, size: 56, color: AppColors.textMuted)),
        // Blend the artwork into the text area below.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.65, 1],
              colors: [Colors.transparent, AppColors.surface],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadMore extends StatelessWidget {
  const _ReadMore({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.15),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Read more',
                style: TextStyle(color: AppColors.primaryBright, fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4),
              Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.primaryBright),
            ],
          ),
        ),
      ),
    );
  }
}
