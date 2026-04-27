// lib/presentation/pages/quiz/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/core/di/injection.dart';
import '../../bloc/auth/quiz_bloc.dart';
import '../../../domain/entities/subject_entity.dart';
import 'result_screen.dart';

class QuizScreen extends StatelessWidget {
  final SubjectEntity subject;
  final int userId;
  const QuizScreen({super.key, required this.subject, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc(
        getQuestionsUseCase: sl(),
        saveResultUseCase: sl(),
      )..add(QuizStarted(subject, userId)),
      child: const _QuizView(),
    );
  }
}

class _QuizView extends StatefulWidget {
  const _QuizView();
  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = Tween<double>(begin: 60, end: 0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _animCtrl.reset();
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizInProgress) _triggerAnimation();
        if (state is QuizCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ResultScreen(result: state.result, subject: state.subject)),
          );
        }
      },
      builder: (context, state) {
        if (state is QuizLoading) {
          return const Scaffold(
            backgroundColor: AppColors.purple,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        if (state is QuizError) {
          return Scaffold(
            backgroundColor: AppColors.purple,
            body: Center(
              child: Text(state.message, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          );
        }
        if (state is QuizInProgress) {
          return _buildQuiz(context, state);
        }
        return const Scaffold(backgroundColor: AppColors.purple);
      },
    );
  }

  Widget _buildQuiz(BuildContext context, QuizInProgress state) {
    final q = state.currentQuestion;
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${state.currentIndex + 1}/${state.totalQuestions}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: state.progress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Question card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: AnimatedBuilder(
                  animation: _animCtrl,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: Opacity(opacity: _animCtrl.value, child: child),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.subject.name, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Select an answer', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        const SizedBox(height: 12),
                        Text(q.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.3)),
                        const SizedBox(height: 28),
                        ...List.generate(q.options.length, (i) {
                          Color bgColor = Colors.white;
                          Color borderColor = Colors.transparent;
                          bool isCorrect = false;
                          bool isWrong = false;
                          bool isSelected = state.selectedAnswer == i;

                          if (state.answered) {
                            if (i == q.correctIndex) {
                              bgColor = AppColors.correct.withOpacity(.15);
                              borderColor = AppColors.correct;
                              isCorrect = true;
                            } else if (isSelected) {
                              bgColor = AppColors.wrong.withOpacity(.15);
                              borderColor = AppColors.wrong;
                              isWrong = true;
                            }
                          } else if (isSelected) {
                            bgColor = AppColors.gold.withOpacity(.15);
                            borderColor = AppColors.gold;
                          }

                          return _OptionTile(
                            text: q.options[i],
                            isSelected: isSelected,
                            bgColor: bgColor,
                            borderColor: borderColor,
                            isCorrect: isCorrect,
                            isWrong: isWrong,
                            onTap: state.answered ? null : () => context.read<QuizBloc>().add(QuizAnswerSelected(i)),
                          );
                        }),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity, height: 54,
                          child: ElevatedButton(
                            onPressed: state.answered
                                ? () => context.read<QuizBloc>().add(QuizNextQuestion())
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purpleDark,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              state.currentIndex + 1 == state.totalQuestions ? 'Finish' : 'Next',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected, isCorrect, isWrong;
  final Color bgColor, borderColor;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.text,
    required this.isSelected,
    required this.bgColor,
    required this.borderColor,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.correct : isWrong ? AppColors.wrong : isSelected ? AppColors.gold : Colors.transparent,
              border: Border.all(
                color: isCorrect ? AppColors.correct : isWrong ? AppColors.wrong : isSelected ? AppColors.gold : AppColors.textGrey.withOpacity(.4),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: (isCorrect || isWrong || isSelected)
                ? Icon(
                    isCorrect ? Icons.check_rounded : isWrong ? Icons.close_rounded : Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isCorrect ? AppColors.correct : isWrong ? AppColors.wrong : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}