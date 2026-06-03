import 'package:flutter/material.dart';
import 'package:archivafinal/core/constants/app_colors.dart';

/// Bantuan (Help) screen with FAQ accordion and contact options.
class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  static const _faqItems = <_FaqItem>[
    _FaqItem(
      question: 'Bagaimana cara memulai kuis?',
      answer:
          'Buka halaman detail tempat bersejarah, lalu scroll ke bawah dan pilih kuis yang tersedia. '
          'Setiap kuis memiliki level kesulitan berbeda: Pemula, Menengah, dan Mahir.',
    ),
    _FaqItem(
      question: 'Apa itu XP dan bagaimana cara mendapatkannya?',
      answer:
          'XP (Experience Points) adalah poin pengalaman yang Anda dapatkan setiap menyelesaikan kuis. '
          'Semakin tinggi skor Anda, semakin banyak XP yang didapat. XP digunakan untuk menentukan level dan rank Anda.',
    ),
    _FaqItem(
      question: 'Bagaimana sistem badge bekerja?',
      answer:
          'Badge diberikan otomatis berdasarkan pencapaian Anda. Contoh: menyelesaikan 1 kuis akan memberikan badge '
          '"Pemula Sejarah", menyelesaikan 3 kuis memberikan "Penjelajah Benteng", dan seterusnya.',
    ),
    _FaqItem(
      question: 'Bisakah saya mengulang kuis?',
      answer:
          'Ya! Anda bisa mengulang kuis kapan saja. Jika skor baru lebih tinggi dari skor sebelumnya, '
          'maka skor dan XP akan diperbarui.',
    ),
    _FaqItem(
      question: 'Bagaimana cara membuka kuis yang terkunci?',
      answer:
          'Kuis terkunci akan terbuka setelah Anda menyelesaikan kuis sebelumnya di tempat yang sama. '
          'Selesaikan kuis secara berurutan untuk membuka semua level.',
    ),
    _FaqItem(
      question: 'Apakah data saya aman?',
      answer:
          'Data disimpan secara lokal di perangkat Anda. Pastikan untuk tidak menghapus data aplikasi '
          'agar progress Anda tetap tersimpan.',
    ),
  ];

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
        title: const Text('Bantuan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Illustration header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.25),
                    AppColors.primaryDark.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: AppColors.accent, size: 40),
                ),
                const SizedBox(height: 14),
                const Text('Ada pertanyaan?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                const Text('Temukan jawaban di bawah atau hubungi kami',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ]),
            ),

            const SizedBox(height: 24),

            // FAQ section
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text('Pertanyaan Umum (FAQ)',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            ..._faqItems.map((faq) => _FaqTile(faq: faq)),

            const SizedBox(height: 28),

            // Contact section
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text('Hubungi Kami',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            _contactCard(
              icon: Icons.email_rounded,
              color: AppColors.accent,
              title: 'Email',
              subtitle: 'support@archiva.id',
            ),
            const SizedBox(height: 10),
            _contactCard(
              icon: Icons.chat_rounded,
              color: AppColors.accentGold,
              title: 'Live Chat',
              subtitle: 'Senin - Jumat, 09:00 - 17:00',
            ),
            const SizedBox(height: 10),
            _contactCard(
              icon: Icons.bug_report_rounded,
              color: AppColors.accentRed,
              title: 'Laporkan Bug',
              subtitle: 'Bantu kami memperbaiki masalah',
            ),

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
      ]),
    );
  }
}

// ── FAQ data & tile ──────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _FaqTile extends StatefulWidget {
  final _FaqItem faq;
  const _FaqTile({required this.faq});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _expanded
            ? AppColors.accent.withValues(alpha: 0.1)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: _expanded
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.35), width: 1)
            : null,
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(widget.faq.question,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary, size: 22),
                ),
              ]),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(widget.faq.answer,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
                ),
                crossFadeState:
                    _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
