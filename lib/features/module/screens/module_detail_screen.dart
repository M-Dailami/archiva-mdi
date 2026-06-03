import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/models/place_model.dart';
import 'package:archivafinal/services/app_state.dart';

class ModuleDetailScreen extends StatefulWidget {
  final HistoricalModule module;
  final String placeName;
  final int moduleIndex;
  final int totalModules;

  const ModuleDetailScreen({
    super.key,
    required this.module,
    required this.placeName,
    required this.moduleIndex,
    required this.totalModules,
  });

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  bool _isRead = false;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    final state = context.read<AppState>();
    await state.readModule(widget.module.id);
    final read = await state.isModuleRead(widget.module.id);
    if (mounted) setState(() => _isRead = read);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    final paragraphs = m.content.split('\n').where((p) => p.trim().isNotEmpty).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDarker, AppColors.primaryDark]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(onTap: () => Navigator.pop(context),
                  child: Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.placeName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('Modul ${widget.moduleIndex + 1} dari ${widget.totalModules}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ])),
                if (_isRead) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.accentGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle, size: 14, color: AppColors.accentGreen),
                    SizedBox(width: 4),
                    Text('Dibaca', style: TextStyle(fontSize: 10, color: AppColors.accentGreen, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              // Progress bar
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (widget.moduleIndex + 1) / widget.totalModules, minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent))),
              const SizedBox(height: 16),
              Text(m.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
              if (m.period.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.accentGold),
                    const SizedBox(width: 6),
                    Text(m.period, style: const TextStyle(fontSize: 12, color: AppColors.accentGold, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ],
            ]),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Content paragraphs
                ...paragraphs.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(p.trim(), style: const TextStyle(
                    fontSize: 14, color: Colors.white, height: 1.8, letterSpacing: 0.2)),
                )),

                // Key Facts
                if (m.keyFacts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.lightbulb_outline, size: 20, color: AppColors.accentGold),
                        SizedBox(width: 8),
                        Text('Fakta Penting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ]),
                      const SizedBox(height: 12),
                      ...m.keyFacts.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(width: 24, height: 24, margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: Center(child: Text('${e.key + 1}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)))),
                          Expanded(child: Padding(padding: const EdgeInsets.only(top: 3),
                            child: Text(e.value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)))),
                        ]),
                      )),
                    ]),
                  ),
                ],
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
