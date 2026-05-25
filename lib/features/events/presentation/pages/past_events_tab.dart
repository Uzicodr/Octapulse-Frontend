import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/event.dart';
import '../providers/events_provider.dart';

class PastEventsTab extends ConsumerWidget {
  const PastEventsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(pastEventsProvider);

    return asyncEvents.when(
      data: (events) => _EventsContent(events: events, icon: Icons.history),
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
                onPressed: () => ref.invalidate(pastEventsProvider),
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
            Icon(icon, size: 64, color: AppColors.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Past Events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No past events yet',
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
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.3),
              child: Icon(icon, color: AppColors.primary),
            ),
            title: Text(event.name),
            subtitle: event.location != null
                ? Text('${event.date} • ${event.location}')
                : Text(event.date),
          ),
        );
      },
    );
  }
}
