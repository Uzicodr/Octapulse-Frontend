import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fighter_avatar.dart';
import '../../domain/entities/fighter_log.dart';
import '../providers/fighter_logs_provider.dart';

class FighterLogsPage extends ConsumerWidget {
  const FighterLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(fighterLogsSearchProvider);
    final asyncFighterLogs = ref.watch(fighterLogsProvider(searchQuery));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fighter Logs'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) =>
                  ref.read(fighterLogsSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search for fighter...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.onSurfaceVariant,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            ref.read(fighterLogsSearchProvider.notifier).state =
                                '',
                      )
                    : null,
              ),
              style: const TextStyle(color: AppColors.onSurface),
            ),
          ),
        ),
      ),
      body: asyncFighterLogs.when(
        data: (fighters) => _FighterLogsContent(fighters: fighters),
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
                  onPressed: () =>
                      ref.invalidate(fighterLogsProvider(searchQuery)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FighterLogsContent extends StatelessWidget {
  const _FighterLogsContent({required this.fighters});

  final List<FighterLog> fighters;

  @override
  Widget build(BuildContext context) {
    if (fighters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No fighters found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fighters.length,
      itemBuilder: (context, index) {
        final fighter = fighters[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: FighterAvatar(
              name: '${fighter.first_name} ${fighter.last_name}',
            ),
            title: Text("${fighter.first_name} ${fighter.last_name}"),
            subtitle: Text(
              fighter.getrecord(),
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
        );
      },
    );
  }
}
