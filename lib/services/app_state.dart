import 'package:flutter/material.dart';
import 'package:archivafinal/models/place_model.dart';
import 'package:archivafinal/models/quiz_model.dart';
import 'package:archivafinal/models/user_model.dart';
import 'package:archivafinal/services/supabase_service.dart';

class AppState extends ChangeNotifier {
  List<Place> _places = [];
  UserProfile? _user;
  bool _loading = true;
  List<String> _bookmarkedIds = [];

  List<Place> get places => _places;
  UserProfile get user => _user ?? const UserProfile(id: '', name: 'User', email: '');
  bool get loading => _loading;
  List<String> get bookmarkedIds => _bookmarkedIds;

  /// ID pengguna yang sedang login dari Supabase Auth
  String get currentUserId => SupabaseService.currentUserId ?? '';

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      await refreshAll();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    _places = await SupabaseService.getPlaces();
    _user = await SupabaseService.getUser(userId);
    _bookmarkedIds = await SupabaseService.getBookmarkedPlaceIds(userId);
    notifyListeners();
  }


  Future<List<Quiz>> getQuizzesForPlace(String placeId) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];
    return SupabaseService.getQuizzesForPlace(placeId, userId);
  }

  Future<void> completeQuiz(String quizId, double score, int xpEarned) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    await SupabaseService.saveQuizResult(userId, quizId, score, xpEarned);
    await refreshAll();
  }

  Future<void> readModule(String moduleId) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    await SupabaseService.markModuleRead(userId, moduleId);
    notifyListeners();
  }

  Future<bool> isModuleRead(String moduleId) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return false;
    return SupabaseService.isModuleRead(userId, moduleId);
  }

  Future<int> getReadModuleCount(String placeId) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return 0;
    return SupabaseService.getReadModuleCount(userId, placeId);
  }

  bool isBookmarked(String placeId) => _bookmarkedIds.contains(placeId);

  Future<void> toggleBookmark(String placeId) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;
    if (_bookmarkedIds.contains(placeId)) {
      await SupabaseService.removeBookmark(userId, placeId);
      _bookmarkedIds.remove(placeId);
    } else {
      await SupabaseService.addBookmark(userId, placeId);
      _bookmarkedIds.add(placeId);
    }
    notifyListeners();
  }

  Future<List<Place>> getBookmarkedPlaces() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];
    return SupabaseService.getBookmarkedPlaces(userId);
  }
}
