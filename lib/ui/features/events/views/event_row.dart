import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/event.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';

/// Compact list row: calendar block, event name and location.
class EventRow extends StatelessWidget {
  const EventRow({super.key, required this.event});

  final EventSummary event;

  @override
  Widget build(BuildContext context) {
    final date = event.startsAt;
    return AppCard(
      padding: const EdgeInsets.all(12),
      radius: 18,
      onTap: () => context.push('/event/${event.id}'),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date == null ? 'TBA' : DateFormat('MMM').format(date).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.primaryBright,
                  ),
                ),
                if (date != null)
                  Text(
                    '${date.day}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.1),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  event.shortLocation.isEmpty ? 'Location TBA' : event.shortLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
