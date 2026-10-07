import 'event.dart';
import 'fight.dart';
import 'pick.dart';

/// Compact user used in lists, comments, feed and leagues.
class UserSummary {
  const UserSummary({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.ai = false,
  });

  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final bool ai;

  String get name => (displayName?.isNotEmpty ?? false) ? displayName! : '@$username';

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      ai: json['ai'] as bool? ?? false,
    );
  }
}

class Me {
  const Me({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.hasPassword,
    required this.googleLinked,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.createdAt,
  });

  final String id;
  final String email;
  final String username;
  final String role;
  final bool hasPassword;
  final bool googleLinked;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';

  UserSummary get summary => UserSummary(
        id: id,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );

  factory Me.fromJson(Map<String, dynamic> json) {
    return Me(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      hasPassword: json['hasPassword'] as bool? ?? true,
      googleLinked: json['googleLinked'] as bool? ?? false,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      createdAt: parseDate(json['createdAt']),
    );
  }
}

class DivisionStats {
  const DivisionStats({
    required this.division,
    required this.settledPicks,
    required this.correctPicks,
    required this.accuracy,
  });

  final String division;
  final int settledPicks;
  final int correctPicks;
  final double accuracy;

  factory DivisionStats.fromJson(Map<String, dynamic> json) => DivisionStats(
        division: json['division'] as String,
        settledPicks: _int(json['settledPicks']),
        correctPicks: _int(json['correctPicks']),
        accuracy: _double(json['accuracy']),
      );
}

class UserStats {
  const UserStats({
    this.totalPicks = 0,
    this.pendingPicks = 0,
    this.settledPicks = 0,
    this.correctPicks = 0,
    this.voidPicks = 0,
    this.accuracy = 0,
    this.points = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.globalRank,
    this.byDivision = const [],
  });

  final int totalPicks;
  final int pendingPicks;
  final int settledPicks;
  final int correctPicks;
  final int voidPicks;

  /// 0 to 1.
  final double accuracy;
  final int points;
  final int currentStreak;
  final int bestStreak;
  final int? globalRank;
  final List<DivisionStats> byDivision;

  String get accuracyLabel => '${(accuracy * 100).round()}%';

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalPicks: _int(json['totalPicks']),
        pendingPicks: _int(json['pendingPicks']),
        settledPicks: _int(json['settledPicks']),
        correctPicks: _int(json['correctPicks']),
        voidPicks: _int(json['voidPicks']),
        accuracy: _double(json['accuracy']),
        points: _int(json['points']),
        currentStreak: _int(json['currentStreak']),
        bestStreak: _int(json['bestStreak']),
        globalRank: json['globalRank'] as int?,
        byDivision: (json['byDivision'] as List? ?? const [])
            .map((d) => DivisionStats.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}

class UserProfile {
  const UserProfile({
    required this.user,
    required this.followers,
    required this.following,
    required this.stats,
    this.bio,
    this.followedByMe,
    this.createdAt,
  });

  final UserSummary user;
  final String? bio;
  final int followers;
  final int following;

  /// null when signed out.
  final bool? followedByMe;
  final UserStats stats;
  final DateTime? createdAt;

  UserProfile copyWith({bool? followedByMe, int? followers}) => UserProfile(
        user: user,
        bio: bio,
        followers: followers ?? this.followers,
        following: following,
        followedByMe: followedByMe ?? this.followedByMe,
        stats: stats,
        createdAt: createdAt,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        user: UserSummary.fromJson(json),
        bio: json['bio'] as String?,
        followers: _int(json['followers']),
        following: _int(json['following']),
        followedByMe: json['followedByMe'] as bool?,
        stats: json['stats'] is Map<String, dynamic>
            ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
            : const UserStats(),
        createdAt: parseDate(json['createdAt']),
      );
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.user,
    required this.points,
    required this.correctPicks,
    required this.settledPicks,
    required this.accuracy,
  });

  final int rank;
  final UserSummary user;
  final int points;
  final int correctPicks;
  final int settledPicks;
  final double accuracy;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank: _int(json['rank']),
        user: UserSummary(
          id: json['userId'] as String,
          username: json['username'] as String? ?? '',
          displayName: json['displayName'] as String?,
          avatarUrl: json['avatarUrl'] as String?,
          ai: json['ai'] as bool? ?? false,
        ),
        points: _int(json['points']),
        correctPicks: _int(json['correctPicks']),
        settledPicks: _int(json['settledPicks']),
        accuracy: _double(json['accuracy']),
      );
}

class Comment {
  const Comment({required this.id, required this.fightId, required this.user, required this.body, this.createdAt});

  final String id;
  final String fightId;
  final UserSummary user;
  final String body;
  final DateTime? createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        fightId: json['fightId'] as String,
        user: UserSummary.fromJson(json['user'] as Map<String, dynamic>),
        body: json['body'] as String? ?? '',
        createdAt: parseDate(json['createdAt']),
      );
}

class FeedItem {
  const FeedItem({required this.user, required this.pick, required this.fight, required this.event});

  final UserSummary user;
  final Pick pick;
  final Fight fight;
  final EventSummary event;

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
        user: UserSummary.fromJson(json['user'] as Map<String, dynamic>),
        pick: Pick.fromJson(json['pick'] as Map<String, dynamic>),
        fight: Fight.fromJson(json['fight'] as Map<String, dynamic>),
        event: EventSummary.fromJson(json['event'] as Map<String, dynamic>),
      );
}

class League {
  const League({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.ownerId,
    required this.memberCount,
    this.createdAt,
  });

  final String id;
  final String name;
  final String inviteCode;
  final String ownerId;
  final int memberCount;
  final DateTime? createdAt;

  factory League.fromJson(Map<String, dynamic> json) => League(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        inviteCode: json['inviteCode'] as String? ?? '',
        ownerId: json['ownerId'] as String? ?? '',
        memberCount: _int(json['memberCount']),
        createdAt: parseDate(json['createdAt']),
      );
}

class LeagueDetail {
  const LeagueDetail({required this.league, required this.members});

  final League league;
  final List<UserSummary> members;

  factory LeagueDetail.fromJson(Map<String, dynamic> json) => LeagueDetail(
        league: League.fromJson(json['league'] as Map<String, dynamic>),
        members: (json['members'] as List? ?? const [])
            .map((m) => UserSummary.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}

/// Which kinds of push the user wants. Everything is on until changed.
class NotificationSettings {
  const NotificationSettings({
    this.live = true,
    this.results = true,
    this.news = true,
    this.announcements = true,
    this.reminders = true,
  });

  final bool live;
  final bool results;
  final bool news;
  final bool announcements;
  final bool reminders;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => NotificationSettings(
        live: json['live'] as bool? ?? true,
        results: json['results'] as bool? ?? true,
        news: json['news'] as bool? ?? true,
        announcements: json['announcements'] as bool? ?? true,
        reminders: json['reminders'] as bool? ?? true,
      );

  NotificationSettings copyWith({bool? live, bool? results, bool? news, bool? announcements, bool? reminders}) =>
      NotificationSettings(
        live: live ?? this.live,
        results: results ?? this.results,
        news: news ?? this.news,
        announcements: announcements ?? this.announcements,
        reminders: reminders ?? this.reminders,
      );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : const {},
        readAt: parseDate(json['readAt']),
        createdAt: parseDate(json['createdAt']),
      );
}

/// Paged list: `{data, meta}`.
class Page<T> {
  const Page({required this.items, required this.page, required this.totalPages, required this.total});

  final List<T> items;
  final int page;
  final int totalPages;
  final int total;

  bool get hasMore => page < totalPages;

  factory Page.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) item) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    return Page(
      items: (json['data'] as List? ?? const []).map((e) => item(e as Map<String, dynamic>)).toList(),
      page: _int(meta['page'], 1),
      totalPages: _int(meta['totalPages']),
      total: _int(meta['total']),
    );
  }
}

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
double _double(Object? v) => v is num ? v.toDouble() : 0;
