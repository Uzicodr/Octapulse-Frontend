import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/social.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/skeleton.dart';

/// Ranked rows in one card; the signed-in user's row is highlighted.
class LeaderboardList extends ConsumerWidget {
  const LeaderboardList({super.key, required this.rows});

  final List<LeaderboardEntry> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(authControllerProvider).valueOrNull?.userId;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final row in rows) _Row(entry: row, isMe: row.user.id == myId),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry, required this.isMe});

  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final medal = switch (entry.rank) {
      1 => AppColors.gold,
      2 => const Color(0xFFC0C6CF),
      3 => const Color(0xFFCD8B5A),
      _ => AppColors.textMuted,
    };
    final user = entry.user;
    return InkWell(
      onTap: () => context.push('/user/${user.id}'),
      child: Container(
        color: isMe ? AppColors.primary.withValues(alpha: 0.1) : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text('${entry.rank}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: medal)),
            ),
            UserAvatar(name: user.name, url: user.avatarUrl, ai: user.ai, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isMe ? '${user.name} (you)' : user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (user.ai) ...[const SizedBox(width: 6), const AiBadge()],
                    ],
                  ),
                  Text(
                    '${entry.correctPicks}/${entry.settledPicks} · ${(entry.accuracy * 100).round()}%',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text('${entry.points}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const Text(' pts', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class LeaderboardSkeleton extends StatelessWidget {
  const LeaderboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < 6; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  SkeletonBox(width: 18, height: 18, radius: 4),
                  SizedBox(width: 12),
                  SkeletonBox.circle(size: 34),
                  SizedBox(width: 10),
                  Expanded(child: SkeletonBox(height: 14)),
                  SizedBox(width: 40),
                  SkeletonBox(width: 40, height: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
