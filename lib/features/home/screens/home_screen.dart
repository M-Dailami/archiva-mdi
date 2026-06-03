import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/core/widgets/common_widgets.dart';
import 'package:archivafinal/services/app_state.dart';
import 'package:archivafinal/features/place_detail/screens/place_detail_screen.dart';
import 'package:archivafinal/features/quiz/screens/quiz_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToKategori;
  const HomeScreen({super.key, this.onNavigateToKategori});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Semua';
  final _categories = ['Semua', 'Arsitektur', 'Sejarah', 'Peristiwa', 'Tokoh'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.loading) {
      return const Scaffold(backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    }
    final user = state.user;
    final allPlaces = state.places;
    final filtered = _selectedCategory == 'Semua'
      ? allPlaces
      : allPlaces.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // User header
            Row(children: [
              CircleAvatar(radius: 28, backgroundColor: AppColors.surfaceDark,
                child: const Icon(Icons.person, size: 32, color: AppColors.textSecondary)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
                  child: Text('${user.totalXp} XP', style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w500)),
                ),
              ])),
            ]),
            const SizedBox(height: 28),
            Row(children: [
              const Expanded(child: Text('Rekomendasi Tempat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
              TextButton(onPressed: () => widget.onNavigateToKategori?.call(), child: const Text('Lihat Semua', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
            ]),
            const SizedBox(height: 8),
            SizedBox(height: 36, child: ListView.separated(
              scrollDirection: Axis.horizontal, itemCount: _categories.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (_, i) => CategoryChip(label: _categories[i],
                isSelected: _selectedCategory == _categories[i],
                onTap: () => setState(() => _selectedCategory = _categories[i])),
            )),
            const SizedBox(height: 16),
            SizedBox(height: 210,
              child: filtered.isEmpty
                ? const Center(child: Text('Tidak ada tempat', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
                    scrollDirection: Axis.horizontal, itemCount: filtered.length,
                    separatorBuilder: (_, i) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      return PlaceCard(name: p.name, location: p.location, category: p.category, imageUrl: p.imageUrl,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: p.id))));
                    }),
            ),
            const SizedBox(height: 24),
            // Quiz CTA
            if (allPlaces.isNotEmpty) GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => QuizDetailScreen(placeId: allPlaces.first.id))),
              child: Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Container(width: 56, height: 56,
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.star, color: AppColors.accent, size: 30)),
                  const SizedBox(width: 16),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Coba Quiz Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Dapatkan 50 XP per kuis!', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ])),
                ]),
              ),
            ),
            const SizedBox(height: 28),
            Row(children: [
              const Expanded(child: Text('Baru Ditambahkan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
              TextButton(onPressed: () => widget.onNavigateToKategori?.call(), child: const Text('Lihat Semua', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
            ]),
            const SizedBox(height: 8),
            ...allPlaces.take(2).map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PlaceCard(name: p.name, location: p.location, category: p.category, imageUrl: p.imageUrl,
                isHorizontal: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: p.id)))),
            )),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
