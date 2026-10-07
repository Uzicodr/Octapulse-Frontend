import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/pick.dart';
import '../../../../data/models/social.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/skeleton.dart';
import '../../community/view_models/community_view_models.dart';
import '../../community/views/profile_widgets.dart';
import '../../picks/view_models/picks_view_model.dart';
import '../../picks/views/pick_tile.dart';
import 'auth_view.dart';
import 'edit_profile_sheet.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (!auth.hasValue && auth.isLoading) {
      return const SafeArea(bottom: false, child: ProfileSkeleton());
    }
    return auth.valueOrNull == null ? const AuthView() : const _SignedIn();
  }
}

class _SignedIn extends ConsumerWidget {
  const _SignedIn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final stats = ref.watch(myStatsProvider).valueOrNull;
    final picks = ref.watch(myPicksProvider);
    final userId = ref.watch(authControllerProvider).valueOrNull?.userId;
    final profile = userId == null ? null : ref.watch(userProfileProvider(userId)).valueOrNull;

    return SafeArea(
      bottom: false,
      child: me.when(
        skipLoadingOnRefresh: true,
        loading: () => const ProfileSkeleton(),
        error: (e, _) => ErrorState(message: 'Could not load your profile.', onRetry: () => ref.invalidate(meProvider)),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          final list = (picks.valueOrNull?.values.toList() ?? <Pick>[])
            ..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () {
              ref.invalidate(myStatsProvider);
              ref.invalidate(myPicksProvider);
              if (userId != null) ref.invalidate(userProfileProvider(userId));
              return ref.refresh(meProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                ProfileHeader(
                  user: user.summary,
                  bio: user.bio,
                  followers: profile?.followers,
                  following: profile?.following,
                  isMe: true,
                  onFollowers: () => context.push('/user/${user.id}/followers'),
                  onFollowing: () => context.push('/user/${user.id}/following'),
                  trailing: _SettingsMenu(me: user),
                ),
                const SizedBox(height: 16),
                PillButton(label: 'Edit Profile', height: 46, onPressed: () => showEditProfileSheet(context, user)),
                const SizedBox(height: 18),
                if (stats != null) ...[
                  StatsCard(stats: stats),
                  const SizedBox(height: 12),
                  DivisionBreakdown(divisions: stats.byDivision),
                ] else
                  const Shimmer(child: StatsCardSkeleton()),
                const SizedBox(height: 24),
                Text('My Picks', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (picks.isLoading && !picks.hasValue)
                  const Shimmer(child: Column(children: [SkeletonTile(), SizedBox(height: 10), SkeletonTile()]))
                else if (list.isEmpty)
                  const EmptyState(
                    icon: Icons.track_changes_rounded,
                    title: 'No picks yet',
                    message: 'Head to the Picks tab and call the next card.',
                  )
                else
                  for (final pick in list)
                    Padding(padding: const EdgeInsets.only(bottom: 10), child: PickTile(pick: pick)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsMenu extends ConsumerWidget {
  const _SettingsMenu({required this.me});

  final Me me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      color: AppColors.surfaceHigh,
      icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
      onSelected: (v) async {
        switch (v) {
          case 'edit':
            showEditProfileSheet(context, me);
          case 'logout':
            if (await confirmSheet(context, title: 'Sign out?', message: 'Your picks stay saved on your account.', action: 'Sign Out')) {
              await ref.read(authControllerProvider.notifier).logout();
            }
          case 'logout-all':
            if (context.mounted &&
                await confirmSheet(
                  context,
                  title: 'Sign out everywhere?',
                  message: 'Every device signed in to this account will be signed out.',
                  action: 'Sign Out Everywhere',
                )) {
              await ref.read(authControllerProvider.notifier).logout(everywhere: true);
            }
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit profile')),
        PopupMenuItem(value: 'logout', child: Text('Sign out')),
        PopupMenuItem(value: 'logout-all', child: Text('Sign out everywhere')),
      ],
    );
  }
}
