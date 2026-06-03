import 'package:flutter/material.dart';
import 'package:archivafinal/core/constants/app_colors.dart';

/// Pengaturan (Settings) screen.
class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});
  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _notifikasi = true;
  bool _suara = true;
  bool _autoSave = true;
  String _bahasa = 'Indonesia';

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
        title: const Text('Pengaturan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Umum ──
            _sectionTitle('Umum'),
            _settingsCard([
              _switchTile(
                icon: Icons.notifications_rounded,
                title: 'Notifikasi',
                subtitle: 'Terima pemberitahuan kuis baru',
                value: _notifikasi,
                onChanged: (v) => setState(() => _notifikasi = v),
              ),
              _divider(),
              _switchTile(
                icon: Icons.volume_up_rounded,
                title: 'Efek Suara',
                subtitle: 'Suara saat menjawab kuis',
                value: _suara,
                onChanged: (v) => setState(() => _suara = v),
              ),
              _divider(),
              _switchTile(
                icon: Icons.save_rounded,
                title: 'Auto-save Progress',
                subtitle: 'Simpan otomatis setiap selesai modul',
                value: _autoSave,
                onChanged: (v) => setState(() => _autoSave = v),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Preferensi ──
            _sectionTitle('Preferensi'),
            _settingsCard([
              _dropdownTile(
                icon: Icons.language_rounded,
                title: 'Bahasa',
                value: _bahasa,
                items: ['Indonesia', 'English'],
                onChanged: (v) => setState(() => _bahasa = v!),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Data ──
            _sectionTitle('Data & Penyimpanan'),
            _settingsCard([
              _actionTile(
                icon: Icons.cached_rounded,
                title: 'Hapus Cache',
                subtitle: 'Bersihkan data sementara',
                onTap: () => _showSnack('Cache berhasil dihapus'),
              ),
              _divider(),
              _actionTile(
                icon: Icons.restart_alt_rounded,
                title: 'Reset Progress',
                subtitle: 'Hapus semua data kemajuan',
                titleColor: AppColors.accentRed,
                onTap: () => _confirmReset(),
              ),
            ]),

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  // ── Builders ─────────────────────────────────────────

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.6)),
      );

  Widget _settingsCard(List<Widget> children) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: children),
      );

  Widget _divider() => Divider(
        height: 1,
        thickness: 0.5,
        indent: 56,
        color: AppColors.surfaceDark.withValues(alpha: 0.6),
      );

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.accent, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      subtitle:
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
        inactiveTrackColor: AppColors.surfaceDark,
      ),
    );
  }

  Widget _dropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accentGold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.accentGold, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: AppColors.cardBackground,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
        items: items
            .map((i) => DropdownMenuItem(
                value: i, child: Text(i, style: const TextStyle(fontSize: 13, color: Colors.white))))
            .toList(),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.textSecondary).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: titleColor ?? AppColors.textSecondary, size: 20),
      ),
      title: Text(title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: titleColor ?? Colors.white)),
      subtitle:
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Progress?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Semua data kemajuan, badge, dan skor kuis akan dihapus. Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnack('Progress berhasil di-reset');
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
