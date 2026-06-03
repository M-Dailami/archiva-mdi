import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archivafinal/models/place_model.dart';
import 'package:archivafinal/models/quiz_model.dart';
import 'package:archivafinal/models/user_model.dart';

/// Layanan Supabase terpusat untuk semua operasi database.
/// Menggantikan SQLite lokal dengan Supabase PostgreSQL berbasis cloud.
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ── AUTENTIKASI ──
  static User? get currentUser => _client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;


  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    // Buat baris profil user di tabel public.user_profiles
    if (response.user != null) {
      await _client.from('user_profiles').upsert({
        'id': response.user!.id,
        'name': name,
        'email': email,
        'avatar_url': '',
      });
    }
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ── TEMPAT BERSEJARAH ──
  static Future<List<Place>> getPlaces({String? category}) async {
    var query = _client.from('places').select();
    if (category != null && category != 'Semua') {
      query = query.eq('category', category);
    }
    final rows = await query.order('added_date', ascending: false);
    final places = <Place>[];
    for (final r in rows) {
      final modules = await getModulesForPlace(r['id'] as String);
      places.add(_placeFromRow(r, modules));
    }
    return places;
  }

  static Future<Place?> getPlace(String id) async {
    final rows = await _client.from('places').select().eq('id', id);
    if (rows.isEmpty) return null;
    final modules = await getModulesForPlace(id);
    return _placeFromRow(rows.first, modules);
  }

  static Place _placeFromRow(Map<String, dynamic> r, List<HistoricalModule> modules) {
    final gallery = (r['gallery_images'] as String?)
            ?.split('|')
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    return Place(
      id: r['id'] as String,
      name: r['name'] as String,
      location: r['location'] as String,
      province: r['province'] as String,
      category: r['category'] as String,
      description: r['description'] as String,
      imageUrl: r['image_url'] as String,
      galleryImages: gallery,
      openHours: r['open_hours'] as String? ?? '08:00 - 16:00',
      ticketPrice: r['ticket_price'] as String? ?? 'Gratis',
      moduleCount: r['module_count'] as int? ?? 0,
      modules: modules,
      addedDate: DateTime.tryParse(r['added_date'] as String? ?? ''),
      gmapsUrl: r['gmaps_url'] as String?,
    );
  }

  // ── MODUL PEMBELAJARAN ──
  static Future<List<HistoricalModule>> getModulesForPlace(String placeId) async {
    final rows = await _client
        .from('modules')
        .select()
        .eq('place_id', placeId)
        .order('order_index');
    return rows.map((r) {
      final facts = (r['key_facts'] as String?)
              ?.split('|')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];
      return HistoricalModule(
        id: r['id'] as String,
        title: r['title'] as String,
        placeId: r['place_id'] as String,
        content: r['content'] as String,
        period: r['period'] as String? ?? '',
        keyFacts: facts,
      );
    }).toList();
  }

  // ── KUIS ──
  static Future<List<Quiz>> getQuizzesForPlace(String placeId, String userId) async {
    final rows = await _client
        .from('quizzes')
        .select()
        .eq('place_id', placeId)
        .order('order_index');
    final quizzes = <Quiz>[];

    for (final r in rows) {
      final questions = await _getQuestions(r['id'] as String);
      final progress = await _client
          .from('quiz_progress')
          .select()
          .eq('user_id', userId)
          .eq('quiz_id', r['id'] as String);
      final isCompleted = progress.isNotEmpty;
      final score = isCompleted ? (progress.first['score'] as num?)?.toDouble() : null;

      // Logika pengunci: periksa apakah kuis sebelumnya sudah diselesaikan
      final idx = rows.indexOf(r);
      bool isLocked = (r['is_locked'] as bool?) == true;
      if (idx > 0 && !isLocked) {
        final prevId = rows[idx - 1]['id'] as String;
        final prevProgress = await _client
            .from('quiz_progress')
            .select()
            .eq('user_id', userId)
            .eq('quiz_id', prevId);
        if (prevProgress.isEmpty) isLocked = true;
      }

      quizzes.add(Quiz(
        id: r['id'] as String,
        placeId: r['place_id'] as String,
        placeName: r['place_name'] as String,
        title: r['title'] as String,
        difficulty: r['difficulty'] as String,
        questionCount: r['question_count'] as int? ?? 5,
        durationMinutes: r['duration_minutes'] as int? ?? 5,
        xpReward: r['xp_reward'] as int? ?? 50,
        questions: questions,
        isLocked: isLocked,
        isCompleted: isCompleted,
        score: score,
      ));
    }
    return quizzes;
  }

  static Future<List<Question>> _getQuestions(String quizId) async {
    final rows = await _client
        .from('questions')
        .select()
        .eq('quiz_id', quizId)
        .order('order_index');
    return rows.map((r) {
      final opts = (r['options'] as String).split('|');
      return Question(
        id: r['id'] as String,
        text: r['text'] as String,
        options: opts,
        correctIndex: r['correct_index'] as int,
        explanation: r['explanation'] as String?,
      );
    }).toList();
  }

  // ── PROFIL PENGGUNA ──
  static Future<UserProfile> getUser(String userId) async {
    final rows = await _client.from('user_profiles').select().eq('id', userId);
    if (rows.isEmpty) {
      return const UserProfile(id: '', name: 'User', email: '');
    }
    final r = rows.first;

    // Agregasi progres kuis
    final qp = await _client
        .from('quiz_progress')
        .select()
        .eq('user_id', userId);
    final totalXp = qp.fold<int>(0, (sum, item) => sum + ((item['xp_earned'] as num?)?.toInt() ?? 0));
    final quizzesCompleted = qp.length;

    // Tempat yang sudah dikunjungi (distinct placeId dari kuis yang sudah selesai)
    final completedQuizIds = qp.map((p) => p['quiz_id'] as String).toSet();
    int placesVisited = 0;
    if (completedQuizIds.isNotEmpty) {
      final quizRows = await _client
          .from('quizzes')
          .select('place_id')
          .inFilter('id', completedQuizIds.toList());
      placesVisited = quizRows.map((q) => q['place_id'] as String).toSet().length;
    }

    // Lencana
    final badgeRows = await _client
        .from('badges')
        .select()
        .eq('user_id', userId);
    final badges = badgeRows.map((b) => b['badge'] as String).toList();

    return UserProfile(
      id: r['id'] as String,
      name: r['name'] as String,
      email: r['email'] as String,
      avatarUrl: r['avatar_url'] as String? ?? '',
      totalXp: totalXp,
      quizzesCompleted: quizzesCompleted,
      placesVisited: placesVisited,
      badges: badges,
    );
  }


  // ── PROGRES ──
  static Future<void> saveQuizResult(String userId, String quizId, double score, int xpEarned) async {
    final existing = await _client
        .from('quiz_progress')
        .select()
        .eq('user_id', userId)
        .eq('quiz_id', quizId);

    if (existing.isNotEmpty) {
      final oldScore = (existing.first['score'] as num?)?.toDouble() ?? 0;
      if (score > oldScore) {
        await _client.from('quiz_progress').update({
          'score': score,
          'xp_earned': xpEarned,
          'completed_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId).eq('quiz_id', quizId);
      }
    } else {
      await _client.from('quiz_progress').insert({
        'user_id': userId,
        'quiz_id': quizId,
        'score': score,
        'xp_earned': xpEarned,
        'completed_at': DateTime.now().toIso8601String(),
      });
    }
    await _checkBadges(userId);
  }

  static Future<void> markModuleRead(String userId, String moduleId) async {
    final existing = await _client
        .from('module_progress')
        .select()
        .eq('user_id', userId)
        .eq('module_id', moduleId);
    if (existing.isEmpty) {
      await _client.from('module_progress').insert({
        'user_id': userId,
        'module_id': moduleId,
        'read_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<bool> isModuleRead(String userId, String moduleId) async {
    final rows = await _client
        .from('module_progress')
        .select()
        .eq('user_id', userId)
        .eq('module_id', moduleId);
    return rows.isNotEmpty;
  }

  static Future<int> getReadModuleCount(String userId, String placeId) async {
    final moduleRows = await _client
        .from('modules')
        .select('id')
        .eq('place_id', placeId);
    final moduleIds = moduleRows.map((m) => m['id'] as String).toList();
    if (moduleIds.isEmpty) return 0;

    final readRows = await _client
        .from('module_progress')
        .select()
        .eq('user_id', userId)
        .inFilter('module_id', moduleIds);
    return readRows.length;
  }

  static Future<void> _checkBadges(String userId) async {
    final qCount = await _client
        .from('quiz_progress')
        .select()
        .eq('user_id', userId);
    final count = qCount.length;
    if (count >= 1) await _addBadge(userId, 'Pemula Sejarah');
    if (count >= 3) await _addBadge(userId, 'Penjelajah Benteng');
    if (count >= 5) await _addBadge(userId, 'Kurator Muda');
    if (count >= 9) await _addBadge(userId, 'Maestro Kuis');
  }

  static Future<void> _addBadge(String userId, String badge) async {
    final existing = await _client
        .from('badges')
        .select()
        .eq('user_id', userId)
        .eq('badge', badge);
    if (existing.isEmpty) {
      await _client.from('badges').insert({
        'user_id': userId,
        'badge': badge,
        'earned_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ── BOOKMARK ──
  static Future<List<String>> getBookmarkedPlaceIds(String userId) async {
    final rows = await _client
        .from('bookmarks')
        .select('place_id')
        .eq('user_id', userId);
    return rows.map((r) => r['place_id'] as String).toList();
  }


  static Future<void> addBookmark(String userId, String placeId) async {
    await _client.from('bookmarks').upsert({
      'user_id': userId,
      'place_id': placeId,
    });
  }

  static Future<void> removeBookmark(String userId, String placeId) async {
    await _client
        .from('bookmarks')
        .delete()
        .eq('user_id', userId)
        .eq('place_id', placeId);
  }

  static Future<List<Place>> getBookmarkedPlaces(String userId) async {
    final ids = await getBookmarkedPlaceIds(userId);
    if (ids.isEmpty) return [];
    final rows = await _client
        .from('places')
        .select()
        .inFilter('id', ids);
    final places = <Place>[];
    for (final r in rows) {
      final modules = await getModulesForPlace(r['id'] as String);
      places.add(_placeFromRow(r, modules));
    }
    return places;
  }

}
