import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/session.dart';
import '../../data/models/social.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/repositories/fighters_repository.dart';
import '../../data/repositories/fights_repository.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/repositories/picks_repository.dart';
import '../../data/repositories/rankings_repository.dart';
import '../../data/repositories/social_repository.dart';
import '../../data/services/api_client.dart';
import '../../data/services/session_store.dart';

// Services
final sessionStoreProvider = Provider((ref) => SessionStore());

final apiClientProvider = Provider((ref) {
  return ApiClient(
    ref.watch(sessionStoreProvider),
    onSessionExpired: () => ref.invalidate(authControllerProvider),
  );
});

// Repositories
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(apiClientProvider), ref.watch(sessionStoreProvider)),
);
final eventsRepositoryProvider = Provider((ref) => EventsRepository(ref.watch(apiClientProvider)));
final fightsRepositoryProvider = Provider((ref) => FightsRepository(ref.watch(apiClientProvider)));
final fightersRepositoryProvider = Provider((ref) => FightersRepository(ref.watch(apiClientProvider)));
final rankingsRepositoryProvider = Provider((ref) => RankingsRepository(ref.watch(apiClientProvider)));
final picksRepositoryProvider = Provider((ref) => PicksRepository(ref.watch(apiClientProvider)));
final socialRepositoryProvider = Provider((ref) => SocialRepository(ref.watch(apiClientProvider)));
final newsRepositoryProvider = Provider((ref) => NewsRepository(ref.watch(apiClientProvider)));

// Auth
final authControllerProvider = AsyncNotifierProvider<AuthController, Session?>(AuthController.new);

class AuthController extends AsyncNotifier<Session?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<Session?> build() => _repo.restore();

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.login(email: email, password: password));
  }

  Future<void> signup(String email, String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signup(email: email, username: username, password: password),
    );
  }

  Future<void> logout({bool everywhere = false}) async {
    await _repo.logout(everywhere: everywhere);
    state = const AsyncData(null);
  }
}

/// True once a session exists; cheap to watch from any screen.
final isSignedInProvider = Provider<bool>(
  (ref) => ref.watch(authControllerProvider).valueOrNull != null,
);

/// The signed-in user's profile, or null when signed out.
final meProvider = AsyncNotifierProvider<MeController, Me?>(MeController.new);

class MeController extends AsyncNotifier<Me?> {
  @override
  Future<Me?> build() async {
    final session = await ref.watch(authControllerProvider.future);
    if (session == null) return null;
    return ref.read(authRepositoryProvider).me();
  }

  Future<void> save({String? username, String? displayName, String? avatarUrl, String? bio}) async {
    final updated = await ref.read(authRepositoryProvider).updateMe(
          username: username,
          displayName: displayName,
          avatarUrl: avatarUrl,
          bio: bio,
        );
    state = AsyncData(updated);
  }
}

final myStatsProvider = FutureProvider<UserStats?>((ref) async {
  final session = await ref.watch(authControllerProvider.future);
  if (session == null) return null;
  return ref.read(authRepositoryProvider).myStats();
});
