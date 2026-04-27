// lib/presentation/pages/home/subjects_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/subject_bloc.dart';
import '../../../domain/entities/subject_entity.dart';
import '../../widgets/subject_tile.dart';
import '../quiz/quiz_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubjectBloc>().add(SubjectsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Subjects')),
      body: BlocBuilder<SubjectBloc, SubjectState>(
        builder: (context, state) {
          final cachedSubjects = context.read<SubjectBloc>().allSubjects;

          if (state is SubjectLoading && cachedSubjects.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.purple),
            );
          }

          final subjects = state is SubjectsLoaded
              ? state.subjects
              : cachedSubjects;

          if (subjects.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: subjects.length,
              itemBuilder: (_, i) => SubjectTile(
                subject: subjects[i],
                onTap: () => _startQuiz(context, subjects[i]),
              ),
            );
          }
          return const Center(child: Text('No subjects found'));
        },
      ),
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
