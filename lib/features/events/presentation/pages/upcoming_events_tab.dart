import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/event.dart';
import '../providers/events_provider.dart';
import 'event_detail_page.dart';

class UpcomingEventsTab extends ConsumerWidget {
  const UpcomingEventsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(upcomingEventsProvider);

    return asyncEvents.when(
      data: (events) =>
          _EventsContent(events: events, icon: Icons.event_available),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(upcomingEventsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventsContent extends StatelessWidget {
  const _EventsContent({required this.events, required this.icon});

  final List<Event> events;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Upcoming Events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No upcoming events',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
            ),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.3),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ufclogo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.sports_mma, color: AppColors.primary),
                ),
              ),
            ),
            title: Text(event.name),
            subtitle: event.location != null
                ? Text('${event.date} • ${event.location}')
                : Text(event.date),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
