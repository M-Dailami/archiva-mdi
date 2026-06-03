import 'package:flutter/material.dart';
import 'package:archivafinal/core/constants/app_colors.dart';

/// Tentang Archiva (About) screen.
class TentangArchivaScreen extends StatelessWidget {
  const TentangArchivaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tentang Archiva',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(children: [
            const SizedBox(height: 20),

            // Logo & version
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.35),
                    AppColors.primaryDark.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1.5),
              ),
              child: const Center(
                child: Text('A',
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Archiva',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Versi 0.1.0',
                  style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            const Text('Panduan Literasi Sejarah Interaktif',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

            const SizedBox(height: 32),

            // Description card
            _infoCard(
              icon: Icons.auto_stories_rounded,
              iconColor: AppColors.accent,
              title: 'Tentang Aplikasi',
              body:
                  'Archiva adalah aplikasi panduan literasi sejarah interaktif yang memadukan '
                  'eksplorasi tempat bersejarah dengan sistem gamifikasi. Melalui kuis, XP, rank, '
                  'dan badge, Archiva meningkatkan keterlibatan pengguna dalam mempelajari sejarah '
                  'Indonesia secara menyenangkan dan edukatif.',
            ),

            const SizedBox(height: 14),

            // Mission card
            _infoCard(
              icon: Icons.flag_rounded,
              iconColor: AppColors.accentGold,
              title: 'Misi Kami',
              body:
                  'Membuat pembelajaran sejarah menjadi pengalaman yang menarik, interaktif, '
                  'dan mudah diakses oleh semua kalangan. Kami percaya bahwa memahami sejarah '
                  'adalah kunci untuk membangun masa depan yang lebih baik.',
            ),

            const SizedBox(height: 14),

            // Features card
            _infoCard(
              icon: Icons.star_rounded,
              iconColor: AppColors.accentGreen,
              title: 'Fitur Utama',
              body: null,
              bulletPoints: const [
                'Eksplorasi tempat bersejarah di Indonesia',
                'Modul pembelajaran interaktif',
                'Kuis dengan 3 tingkat kesulitan',
                'Sistem XP, Level, dan Rank',
                'Koleksi badge pencapaian',
                'Panduan offline-ready',
              ],
            ),

            const SizedBox(height: 28),

            // Team section
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text('Tim Pengembang',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            _teamMember(
              name: 'Tim Archiva',
              role: 'Development Team',
              icon: Icons.groups_rounded,
              color: AppColors.accent,
            ),

            const SizedBox(height: 28),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                const Text('Dibuat dengan ❤️ untuk pendidikan',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _footerLink(Icons.public, 'Website'),
                  const SizedBox(width: 20),
                  _footerLink(Icons.code, 'GitHub'),
                  const SizedBox(width: 20),
                  _footerLink(Icons.privacy_tip_outlined, 'Privasi'),
                ]),
                const SizedBox(height: 12),
                const Text('© 2026 Archiva. All rights reserved.',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ]),
            ),

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────

  static Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? body,
    List<String>? bulletPoints,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        const SizedBox(height: 12),
        if (body != null)
          Text(body,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.55)),
        if (bulletPoints != null)
          ...bulletPoints.map((bp) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(bp,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4))),
                ]),
              )),
      ]),
    );
  }

  static Widget _teamMember({
    required String name,
    required String role,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 2),
            Text(role,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
      ]),
    );
  }

  static Widget _footerLink(IconData icon, String label) {
    return Column(children: [
      Icon(icon, color: AppColors.textMuted, size: 20),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
    ]);
  }
}
