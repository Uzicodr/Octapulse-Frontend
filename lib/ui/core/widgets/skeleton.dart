import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Sweeps a soft highlight across every [SkeletonBox] below it.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = (_controller.value * 3 - 1) * bounds.width;
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Translucent sweep: keeps card and box colours, only lightens them.
              colors: const [Color(0x00FFFFFF), Color(0x14FFFFFF), Color(0x00FFFFFF)],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.dx);

  final double dx;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, required this.height, this.radius = 10});

  const SkeletonBox.circle({super.key, required double size})
      : width = size,
        height = size,
        radius = size / 2;

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Card outline matching [AppCard], holding skeleton content.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 22, this.height});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.outline),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks

class SkeletonEventHero extends StatelessWidget {
  const SkeletonEventHero({super.key, this.height = 340});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      height: height,
      radius: 26,
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 80, height: 24),
              Spacer(),
              SkeletonBox(width: 90, height: 24),
            ],
          ),
          Spacer(),
          SkeletonBox(width: 220, height: 24),
          SizedBox(height: 10),
          SkeletonBox(width: 150, height: 16),
          SizedBox(height: 10),
          SkeletonBox(width: 120, height: 13),
          SizedBox(height: 18),
          SkeletonBox(height: 48, radius: 24),
        ],
      ),
    );
  }
}

/// Two fighters facing each other, as on fight and result cards.
class SkeletonMatchup extends StatelessWidget {
  const SkeletonMatchup({super.key, this.avatar = 48});

  final double avatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox.circle(size: avatar),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 80, height: 15),
              SizedBox(height: 6),
              SkeletonBox(width: 50, height: 12),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonBox(width: 80, height: 15),
              SizedBox(height: 6),
              SkeletonBox(width: 50, height: 12),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SkeletonBox.circle(size: avatar),
      ],
    );
  }
}

class SkeletonFightCard extends StatelessWidget {
  const SkeletonFightCard({super.key, this.withDetails = true});

  final bool withDetails;

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 130, height: 14),
          const SizedBox(height: 16),
          const SkeletonMatchup(),
          if (withDetails) ...[
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: SkeletonBox(height: 42, radius: 12)),
                SizedBox(width: 6),
                Expanded(child: SkeletonBox(height: 42, radius: 12)),
                SizedBox(width: 6),
                Expanded(flex: 2, child: SkeletonBox(height: 42, radius: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Calendar block + two lines, as on event rows.
class SkeletonEventRow extends StatelessWidget {
  const SkeletonEventRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(
      radius: 18,
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          SkeletonBox(width: 54, height: 58, radius: 14),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 200, height: 15),
                SizedBox(height: 8),
                SkeletonBox(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar + two lines, for fighter, ranking and pick rows.
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key, this.avatar = 46, this.leading, this.carded = true});

  final double avatar;
  final Widget? leading;
  final bool carded;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        SkeletonBox.circle(size: avatar),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 150, height: 15),
              SizedBox(height: 7),
              SkeletonBox(width: 90, height: 12),
            ],
          ),
        ),
        const SkeletonBox(width: 26, height: 18, radius: 4),
      ],
    );
    if (!carded) return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: row);
    return SkeletonCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: row,
    );
  }
}

class SkeletonChips extends StatelessWidget {
  const SkeletonChips({super.key, this.height = 40, this.widths = const [110, 140, 130, 120]});

  final double height;
  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => SkeletonBox(width: widths[i], height: height, radius: height / 2),
      ),
    );
  }
}

/// Vertical list of [count] copies of [item], non-scrollable, inside a shimmer.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    required this.item,
    this.count = 6,
    this.spacing = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget item;
  final int count;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: (_, __) => item,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Whole-screen placeholders

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * 0.86;
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderLine(width: 170),
            SizedBox(
              height: 340,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(width: cardWidth, child: const SkeletonEventHero()),
                  const SizedBox(width: 12),
                  SizedBox(width: cardWidth, child: const SkeletonEventHero()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _HeaderLine(width: 140),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: SizedBox(width: cardWidth, child: const SkeletonFightCard()),
            ),
            const SizedBox(height: 20),
            const _HeaderLine(width: 120),
            for (var i = 0; i < 3; i++)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: SkeletonEventRow(),
              ),
          ],
        ),
      ),
    );
  }
}

class EventDetailSkeleton extends StatelessWidget {
  const EventDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(height: 330, radius: 0),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  SkeletonBox(width: 170, height: 36, radius: 18),
                  SizedBox(width: 8),
                  SkeletonBox(width: 120, height: 36, radius: 18),
                ],
              ),
            ),
            const _HeaderLine(width: 130, top: 24),
            for (var i = 0; i < 4; i++)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: SkeletonFightCard(),
              ),
          ],
        ),
      ),
    );
  }
}

class PickCardsSkeleton extends StatelessWidget {
  const PickCardsSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    final side = Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            SkeletonBox.circle(size: 64),
            SizedBox(height: 10),
            SkeletonBox(width: 100, height: 14),
            SizedBox(height: 6),
            SkeletonBox(width: 60, height: 11),
          ],
        ),
      ),
    );
    return Shimmer(
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SkeletonCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 130, height: 14),
                    const SizedBox(height: 12),
                    Row(children: [side, const SizedBox(width: 10), side]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PicksSkeleton extends StatelessWidget {
  const PicksSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderLine(width: 100, height: 28, top: 18),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: SkeletonBox(width: 260, height: 14),
                ),
                SkeletonChips(height: 44, widths: [150, 190, 160]),
                SizedBox(height: 28),
              ],
            ),
          ),
          PickCardsSkeleton(),
        ],
      ),
    );
  }
}

class RankingsSkeleton extends StatelessWidget {
  const RankingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderLine(width: 150, height: 28, top: 18),
            const SkeletonChips(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: SkeletonCard(
                height: 190,
                radius: 26,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 110, height: 14),
                    Spacer(),
                    SkeletonBox(width: 180, height: 26),
                    SizedBox(height: 10),
                    SkeletonBox(width: 100, height: 14),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < 5; i++)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: SkeletonTile(leading: SkeletonBox(width: 18, height: 20, radius: 4)),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  SkeletonBox.circle(size: 76),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 160, height: 20),
                        SizedBox(height: 8),
                        SkeletonBox(width: 200, height: 13),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: StatsCardSkeleton()),
            const SizedBox(height: 28),
            for (var i = 0; i < 4; i++)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: SkeletonTile(),
              ),
          ],
        ),
      ),
    );
  }
}

class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const stat = Expanded(
      child: Column(
        children: [
          SkeletonBox.circle(size: 26),
          SizedBox(height: 8),
          SkeletonBox(width: 40, height: 18),
          SizedBox(height: 6),
          SkeletonBox(width: 56, height: 11),
        ],
      ),
    );
    return const SkeletonCard(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Row(children: [stat, stat, stat, stat]),
    );
  }
}

class FighterDetailSkeleton extends StatelessWidget {
  const FighterDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(height: 380, radius: 0),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 240, height: 34),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonBox(width: 110, height: 32, radius: 16),
                      SizedBox(width: 8),
                      SkeletonBox(width: 130, height: 32, radius: 16),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.9,
                padding: EdgeInsets.zero,
                children: List.generate(4, (_) => const SkeletonCard(radius: 20, child: SizedBox.expand())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderLine extends StatelessWidget {
  const _HeaderLine({required this.width, this.height = 20, this.top = 8});

  final double width;
  final double height;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top, 20, 14),
      child: SkeletonBox(width: width, height: height),
    );
  }
}
