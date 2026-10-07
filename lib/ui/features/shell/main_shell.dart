import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../community/views/community_view.dart';
import '../events/views/home_view.dart';
import '../notifications/view_models/notifications_view_model.dart';
import '../picks/views/picks_view.dart';
import '../profile/views/profile_view.dart';
import '../rankings/views/rankings_view.dart';

enum AppTab { home, picks, community, rankings, profile }

final currentTabProvider = StateProvider<AppTab>((ref) => AppTab.home);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> with WidgetsBindingObserver {
  static const _pages = [
    HomeView(),
    PicksView(),
    CommunityView(),
    RankingsView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Refresh the notification badge whenever the app comes back to the front.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(unreadCountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(index: tab.index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.navBar),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                for (final t in AppTab.values)
                  Expanded(
                    child: _NavItem(
                      tab: t,
                      selected: t == tab,
                      onTap: () => ref.read(currentTabProvider.notifier).state = t,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.textPrimary : AppColors.textMuted;
    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          _icon(color),
          const SizedBox(height: 3),
          Text(
            _label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String get _label => switch (tab) {
        AppTab.home => 'Home',
        AppTab.picks => 'Picks',
        AppTab.community => 'Community',
        AppTab.rankings => 'Rankings',
        AppTab.profile => 'Profile',
      };

  Widget _icon(Color color) {
    if (tab == AppTab.rankings) {
      return Image.asset(
        'assets/images/belt.png',
        width: 28,
        height: 26,
        color: color,
        colorBlendMode: BlendMode.srcIn,
      );
    }
    final icon = switch (tab) {
      AppTab.home => selected ? Icons.home_rounded : Icons.home_outlined,
      AppTab.picks => Icons.track_changes_rounded,
      AppTab.community => selected ? Icons.groups_rounded : Icons.groups_outlined,
      AppTab.profile => selected ? Icons.person_rounded : Icons.person_outline_rounded,
      AppTab.rankings => Icons.emoji_events_outlined,
    };
    return Icon(icon, color: color, size: 26);
  }
}
