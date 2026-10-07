import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/social.dart';
import '../../../../data/services/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/skeleton.dart';
import '../view_models/community_view_models.dart';
import 'leaderboard_list.dart';

class LeagueView extends ConsumerStatefulWidget {
  const LeagueView({super.key, required this.leagueId});

  final String leagueId;

  @override
  ConsumerState<LeagueView> createState() => _LeagueViewState();
}

class _LeagueViewState extends ConsumerState<LeagueView> {
  bool _members = false;

  String get id => widget.leagueId;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(leagueProvider(id));
    final myId = ref.watch(authControllerProvider).valueOrNull?.userId;
    final isOwner = detail.valueOrNull?.league.ownerId == myId;

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.valueOrNull?.league.name ?? 'League'),
        actions: [
          if (detail.hasValue)
            PopupMenuButton<String>(
              color: AppColors.surfaceHigh,
              onSelected: (v) => _menu(v, detail.value!),
              itemBuilder: (_) => [
                if (isOwner) const PopupMenuItem(value: 'code', child: Text('New invite code')),
                const PopupMenuItem(value: 'leave', child: Text('Leave league')),
                if (isOwner) const PopupMenuItem(value: 'delete', child: Text('Delete league', style: TextStyle(color: AppColors.loss))),
              ],
            ),
        ],
      ),
      body: AsyncBody<LeagueDetail>(
        value: detail,
        skeleton: const Shimmer(child: Padding(padding: EdgeInsets.all(20), child: LeaderboardSkeleton())),
        onRetry: () => ref.invalidate(leagueProvider(id)),
        data: (d) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () {
            ref.invalidate(leagueLeaderboardProvider(id));
            return ref.refresh(leagueProvider(id).future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              _InviteCard(league: d.league),
              const SizedBox(height: 16),
              SegmentedTabs<bool>(
                values: const [false, true],
                selected: _members,
                label: (m) => m ? 'Members · ${d.members.length}' : 'Leaderboard',
                onChanged: (m) => setState(() => _members = m),
              ),
              const SizedBox(height: 14),
              if (_members)
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      for (final m in d.members)
                        ListTile(
                          onTap: () => context.push('/user/${m.id}'),
                          leading: UserAvatar(name: m.name, url: m.avatarUrl, ai: m.ai, size: 36),
                          title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: m.id == d.league.ownerId
                              ? const Text('Owner', style: TextStyle(color: AppColors.gold, fontSize: 12))
                              : null,
                          trailing: isOwner && m.id != myId
                              ? IconButton(
                                  icon: const Icon(Icons.person_remove_outlined, color: AppColors.textMuted),
                                  onPressed: () => _remove(m),
                                )
                              : null,
                        ),
                    ],
                  ),
                )
              else
                ref.watch(leagueLeaderboardProvider(id)).when(
                      skipLoadingOnRefresh: true,
                      loading: () => const Shimmer(child: LeaderboardSkeleton()),
                      error: (e, _) => ErrorState(message: describeError(e)),
                      data: (rows) => rows.isEmpty
                          ? const EmptyState(
                              icon: Icons.leaderboard_rounded,
                              title: 'No points yet',
                              message: 'Standings fill in once members have settled picks.',
                            )
                          : LeaderboardList(rows: rows),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _menu(String action, LeagueDetail d) async {
    final repo = ref.read(socialRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      switch (action) {
        case 'code':
          await repo.regenerateInvite(id);
          ref.invalidate(leagueProvider(id));
          messenger.showSnackBar(const SnackBar(content: Text('New invite code created. The old one no longer works.')));
        case 'leave':
          if (!await confirmSheet(context, title: 'Leave league?', message: 'You can rejoin with an invite code.', action: 'Leave')) return;
          await repo.leaveLeague(id);
          _exit();
        case 'delete':
          if (!await confirmSheet(context, title: 'Delete league?', message: 'This removes it for every member.', action: 'Delete')) return;
          await repo.deleteLeague(id);
          _exit();
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
    }
  }

  Future<void> _remove(UserSummary member) async {
    if (!await confirmSheet(context, title: 'Remove ${member.name}?', message: 'They can rejoin with the invite code.', action: 'Remove')) {
      return;
    }
    try {
      await ref.read(socialRepositoryProvider).removeMember(id, member.id);
      ref.invalidate(leagueProvider(id));
      ref.invalidate(leagueLeaderboardProvider(id));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    }
  }

  void _exit() {
    ref.invalidate(myLeaguesProvider);
    if (mounted) context.pop();
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.league});

  final League league;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: AppColors.primary.withValues(alpha: 0.4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('INVITE CODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(
                  league.inviteCode,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 4),
                ),
                Text(
                  '${league.memberCount}/200 members',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy code',
            style: IconButton.styleFrom(backgroundColor: AppColors.surfaceHigh),
            icon: const Icon(Icons.copy_rounded),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: league.inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite code copied. Friends join from Community > Leagues > Join.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
