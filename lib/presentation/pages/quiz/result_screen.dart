// lib/presentation/pages/quiz/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../domain/entities/quiz_result_entity.dart';
import '../../../domain/entities/subject_entity.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../home/main_shell.dart';

class ResultScreen extends StatefulWidget {
  final QuizResultEntity result;
  final SubjectEntity subject;
  const ResultScreen({super.key, required this.result, required this.subject});

  @override
 State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _xpUpdateSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _xpUpdateSent) return;
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;

      final isGood = widget.result.scorePct >= 70;
      final xpEarned = widget.result.correct * 50;
      final updatedUser = authState.user.copyWith(
        xpPoints: authState.user.xpPoints + xpEarned,
        trophyCount: isGood
            ? authState.user.trophyCount + 1
            : authState.user.trophyCount,
      );

      context.read<AuthBloc>().add(UpdateUserRequested(updatedUser));
      _xpUpdateSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final subject = widget.subject;
    final pct = result.scorePct;
    final isGood = pct >= 70;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.purple, AppColors.purpleLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isGood ? Icons.emoji_events_rounded : Icons.sentiment_satisfied_alt_rounded,
                    color: AppColors.gold, size: 90,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isGood ? 'Great Job! 🎉' : 'Keep Practicing!',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(subject.name, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 24),
                  // Score circle
                  Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 3),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$pct%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                          const Text('Score', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${result.correct} out of ${result.total} correct',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  // XP earned
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded, color: AppColors.gold, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '+${result.correct * 50} XP earned',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isGood ? 'Excellent performance! Keep it up!' : 'Don\'t worry, practice makes perfect!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity, height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainShell()),
                        (_) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Try Again', style: TextStyle(color: Colors.white70, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}