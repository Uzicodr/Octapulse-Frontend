import 'package:go_router/go_router.dart';

import '../data/models/fighter.dart';
import '../data/repositories/events_repository.dart';
import 'features/community/view_models/community_view_models.dart';
import 'features/community/views/league_view.dart';
import 'features/community/views/user_profile_view.dart';
import 'features/events/views/event_detail_view.dart';
import 'features/events/views/home_view.dart';
import 'features/fights/views/fight_detail_view.dart';
import 'features/news/views/news_view.dart';
import 'features/notifications/views/notifications_view.dart';
import 'features/profile/views/password_reset_view.dart';
import 'features/search/views/fighter_detail_view.dart';
import 'features/search/views/search_view.dart';
import 'features/shell/main_shell.dart';
import 'features/splash/splash_view.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashView()),
      GoRoute(path: '/home', builder: (_, __) => const MainShell()),
      GoRoute(path: '/search', builder: (_, __) => const SearchView()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsView()),
      GoRoute(path: '/news', builder: (_, __) => const NewsView()),
      GoRoute(
        path: '/events/:window',
        builder: (_, state) => EventListView(
          window: state.pathParameters['window'] == 'past' ? EventWindow.past : EventWindow.upcoming,
        ),
      ),
      GoRoute(
        path: '/event/:id',
        builder: (_, state) => EventDetailView(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/fight/:id',
        builder: (_, state) => FightDetailView(fightId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/fighter/:slug',
        builder: (_, state) => FighterDetailView(
          slug: state.pathParameters['slug']!,
          initial: state.extra is Fighter ? state.extra as Fighter : null,
        ),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (_, state) => UserProfileView(userId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'followers',
            builder: (_, state) => FollowListView(userId: state.pathParameters['id']!, list: FollowList.followers),
          ),
          GoRoute(
            path: 'following',
            builder: (_, state) => FollowListView(userId: state.pathParameters['id']!, list: FollowList.following),
          ),
        ],
      ),
      GoRoute(
        path: '/league/:id',
        builder: (_, state) => LeagueView(leagueId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) => PasswordResetView(token: state.uri.queryParameters['token']),
      ),
    ],
  );
}
