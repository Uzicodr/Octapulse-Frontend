import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/fighter.dart';
import '../../../../data/models/news.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fighter_avatar.dart';

/// Opens the full story on the publisher's site. Publisher terms require linking out
/// rather than showing the article in the app.
Future<void> openStory(BuildContext context, NewsItem item) async {
  final opened = await launchUrl(Uri.parse(item.url), mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the story')));
  }
}

/// One headline. Title and summary are shown exactly as the publisher wrote them.
class NewsTile extends StatelessWidget {
  const NewsTile({super.key, required this.item, this.showSummary = true});

  final NewsItem item;
  final bool showSummary;

  @override
  Widget build(BuildContext context) {
    final summary = item.summary;
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      onTap: () => openStory(context, item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumb(item: item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.sourceName} · ${Dates.ago(item.publishedAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_badge(item.kind) case (final label, final color)) _KindBadge(label: label, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.25),
                ),
                if (showSummary && summary != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
                if (item.fighters.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final f in item.fighters.take(3))
                        _FighterChip(fighter: f, onTap: () => context.push('/fighter/${f.slug}')),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static (String, Color)? _badge(NewsKind kind) => switch (kind) {
        NewsKind.announcement => ('ANNOUNCED', AppColors.primaryBright),
        NewsKind.result => ('RESULT', AppColors.win),
        NewsKind.injury => ('INJURY', AppColors.loss),
        NewsKind.rumor => ('RUMOR', AppColors.textMuted),
        NewsKind.news => null,
      };
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item});

  final NewsItem item;
  static const _size = 48.0;

  @override
  Widget build(BuildContext context) {
    final image = item.imageUrl;
    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: image,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _SourceMark(item: item, size: _size),
        ),
      );
    }
    if (item.fighters.isNotEmpty) {
      final f = item.fighters.first;
      return FighterAvatar(fighter: Fighter(id: f.id, slug: f.slug, name: f.name), size: _size);
    }
    return _SourceMark(item: item, size: _size);
  }
}

class _SourceMark extends StatelessWidget {
  const _SourceMark({required this.item, required this.size});

  final NewsItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.surfaceHigh, shape: BoxShape.circle),
      child: Text(
        item.sourceName.isEmpty ? '?' : item.sourceName[0].toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    );
  }
}

class _FighterChip extends StatelessWidget {
  const _FighterChip({required this.fighter, required this.onTap});

  final NewsFighter fighter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            fighter.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
