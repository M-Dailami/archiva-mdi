import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/services/app_state.dart';
import 'package:archivafinal/features/quiz/screens/quiz_detail_screen.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final places = state.places;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Kuis Tersedia', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Pilih tempat untuk memulai kuis', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Expanded(child: ListView.builder(itemCount: places.length, itemBuilder: (_, i) {
            final p = places[i];
            return FutureBuilder(
              future: state.getQuizzesForPlace(p.id),
              builder: (ctx, snap) {
                final quizzes = snap.data ?? [];
                final completed = quizzes.where((q) => q.isCompleted).length;
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizDetailScreen(placeId: p.id))),
                  child: Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12),
                        child: SizedBox(width: 70, height: 70,
                          child: p.imageUrl.startsWith('http')
                              ? Image.network(
                                  p.imageUrl,
                                  width: 70, height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 70, height: 70,
                                    color: AppColors.surfaceDark,
                                    child: const Icon(Icons.photo, color: AppColors.textMuted, size: 28)))
                              : Container(
                                  width: 70, height: 70,
                                  color: AppColors.surfaceDark,
                                  child: const Icon(Icons.photo, color: AppColors.textMuted, size: 28)))),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(p.location, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.quiz, size: 14, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text('$completed/${quizzes.length} Kuis Selesai',
                            style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w500)),
                        ]),
                      ])),
                      const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    ])));
              });
          })),
        ]))),
    );
  }
}
