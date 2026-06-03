import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/core/widgets/common_widgets.dart';
import 'package:archivafinal/models/place_model.dart';
import 'package:archivafinal/services/app_state.dart';
import 'package:archivafinal/features/place_detail/screens/place_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Place> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final places = await context.read<AppState>().getBookmarkedPlaces();
    if (mounted) {
      setState(() {
        _bookmarks = places;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarker,
        title: const Text('Koleksi Bookmark',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _bookmarks.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.bookmark_border, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('Belum ada bookmark',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 8),
                    const Text('Simpan tempat favoritmu dari halaman detail',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _bookmarks.length,
                  itemBuilder: (_, i) {
                    final p = _bookmarks[i];
                    return PlaceCard(
                      name: p.name,
                      location: p.location,
                      category: p.category,
                      imageUrl: p.imageUrl,
                      isHorizontal: true,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: p.id))),
                    );
                  },
                ),
    );
  }
}
