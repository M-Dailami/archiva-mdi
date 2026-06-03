/// Model data pengguna
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String rank;
  final int totalXp;
  final int level;
  final int quizzesCompleted;
  final int placesVisited;
  final List<String> badges;
  final String avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.rank = 'Sejarawan Muda',
    this.totalXp = 80,
    this.level = 1,
    this.quizzesCompleted = 1,
    this.placesVisited = 3,
    this.badges = const ['Penjelajah Benteng', 'Pemula Sejarah'],
    this.avatarUrl = '',
  });
}

/// Model data peringkat (rank)
class RankData {
  final String title;
  final int minXp;
  final int maxXp;
  final int level;

  const RankData({
    required this.title,
    required this.minXp,
    required this.maxXp,
    required this.level,
  });

  static const List<RankData> ranks = [
    RankData(title: 'Penjelajah Muda', minXp: 0, maxXp: 100, level: 1),
    RankData(title: 'Penjelajah Andal', minXp: 100, maxXp: 300, level: 2),
    RankData(title: 'Sejarawan Muda', minXp: 300, maxXp: 600, level: 3),
    RankData(title: 'Sejarawan Senior', minXp: 600, maxXp: 1000, level: 4),
    RankData(title: 'Maestro Sejarah', minXp: 1000, maxXp: 2000, level: 5),
  ];
}
