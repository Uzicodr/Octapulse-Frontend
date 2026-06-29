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

  static const _labels = [
    'Fighter Logs',
    'Events',
    'Alarm',
    'Rankings',
    'Chat',
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
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _labels.length,
                (i) => Expanded(
                  child: _NavItem(
                    icon: _buildIcon(i, index == i),
                    label: _labels[i],
                    isSelected: index == i,
                    onTap: () => ref.read(_navIndexProvider.notifier).state = i,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildIcon(int index, bool isSelected) {
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;
    switch (index) {
      case 0:
        return SizedBox(
          width: 24,
          height: 24,
          child: Image.asset(
            'assets/images/glove.png',
            width: 24,
            height: 24,
            color: color,
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.sports_mma, size: 24, color: color),
          ),
        );
      case 1:
        return Icon(Icons.event_outlined, size: 24, color: color);
      case 2:
        return Icon(Icons.alarm_outlined, size: 24, color: color);
      case 3:
        return SizedBox(
          width: 24,
          height: 24,
          child: Image.asset(
            'assets/images/belt.png',
            width: 24,
            height: 24,
            color: color,
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.sports_mma, size: 24, color: color),
          ),
        );
      case 4:
        return Icon(Icons.chat_bubble_outline, size: 24, color: color);
      default:
        return Icon(Icons.circle, size: 24, color: color);
    }
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Widget icon;
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
            icon,
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
