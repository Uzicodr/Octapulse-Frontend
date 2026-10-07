import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/fighter.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/country_flag.dart';
import '../../../core/widgets/fighter_avatar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../events/views/home_view.dart';

final fighterQueryProvider = StateProvider<String>((ref) => '');

final fighterSearchProvider = FutureProvider<List<Fighter>>((ref) {
  final query = ref.watch(fighterQueryProvider);
  return ref.watch(fightersRepositoryProvider).search(query);
});

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(fighterQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(fighterSearchProvider);
    final query = ref.watch(fighterQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search fighters')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search fighters',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () {
                          _controller.clear();
                          ref.read(fighterQueryProvider.notifier).state = '';
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              query.isEmpty ? 'ALL FIGHTERS' : 'RESULTS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: AsyncBody<List<Fighter>>(
              value: results,
              skeleton: const SkeletonList(
                item: SkeletonTile(avatar: 50, carded: false),
                count: 10,
                spacing: 1,
              ),
              onRetry: () => ref.invalidate(fighterSearchProvider),
              data: (fighters) => fighters.isEmpty
                  ? EmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'No fighters found',
                      message: 'Nothing matches "$query".',
                    )
                  : ListView.separated(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: fighters.length,
                      separatorBuilder: (_, __) => const Divider(indent: 64),
                      itemBuilder: (context, i) => _FighterTile(fighter: fighters[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FighterTile extends StatelessWidget {
  const _FighterTile({required this.fighter});

  final Fighter fighter;

  @override
  Widget build(BuildContext context) {
    final subtitle = [fighter.weightClass, fighter.record].whereType<String>().join(' · ');
    return InkWell(
      onTap: () => openFighter(context, fighter),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            FighterAvatar(fighter: fighter, size: 50),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fighter.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            CountryFlag(fighter.country, size: 20),
          ],
        ),
      ),
    );
  }
}
