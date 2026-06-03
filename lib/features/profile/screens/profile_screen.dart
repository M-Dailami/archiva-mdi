import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/core/utils/helpers.dart';
import 'package:archivafinal/services/app_state.dart';
import 'package:archivafinal/services/supabase_service.dart';
import 'package:archivafinal/models/user_model.dart';
import 'package:archivafinal/features/profile/screens/pengaturan_screen.dart';
import 'package:archivafinal/features/profile/screens/bantuan_screen.dart';
import 'package:archivafinal/features/profile/screens/tentang_archiva_screen.dart';
import 'package:archivafinal/features/profile/screens/bookmarks_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh live stats from Supabase when profile tab opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    final level = XpUtils.levelFromXp(user.totalXp);
    final progress = XpUtils.progressInLevel(user.totalXp);
    final nextXp = XpUtils.xpForLevel(level + 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 10),
          CircleAvatar(radius: 44, backgroundColor: AppColors.surfaceDark,
            child: const Icon(Icons.person, size: 48, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
            child: Text(XpUtils.rankTitle(user.totalXp), style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600))),
          const SizedBox(height: 24),
          // XP card
          Container(width: double.infinity, padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Level & XP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.xpGold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text('Level $level', style: const TextStyle(fontSize: 12, color: AppColors.xpGold, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${user.totalXp} XP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('$nextXp XP', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 8,
                  backgroundColor: AppColors.xpBarBackground, valueColor: const AlwaysStoppedAnimation(AppColors.xpBar))),
              const SizedBox(height: 6),
              Text('${(progress * 100).toInt()}% menuju level berikutnya', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
          const SizedBox(height: 16),
          // Stats
          Row(children: [
            Expanded(child: _statCard(Icons.quiz, '${user.quizzesCompleted}', 'Kuis Selesai', AppColors.accentGreen)),
            const SizedBox(width: 12),
            Expanded(child: _statCard(Icons.place, '${user.placesVisited}', 'Tempat Dijelajahi', AppColors.accent)),
          ]),
          const SizedBox(height: 16),
          // Badges
          if (user.badges.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Badge Collection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Icon(Icons.emoji_events, color: AppColors.xpGold, size: 22),
              ]),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: user.badges.map((b) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star, size: 14, color: AppColors.xpGold),
                  const SizedBox(width: 6),
                  Text(b, style: const TextStyle(fontSize: 12, color: Colors.white)),
                ]))).toList()),
            ])),
          const SizedBox(height: 16),
          // Ranks
          Container(width: double.infinity, padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Jenjang Rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 14),
              ...RankData.ranks.map((r) {
                final isActive = user.totalXp >= r.minXp;
                final isCurrent = XpUtils.rankTitle(user.totalXp) == r.title;
                return Container(margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(10),
                    border: isCurrent ? Border.all(color: AppColors.accent.withValues(alpha: 0.5)) : null),
                  child: Row(children: [
                    Icon(isActive ? Icons.check_circle : Icons.lock_outline, size: 18,
                      color: isActive ? AppColors.accentGreen : AppColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.textMuted)),
                      Text('${r.minXp} - ${r.maxXp} XP', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ])),
                    Text('Lv.${r.level}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.xpGold : AppColors.textMuted)),
                  ]));
              }),
            ])),
          const SizedBox(height: 16),
          // Settings menu
          Container(width: double.infinity, padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              _menuItem(context, Icons.bookmark, 'Koleksi Bookmark',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()))),
              _menuItem(context, Icons.settings, 'Pengaturan',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PengaturanScreen()))),
              _menuItem(context, Icons.help_outline, 'Bantuan',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BantuanScreen()))),
              _menuItem(context, Icons.info_outline, 'Tentang Archiva',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TentangArchivaScreen()))),
              _menuItem(context, Icons.logout, 'Keluar', color: AppColors.accentRed,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.cardBackground,
                        title: const Text('Keluar', style: TextStyle(color: Colors.white)),
                        content: const Text('Apakah Anda yakin ingin keluar?', style: TextStyle(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary))),
                          TextButton(onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Keluar', style: TextStyle(color: AppColors.accentRed))),
                        ],
                      ),
                    );
                    if (confirm == true) await SupabaseService.signOut();
                  }),
            ])),
          const SizedBox(height: 24),
        ]))),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
    child: Column(children: [
      Icon(icon, size: 28, color: color), const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
    ]));

  Widget _menuItem(BuildContext context, IconData icon, String label, {Color? color, VoidCallback? onTap}) => ListTile(
    leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
    title: Text(label, style: TextStyle(fontSize: 14, color: color ?? Colors.white)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
    onTap: onTap ?? () {});
}
