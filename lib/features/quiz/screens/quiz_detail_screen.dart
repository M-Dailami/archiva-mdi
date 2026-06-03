import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/core/widgets/common_widgets.dart';
import 'package:archivafinal/models/quiz_model.dart';
import 'package:archivafinal/services/app_state.dart';
import 'package:archivafinal/services/supabase_service.dart';
import 'package:archivafinal/models/place_model.dart';
import 'package:archivafinal/features/quiz/screens/inside_quiz_screen.dart';

class QuizDetailScreen extends StatefulWidget {
  final String placeId;
  const QuizDetailScreen({super.key, required this.placeId});
  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  String _filter = 'Semua';
  final _filters = ['Semua', 'Pemula', 'Menengah', 'Mahir'];
  Place? _place;
  List<Quiz> _quizzes = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final place = await SupabaseService.getPlace(widget.placeId);
    final quizzes = await context.read<AppState>().getQuizzesForPlace(widget.placeId);
    if (mounted) setState(() { _place = place; _quizzes = quizzes; });
  }

  void _startQuiz(Quiz quiz) {
    if (quiz.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selesaikan kuis sebelumnya untuk membuka kuis ini'), backgroundColor: AppColors.accentRed));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => InsideQuizScreen(quiz: quiz)))
      .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_place == null) return const Scaffold(backgroundColor: AppColors.backgroundDark,
      body: Center(child: CircularProgressIndicator(color: AppColors.accent)));

    final filtered = _filter == 'Semua' ? _quizzes : _quizzes.where((q) => q.difficulty == _filter).toList();
    final completed = _quizzes.where((q) => q.isCompleted).length;
    final progress = _quizzes.isEmpty ? 0.0 : completed / _quizzes.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_place!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
              const Text('Pilih Kuiz', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              _stat('$completed', 'Selesai'),
              Container(width: 1, height: 36, color: AppColors.surfaceDark),
              _stat('${_quizzes.length}', 'Total'),
              Container(width: 1, height: 36, color: AppColors.surfaceDark),
              Expanded(child: Column(children: [
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: progress, minHeight: 6,
                    backgroundColor: AppColors.surfaceDark, valueColor: const AlwaysStoppedAnimation(AppColors.xpBar))),
              ])),
            ])),
          const SizedBox(height: 16),
          SizedBox(height: 36, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _filters.length,
            separatorBuilder: (_, i) => const SizedBox(width: 8),
            itemBuilder: (_, i) => CategoryChip(label: _filters[i], isSelected: _filter == _filters[i],
              onTap: () => setState(() => _filter = _filters[i])))),
          const SizedBox(height: 16),
          Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
            final q = filtered[i];
            return GestureDetector(onTap: () => _startQuiz(q),
              child: Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16),
                  border: q.isCompleted ? Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4)) : null),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.surfaceDark, shape: BoxShape.circle),
                      child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(q.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(8)),
                        child: Text(q.difficulty, style: const TextStyle(fontSize: 10, color: AppColors.accent))),
                    ])),
                    const SizedBox(width: 8),
                    Icon(q.isLocked ? Icons.lock : (q.isCompleted ? Icons.refresh : Icons.play_arrow),
                      color: q.isLocked ? AppColors.accentRed : AppColors.accentGreen, size: 28),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _quizStat('${q.questionCount}', 'Soal')),
                    Container(width: 1, height: 30, color: AppColors.surfaceDark),
                    Expanded(child: _quizStat('${q.durationMinutes}', 'Menit')),
                    Container(width: 1, height: 30, color: AppColors.surfaceDark),
                    Expanded(child: _quizStat('+${q.xpReward}', 'XP', color: AppColors.xpGold)),
                  ]),
                  if (q.isCompleted && q.score != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: q.score!, minHeight: 6,
                        backgroundColor: AppColors.surfaceDark, valueColor: const AlwaysStoppedAnimation(AppColors.accentGreen))),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('Nilai ${(q.score! * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: AppColors.accentGreen)),
                      const Spacer(),
                      const Text('Tap untuk mengulang', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ]),
                  ],
                  if (q.isLocked) ...[const SizedBox(height: 8),
                    const Text('Selesaikan Kuis Sebelumnya', style: TextStyle(fontSize: 11, color: AppColors.textMuted))],
                  if (!q.isLocked && !q.isCompleted) ...[const SizedBox(height: 8),
                    Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('Mulai Kuis Sekarang', style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600))))],
                ])));
          })),
        ]))),
    );
  }

  Widget _stat(String v, String l) => Expanded(child: Column(children: [
    Text(v, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
    Text(l, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))]));

  Widget _quizStat(String v, String l, {Color? color}) => Column(children: [
    Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
    Text(l, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))]);
}
