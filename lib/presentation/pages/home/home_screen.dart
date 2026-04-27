// lib/presentation/pages/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';

import '../../../domain/entities/subject_entity.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/subject_bloc.dart';
import '../../widgets/subject_tile.dart';
import '../quiz/quiz_screen.dart';
import 'subjects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubjectBloc>().add(SubjectsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final name = user?.name ?? 'Student';
        final xp = user?.xpPoints ?? 0;
        final trophies = user?.trophyCount ?? 0;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi $name 👋',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Text(
                              'Start your productive day',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.purpleBg,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.purple, AppColors.purpleDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _StatChip(
                          icon: Icons.shield_rounded,
                          value: '$xp',
                          label: 'XP Points',
                        ),
                        const SizedBox(width: 20),
                        Container(width: 1, height: 40, color: Colors.white24),
                        const SizedBox(width: 20),
                        _StatChip(
                          icon: Icons.emoji_events_rounded,
                          value: '$trophies',
                          label: 'Trophies',
                          isGold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Studies',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Subjects
                  BlocBuilder<SubjectBloc, SubjectState>(
                    builder: (context, state) {
                      final cachedSubjects = context
                          .read<SubjectBloc>()
                          .allSubjects;

                      if (state is SubjectLoading && cachedSubjects.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                              color: AppColors.purple,
                            ),
                          ),
                        );
                      }

                      final subjects =
                          (state is SubjectsLoaded
                                  ? state.subjects
                                  : cachedSubjects)
                              .take(3)
                              .toList();

                      if (subjects.isNotEmpty) {
                        return Column(
                          children: subjects
                              .map(
                                (s) => SubjectTile(
                                  subject: s,
                                  onTap: () => _startQuiz(context, s),
                                ),
                              )
                              .toList(),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubjectsScreen(),
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.purple,
                      ),
                      label: const Text(
                        'See more',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Premium banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.purpleDark, AppColors.purple],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Premium\nAccount\nDiscount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text(
                                  'Get Premium',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white70,
                          size: 80,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startQuiz(BuildContext context, SubjectEntity subject) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizScreen(subject: subject, userId: authState.user.id!),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final bool isGold;
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    this.isGold = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isGold ? AppColors.gold : Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    ],
  );
}
