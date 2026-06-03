import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/core/widgets/common_widgets.dart';
import 'package:archivafinal/services/app_state.dart';
import 'package:archivafinal/features/place_detail/screens/place_detail_screen.dart';

/// Kategori Tempat screen – replaces the old Explore/Search screen.
/// Shows a grid of place categories with icons and colors,
/// tapping a category shows filtered places.
class KategoriTempatScreen extends StatefulWidget {
  const KategoriTempatScreen({super.key});
  @override
  State<KategoriTempatScreen> createState() => _KategoriTempatScreenState();
}

class _KategoriTempatScreenState extends State<KategoriTempatScreen> {
  String? _activeCategory;

  static const _categoryMeta = <String, _CategoryInfo>{
    'Arsitektur': _CategoryInfo(Icons.account_balance_rounded, Color(0xFF4DB6AC), Color(0xFF00897B)),
    'Sejarah': _CategoryInfo(Icons.menu_book_rounded, Color(0xFFFFB74D), Color(0xFFF57C00)),
    'Peristiwa': _CategoryInfo(Icons.flag_rounded, Color(0xFFEF5350), Color(0xFFC62828)),
    'Tokoh': _CategoryInfo(Icons.person_pin_rounded, Color(0xFF7986CB), Color(0xFF3949AB)),
  };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allPlaces = state.places;

    // Filter places for the active category
    final filteredPlaces = _activeCategory != null
        ? allPlaces.where((p) => p.category == _activeCategory).toList()
        : <dynamic>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _activeCategory == null
            ? _buildCategoryGrid(allPlaces)
            : _buildCategoryDetail(filteredPlaces),
      ),
    );
  }

  // ── Category grid ──────────────────────────────────────────────
  Widget _buildCategoryGrid(List allPlaces) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Kategori Tempat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        const Text('Jelajahi tempat bersejarah berdasarkan kategori',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        // Category cards grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
          children: _categoryMeta.entries.map((entry) {
            final name = entry.key;
            final info = entry.value;
            final count = allPlaces.where((p) => p.category == name).length;

            return _CategoryCard(
              name: name,
              icon: info.icon,
              color: info.color,
              darkColor: info.darkColor,
              count: count,
              onTap: () => setState(() => _activeCategory = name),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // "Semua Tempat" section
        const Text('Semua Tempat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        Text('${allPlaces.length} tempat bersejarah terdaftar',
            style: const TextStyle(fontSize: 12, color: Colors.white)),
        const SizedBox(height: 14),
        ...allPlaces.map((p) => PlaceCard(
              name: p.name,
              location: p.location,
              category: p.category,
              imageUrl: p.imageUrl,
              isHorizontal: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: p.id))),
            )),
        const SizedBox(height: 12),
      ]),
    );
  }

  // ── Filtered detail view ───────────────────────────────────────
  Widget _buildCategoryDetail(List filteredPlaces) {
    final info = _categoryMeta[_activeCategory]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => setState(() => _activeCategory = null),
            ),
            const SizedBox(width: 4),
            Icon(info.icon, color: info.color, size: 26),
            const SizedBox(width: 10),
            Text(_activeCategory!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: info.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Text('${filteredPlaces.length} Tempat',
                  style: TextStyle(fontSize: 11, color: info.color, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        // List
        Expanded(
          child: filteredPlaces.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(info.icon, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text('Belum ada tempat di kategori ini',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredPlaces.length,
                  itemBuilder: (_, i) {
                    final p = filteredPlaces[i];
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
        ),
      ],
    );
  }
}

// ── Supporting widgets ───────────────────────────────────────────

class _CategoryInfo {
  final IconData icon;
  final Color color;
  final Color darkColor;
  const _CategoryInfo(this.icon, this.color, this.darkColor);
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final Color darkColor;
  final int count;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.darkColor,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [darkColor.withValues(alpha: 0.55), darkColor.withValues(alpha: 0.25)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text('$count Tempat',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
