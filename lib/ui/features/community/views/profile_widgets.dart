import 'package:flutter/material.dart';

import '../../../../data/models/social.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

/// Avatar, name, @handle, bio and follower counts.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    this.bio,
    this.followers,
    this.following,
    this.onFollowers,
    this.onFollowing,
    this.isMe = false,
    this.trailing,
  });

  final UserSummary user;
  final String? bio;
  final int? followers;
  final int? following;
  final VoidCallback? onFollowers;
  final VoidCallback? onFollowing;
  final bool isMe;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final hasDisplayName = user.displayName?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.85), width: 2.5),
              ),
              child: UserAvatar(name: user.name, url: user.avatarUrl, ai: user.ai, size: 72),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (user.ai) const AiBadge(),
                      if (isMe)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                          child: const Text('You', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                    ],
                  ),
                  if (hasDisplayName)
                    Text('@${user.username}', style: const TextStyle(color: AppColors.textSecondary)),
                  if (followers != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Count(value: followers!, label: 'Followers', onTap: onFollowers),
                        const SizedBox(width: 20),
                        _Count(value: following ?? 0, label: 'Following', onTap: onFollowing),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (bio != null && bio!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(bio!, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
        ],
      ],
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, required this.label, this.onTap});

  final int value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: '$value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          TextSpan(text: ' $label', style: const TextStyle(color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

/// Accuracy, points, streak and rank, Verdict-style icon tiles.
class StatsCard extends StatelessWidget {
  const StatsCard({super.key, required this.stats});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 14),
      child: Column(
        children: [
          Row(
            children: [
              _Stat(icon: Icons.speed_rounded, value: stats.accuracyLabel, label: 'Accuracy'),
              _Stat(icon: Icons.bolt_rounded, value: '${stats.points}', label: 'Points'),
              _Stat(icon: Icons.local_fire_department_rounded, value: '${stats.currentStreak}', label: 'Streak'),
              _Stat(
                icon: Icons.leaderboard_rounded,
                value: stats.globalRank == null ? '—' : '#${stats.globalRank}',
                label: 'Global',
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8), child: Divider()),
          Row(
            children: [
              _Mini(label: 'Picks', value: stats.totalPicks),
              _Mini(label: 'Correct', value: stats.correctPicks),
              _Mini(label: 'Pending', value: stats.pendingPicks),
              _Mini(label: 'Best streak', value: stats.bestStreak),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBright, size: 26),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
        ],
      ),
    );
  }
}

/// Accuracy per division, as thin bars.
class DivisionBreakdown extends StatelessWidget {
  const DivisionBreakdown({super.key, required this.divisions});

  final List<DivisionStats> divisions;

  @override
  Widget build(BuildContext context) {
    if (divisions.isEmpty) return const SizedBox.shrink();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('By division', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          for (final d in divisions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(d.division, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
                Text(
                  '${d.correctPicks}/${d.settledPicks} · ${(d.accuracy * 100).round()}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: d.accuracy.clamp(0, 1).toDouble(),
                minHeight: 6,
                backgroundColor: AppColors.surfaceHigh,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
