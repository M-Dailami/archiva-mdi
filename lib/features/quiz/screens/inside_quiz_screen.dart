import 'dart:async';
import 'package:flutter/material.dart';
import 'package:archivafinal/core/constants/app_colors.dart';
import 'package:archivafinal/models/quiz_model.dart';
import 'package:archivafinal/features/quiz/screens/quiz_reward_screen.dart';

class InsideQuizScreen extends StatefulWidget {
  final Quiz quiz;
  const InsideQuizScreen({super.key, required this.quiz});
  @override
  State<InsideQuizScreen> createState() => _InsideQuizScreenState();
}

class _InsideQuizScreenState extends State<InsideQuizScreen> {
  int _current = 0;
  int? _selected;
  int _correctCount = 0;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seconds = widget.quiz.durationMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _finish();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _answer() {
    if (_selected == null) return;
    final q = widget.quiz.questions[_current];
    if (_selected == q.correctIndex) {
      _correctCount++;
    }
    if (_current < widget.quiz.questions.length - 1) {
      setState(() { _current++; _selected = null; });
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() { _current--; _selected = null; });
    }
  }

  void _finish() {
    _timer?.cancel();
    final score = _correctCount / widget.quiz.questions.length;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => QuizRewardScreen(
        quiz: widget.quiz,
        score: score,
        correctCount: _correctCount,
      )));
  }

  String get _timeStr {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz.questions[_current];
    final progress = (_current + 1) / widget.quiz.questions.length;
    final labels = ['A', 'B', 'C', 'D'];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Kuis ${widget.quiz.placeName}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 20),

            // Progress bar
            Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 8,
                  backgroundColor: AppColors.surfaceDark,
                  valueColor: const AlwaysStoppedAnimation(AppColors.quizProgress)))),
              const SizedBox(width: 12),
              Text('${_current + 1} / ${widget.quiz.questions.length}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                child: Text(_timeStr, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500))),
            ]),
            const SizedBox(height: 24),

            // Scrollable content for question + options
            Expanded(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Question
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16)),
                    child: Text(q.text, style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                      textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 12),
                  Text('Pertanyaan ${_current + 1} dari ${widget.quiz.questions.length}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),

                  // Options
                  ...List.generate(q.options.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selected == i ? AppColors.quizSelected : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(children: [
                          Container(width: 36, height: 36,
                            decoration: BoxDecoration(shape: BoxShape.circle,
                              color: _selected == i ? AppColors.quizSelected : AppColors.surfaceDark),
                            child: Center(child: Text(labels[i],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)))),
                          const SizedBox(width: 14),
                          Expanded(child: Text(q.options[i],
                            style: const TextStyle(fontSize: 15, color: Colors.white))),
                        ]),
                      ),
                    ),
                  )),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            // Buttons — always visible at bottom
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _selected != null ? _answer : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor: AppColors.surfaceDark),
                child: const Text('Jawab Dan Lanjut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              )),
            if (_current > 0) ...[
              const SizedBox(height: 8),
              Center(child: TextButton(onPressed: _prev,
                child: const Text('Sebelumnya', style: TextStyle(color: AppColors.textSecondary)))),
            ],
          ]),
        ),
      ),
    );
  }
}
