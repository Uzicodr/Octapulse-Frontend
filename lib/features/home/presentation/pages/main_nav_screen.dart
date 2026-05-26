import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../alarm/presentation/pages/alarm_page.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../events/presentation/pages/events_page.dart';
import '../../../fighter_logs/presentation/pages/fighter_logs_page.dart';
import '../../../rankings/presentation/pages/rankings_page.dart';

final _navIndexProvider = StateProvider<int>((ref) => 0);

class MainNavScreen extends ConsumerWidget {
  const MainNavScreen({super.key});

  static const _tabs = [
    (icon: Icons.people_alt_outlined, label: 'Fighter Logs'),
    (icon: Icons.event_outlined, label: 'Events'),
    (icon: Icons.alarm_outlined, label: 'Alarm'),
    (icon: Icons.leaderboard_outlined, label: 'Rankings'),
    (icon: Icons.chat_bubble_outline, label: 'Chat'),
  ];

  static const _pages = [
    FighterLogsPage(),
    EventsPage(),
    AlarmPage(),
    RankingsPage(),
    ChatPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_navIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: index,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outline, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _tabs.length,
                (i) => Expanded(
                  child: _NavItem(
                    icon: _tabs[i].icon,
                    label: _tabs[i].label,
                    isSelected: index == i,
                    onTap: () =>
                        ref.read(_navIndexProvider.notifier).state = i,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
