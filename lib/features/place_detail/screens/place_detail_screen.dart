import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/models/place_model.dart';
import 'package:archivafinal/services/app_state.dart';
import 'package:archivafinal/services/supabase_service.dart';
import 'package:archivafinal/features/quiz/screens/quiz_detail_screen.dart';
import 'package:archivafinal/features/module/screens/module_detail_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});
  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  Place? _place;
  int _readCount = 0;
  bool _bookmarked = false;
  bool _bookmarkLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final place = await SupabaseService.getPlace(widget.placeId);
    final readCount = await context.read<AppState>().getReadModuleCount(widget.placeId);
    final bookmarked = context.read<AppState>().isBookmarked(widget.placeId);
    if (mounted) setState(() { _place = place; _readCount = readCount; _bookmarked = bookmarked; });
  }

  Future<void> _toggleBookmark() async {
    if (_bookmarkLoading) return;
    setState(() => _bookmarkLoading = true);
    await context.read<AppState>().toggleBookmark(widget.placeId);
    if (mounted) {
      setState(() {
        _bookmarked = context.read<AppState>().isBookmarked(widget.placeId);
        _bookmarkLoading = false;
      });
    }
  }

  Future<void> _openGmaps() async {
    final url = _place?.gmapsUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_place == null) {
      return const Scaffold(backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    }
    final place = _place!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Header image
        Stack(children: [
          SizedBox(
            height: 240,
            width: double.infinity,
            child: place.imageUrl.startsWith('http')
                ? Image.network(
                    place.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            color: AppColors.surfaceDark,
                            child: const Center(
                              child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))),
                    errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceDark,
                        child: const Icon(Icons.broken_image_rounded, size: 60, color: AppColors.textMuted)),
                  )
                : Container(
                    color: AppColors.surfaceDark,
                    child: const Icon(Icons.photo_library, size: 60, color: AppColors.textMuted)),
          ),
          // Gradient overlay for readability
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.85)])))),
          Positioned(top: 40, left: 16,
            child: GestureDetector(onTap: () => Navigator.pop(context),
              child: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryDark.withValues(alpha: 0.6), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22)))),
          Positioned(top: 40, right: 16,
            child: GestureDetector(
              onTap: _toggleBookmark,
              child: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryDark.withValues(alpha: 0.6), shape: BoxShape.circle),
                child: _bookmarkLoading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(
                        _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _bookmarked ? AppColors.accent : Colors.white,
                        size: 22)))),
        ]),
        // Content
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20)),
              child: Text(place.category, style: const TextStyle(fontSize: 12, color: Colors.white))),
            const SizedBox(height: 12),
            Text(place.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(place.location, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Text(place.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 16),
            // Gallery
            if (place.galleryImages.isNotEmpty) SizedBox(height: 80,
              child: ListView.separated(scrollDirection: Axis.horizontal,
                itemCount: place.galleryImages.length.clamp(0, 4),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final isOverflow = i == 3 && place.galleryImages.length > 4;
                  final url = place.galleryImages[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(children: [
                      url.startsWith('http')
                          ? Image.network(url, width: 90, height: 80, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 90, height: 80, color: AppColors.surfaceDark,
                                child: const Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 24)))
                          : Container(width: 90, height: 80, color: AppColors.surfaceDark,
                              child: const Icon(Icons.photo, color: AppColors.textMuted, size: 24)),
                      if (isOverflow)
                        Container(
                          width: 90, height: 80,
                          color: Colors.black.withValues(alpha: 0.55),
                          child: Center(child: Text('+${place.galleryImages.length - 3}',
                            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)))),
                    ]),
                  );
                })),
            const SizedBox(height: 20),
            // Info chips
            Row(children: [
              Expanded(child: _infoChip('Jam Buka', place.openHours)),
              const SizedBox(width: 12),
              Expanded(child: _infoChip('Harga Tiket', place.ticketPrice)),
            ]),
            // Google Maps button
            if (place.gmapsUrl != null && place.gmapsUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openGmaps,
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: const Text('Buka di Google Maps'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                )),
            ],
            const SizedBox(height: 20),
            // Module progress
            Row(children: [
              const Expanded(child: Text('Modul Pembelajaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
              Text('$_readCount/${place.modules.length} dibaca', style: const TextStyle(fontSize: 12, color: AppColors.accent)),
            ]),
            const SizedBox(height: 12),
            ...place.modules.asMap().entries.map((e) => _moduleCard(e.value, e.key, place)),
            const SizedBox(height: 20),
          ]),
        )),
        // Bottom CTA
        Container(padding: const EdgeInsets.all(16), color: AppColors.primaryDarker,
          child: SafeArea(top: false,
            child: SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizDetailScreen(placeId: place.id))),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Mulai Kuis Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))))),
      ]),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      ]));
  }

  Widget _moduleCard(HistoricalModule m, int index, Place place) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => ModuleDetailScreen(module: m, placeName: place.name,
            moduleIndex: index, totalModules: place.modules.length)));
        _load(); // Refresh read count
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surfaceDark, shape: BoxShape.circle),
            child: Center(child: Text('${index + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            if (m.period.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(m.period, style: const TextStyle(fontSize: 11, color: AppColors.accentGold)),
            ],
            const SizedBox(height: 4),
            Text('${m.keyFacts.length} fakta penting', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 22),
        ]),
      ),
    );
  }
}
