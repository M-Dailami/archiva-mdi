import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/models/quiz_model.dart';
import 'package:archivafinal/services/app_state.dart';
import 'package:archivafinal/core/utils/helpers.dart';

class QuizRewardScreen extends StatefulWidget {
  final Quiz quiz;
  final double score;
  final int correctCount;
  const QuizRewardScreen({super.key, required this.quiz, required this.score, required this.correctCount});
  @override
  State<QuizRewardScreen> createState() => _QuizRewardScreenState();
}

class _QuizRewardScreenState extends State<QuizRewardScreen> {
  @override
  void initState() { super.initState(); _saveResult(); }

  Future<void> _saveResult() async {
    final xpEarned = (widget.score * widget.quiz.xpReward).toInt();
    await context.read<AppState>().completeQuiz(widget.quiz.id, widget.score, xpEarned);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    final xpEarned = (widget.score * widget.quiz.xpReward).toInt();
    final totalXp = user.totalXp;
    final rank = XpUtils.rankTitle(totalXp);
    final level = XpUtils.levelFromXp(totalXp);
    final nextLevel = level + 1;
    final nextRank = XpUtils.rankTitle(XpUtils.xpForLevel(nextLevel));
    final xpForNext = XpUtils.xpForLevel(nextLevel);
    final progressInLevel = XpUtils.progressInLevel(totalXp);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(child: Column(children: [
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 24),
            Container(width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accentGreen.withValues(alpha: 0.2)),
              child: const Icon(Icons.check, size: 44, color: AppColors.accentGreen)),
            const SizedBox(height: 20),
            const Text('Kuis Selesai!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text(widget.quiz.title, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 28),
            Row(children: [
              _bigStat('${(widget.score * 100).toInt()}%', 'Nilai'),
              _bigStat('${widget.correctCount}/${widget.quiz.questions.length}', 'Benar'),
              _bigStat('+$xpEarned', 'XP', color: AppColors.xpGold),
            ]),
            const SizedBox(height: 28),
            Container(width: double.infinity, padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Kemajuan Rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Flexible(child: Text(rank, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  Text('$totalXp / $xpForNext XP', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: progressInLevel, minHeight: 10,
                    backgroundColor: AppColors.xpBarBackground, valueColor: const AlwaysStoppedAnimation(AppColors.xpBar))),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Level $level', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Flexible(child: Text('Level $nextLevel : $nextRank', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                ]),
              ])),
            const SizedBox(height: 24),
            if (user.badges.isNotEmpty) ...[
              const Align(alignment: Alignment.centerLeft,
                child: Text('Badge yang didapatkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 8, children: user.badges.map((b) => _badge(b)).toList()),
            ],
            const SizedBox(height: 32),
          ]))),
        Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))))),
      ])),
    );
  }

  Widget _bigStat(String v, String l, {Color? color}) => Expanded(child: Column(children: [
    FittedBox(fit: BoxFit.scaleDown, child: Text(v, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color ?? Colors.white))),
    const SizedBox(height: 4),
    Text(l, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))]));

  Widget _badge(String name) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.accent.withValues(alpha: 0.4))),
    child: Text(name, style: const TextStyle(fontSize: 12, color: Colors.white)));
}
