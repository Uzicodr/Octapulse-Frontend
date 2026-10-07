import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          if (item.imageUrl != null && item.imageCredit != null)
            Positioned(right: 10, bottom: 10, left: 60, child: _PhotoCredit(credit: item.imageCredit!)),
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
            imageBuilder: (_, provider) => NewsPhoto(image: provider),
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

/// Small "Photo: X · CC BY 3.0" label on the image. Free licenses require the credit and,
/// where given, a link to the photo's page.
class _PhotoCredit extends StatelessWidget {
  const _PhotoCredit({required this.credit});

  final ImageCredit credit;

  @override
  Widget build(BuildContext context) {
    final license = credit.license;
    final text = license == null || license == 'Unsplash License'
        ? 'Photo: ${credit.text}'
        : 'Photo: ${credit.text} · $license';
    final url = credit.url;
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: url == null ? null : () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
              decoration: url == null ? null : TextDecoration.underline,
              decorationColor: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fits a story photo into the wide card without cutting off faces.
///
/// Landscape photos fill the box, cropped slightly towards the top where faces usually are.
/// Portrait photos (most fighter photos from Wikipedia) would lose the face to a fill crop, so they
/// are shown whole, centred over a blurred, darkened copy of themselves.
class NewsPhoto extends StatefulWidget {
  const NewsPhoto({super.key, required this.image});

  final ImageProvider image;

  @override
  State<NewsPhoto> createState() => _NewsPhotoState();
}

class _NewsPhotoState extends State<NewsPhoto> {
  ImageStream? _stream;
  late final ImageStreamListener _listener = ImageStreamListener(_onImage);
  double? _aspect;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(NewsPhoto old) {
    super.didUpdateWidget(old);
    if (old.image != widget.image) _resolve();
  }

  void _resolve() {
    final stream = widget.image.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _onImage(ImageInfo info, bool _) {
    final aspect = info.image.width / info.image.height;
    info.dispose();
    if (mounted && aspect != _aspect) setState(() => _aspect = aspect);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, box) {
      final aspect = _aspect;
      final boxAspect = box.maxWidth / box.maxHeight;
      // Fill when cropping keeps most of the height; a 4:3 photo in a 16:9 box still shows ~75%.
      if (aspect == null || aspect >= boxAspect * 0.7) {
        return Image(image: widget.image, fit: BoxFit.cover, alignment: const Alignment(0, -0.4));
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Image(image: widget.image, fit: BoxFit.cover),
          ),
          ColoredBox(color: Colors.black.withValues(alpha: 0.35)),
          Image(image: widget.image, fit: BoxFit.contain),
        ],
      );
    });
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
