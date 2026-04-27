// lib/presentation/pages/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/core/di/injection.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/dashboard_bloc.dart';
import '../../bloc/auth/subject_bloc.dart';
import '../../../domain/entities/quiz_result_entity.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = DashboardBloc(getResultsUseCase: sl(), getStatsUseCase: sl());
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          bloc.add(DashboardLoadRequested(authState.user.id!));
        }
        return bloc;
      },
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.purple),
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<DashboardBloc>().add(DashboardLoadRequested(authState.user.id!));
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.purple));
          }
          if (state is DashboardLoaded) {
            return _buildContent(context, state);
          }
          if (state is DashboardError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.textGrey)));
          }
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_rounded, size: 60, color: AppColors.textGrey),
                SizedBox(height: 12),
                Text('Loading your stats...', style: TextStyle(color: AppColors.textGrey)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    final stats = state.stats;
    final results = state.results;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(child: _DashCard(icon: Icons.quiz_rounded, iconColor: AppColors.purpleLight, label: 'Quizzes Done', value: '${stats['quizzes_done'] ?? 0}')),
              const SizedBox(width: 12),
              Expanded(child: _DashCard(icon: Icons.check_circle_rounded, iconColor: AppColors.correct, label: 'Avg Score', value: '${stats['avg_score'] ?? 0}%')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _DashCard(icon: Icons.star_rounded, iconColor: AppColors.gold, label: 'Best Score', value: '${stats['best_score'] ?? 0}%')),
              const SizedBox(width: 12),
              Expanded(child: _DashCard(icon: Icons.done_all_rounded, iconColor: AppColors.purple, label: 'Total Correct', value: '${stats['total_correct'] ?? 0}')),
            ],
          ),
          const SizedBox(height: 28),
          const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 12),
          if (results.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: const [
                    Icon(Icons.history_rounded, size: 60, color: AppColors.textGrey),
                    SizedBox(height: 12),
                    Text('No activity yet.\nTake a quiz to see your stats!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey)),
                  ],
                ),
              ),
            )
          else
            ...results.take(10).map((r) => _ActivityTile(result: r)),

          // Subject progress
          if (results.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Subject Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 12),
            BlocBuilder<SubjectBloc, SubjectState>(
              builder: (context, subjectState) {
                if (subjectState is SubjectsLoaded) {
                  final subjectMap = <String, QuizResultEntity>{};
                  for (final r in results) {
                    if (!subjectMap.containsKey(r.subjectName) || r.scorePct > subjectMap[r.subjectName]!.scorePct) {
                      subjectMap[r.subjectName] = r;
                    }
                  }
                  return Column(
                    children: subjectState.subjects.map((s) {
                      final bestResult = subjectMap[s.name];
                      return _ProgressTile(subjectName: s.name, subjectIcon: s.icon, subjectColor: s.color, bestResult: bestResult);
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  const _DashCard({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)],
    ),
    child: Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: iconColor.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActivityTile extends StatelessWidget {
  final QuizResultEntity result;
  const _ActivityTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final pct = result.scorePct;
    final date = DateTime.tryParse(result.takenAt);
    final dateStr = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.purpleBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.quiz_rounded, color: AppColors.purple, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.subjectName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                Text('${result.correct}/${result.total} correct • $dateStr', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pct >= 70 ? AppColors.correct.withOpacity(.15) : AppColors.wrong.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$pct%', style: TextStyle(color: pct >= 70 ? AppColors.correct : AppColors.wrong, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final String subjectName, subjectIcon;
  final Color subjectColor;
  final QuizResultEntity? bestResult;
  const _ProgressTile({required this.subjectName, required this.subjectIcon, required this.subjectColor, this.bestResult});

  @override
  Widget build(BuildContext context) {
    final pct = bestResult != null ? bestResult!.scorePct / 100.0 : 0.0;
    final label = bestResult != null ? '${bestResult!.scorePct}%' : 'Not started';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: subjectColor.withOpacity(.15), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(subjectIcon, style: TextStyle(color: subjectColor, fontWeight: FontWeight.w900, fontSize: 13))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark))),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: bestResult != null ? subjectColor : AppColors.textGrey)),
            ],
          ),
          if (bestResult != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct, minHeight: 6,
                backgroundColor: subjectColor.withOpacity(.15),
                valueColor: AlwaysStoppedAnimation(subjectColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}