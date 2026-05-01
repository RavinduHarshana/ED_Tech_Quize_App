// lib/presentation/pages/admin/manage_questions_screen.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/core/di/injection.dart';
import '../../../domain/entities/question_entity.dart';
import '../../../domain/entities/subject_entity.dart';
import '../../../domain/usecases/question_usecases.dart';
import '../../../domain/usecases/subject_usecases.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  late Future<_QuestionAdminData> _dataFuture;
  int? _subjectFilterId;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_QuestionAdminData> _loadData() async {
    final (subjects, subjectFailure) = await sl<GetAllSubjectsUseCase>()();
    final (questions, questionFailure) = await sl<GetAllQuestionsUseCase>()();
    if (subjectFailure != null) {
      throw subjectFailure.message;
    }
    if (questionFailure != null) {
      throw questionFailure.message;
    }
    if (_subjectFilterId == null && subjects.isNotEmpty) {
      _subjectFilterId = subjects.first.id;
    }
    return _QuestionAdminData(subjects: subjects, questions: questions);
  }

  Future<void> _refresh() async {
    setState(() {
      _dataFuture = _loadData();
    });
    await _dataFuture;
  }

  Future<void> _openQuestionDialog({
    QuestionEntity? question,
    List<SubjectEntity>? subjects,
  }) async {
    final availableSubjects = subjects ?? const <SubjectEntity>[];
    final formKey = GlobalKey<FormState>();
    final textCtrl = TextEditingController(text: question?.text ?? '');
    final optionCtrls = List.generate(
      4,
      (index) => TextEditingController(text: question?.options[index] ?? ''),
    );
    int? selectedSubjectId = question?.subjectId ?? _subjectFilterId;
    int correctIndex = question?.correctIndex ?? 0;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(question == null ? 'Add Question' : 'Edit Question'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: selectedSubjectId,
                        decoration: const InputDecoration(labelText: 'Subject'),
                        items: availableSubjects
                            .map(
                              (subject) => DropdownMenuItem(
                                value: subject.id,
                                child: Text(subject.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => selectedSubjectId = value),
                        validator: (value) =>
                            value == null ? 'Choose a subject' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: textCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Question text',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a question';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextFormField(
                            controller: optionCtrls[index],
                            decoration: InputDecoration(
                              labelText:
                                  'Option ${String.fromCharCode(65 + index)}',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter option ${index + 1}';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      DropdownButtonFormField<int>(
                        value: correctIndex,
                        decoration: const InputDecoration(
                          labelText: 'Correct answer',
                        ),
                        items: List.generate(
                          4,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(
                              'Option ${String.fromCharCode(65 + index)}',
                            ),
                          ),
                        ),
                        onChanged: (value) =>
                            setDialogState(() => correctIndex = value ?? 0),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;
                    if (selectedSubjectId == null) return;
                    final payload = QuestionEntity(
                      id: question?.id,
                      subjectId: selectedSubjectId!,
                      text: textCtrl.text.trim(),
                      options: optionCtrls
                          .map((controller) => controller.text.trim())
                          .toList(),
                      correctIndex: correctIndex,
                    );
                    if (question == null) {
                      final (id, failure) = await sl<CreateQuestionUseCase>()(
                        payload,
                      );
                      if (!mounted) return;
                      if (failure != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(failure.message)),
                        );
                        return;
                      }
                      if (id != null) {
                        Navigator.pop(dialogContext, true);
                      }
                    } else {
                      final (ok, failure) = await sl<UpdateQuestionUseCase>()(
                        payload,
                      );
                      if (!mounted) return;
                      if (failure != null || !ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              failure?.message ?? 'Failed to update question',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    textCtrl.dispose();
    for (final controller in optionCtrls) {
      controller.dispose();
    }

    if (saved == true) {
      await _refresh();
    }
  }

  Future<void> _deleteQuestion(QuestionEntity question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete question?'),
        content: const Text(
          'This will remove the question from the quiz bank.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final (ok, failure) = await sl<DeleteQuestionUseCase>()(question.id!);
    if (!mounted) return;
    if (failure != null || !ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure?.message ?? 'Failed to delete question'),
        ),
      );
      return;
    }
    await _refresh();
  }

  SubjectEntity? _subjectForId(List<SubjectEntity> subjects, int subjectId) {
    for (final subject in subjects) {
      if (subject.id == subjectId) return subject;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<_QuestionAdminData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.purple),
            );
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 80),
                const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppColors.textGrey,
                ),
                const SizedBox(height: 12),
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textGrey),
                ),
              ],
            );
          }

          final data =
              snapshot.data ??
              const _QuestionAdminData(subjects: [], questions: []);
          final questions = data.questions.where((question) {
            if (_subjectFilterId == null) return true;
            return question.subjectId == _subjectFilterId;
          }).toList();
          final selectedSubject = _subjectForId(
            data.subjects,
            _subjectFilterId ?? -1,
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: data.subjects.isEmpty
                        ? null
                        : () => _openQuestionDialog(subjects: data.subjects),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _subjectFilterId,
                decoration: const InputDecoration(
                  labelText: 'Filter by subject',
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All subjects'),
                  ),
                  ...data.subjects.map(
                    (subject) => DropdownMenuItem<int?>(
                      value: subject.id,
                      child: Text(subject.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _subjectFilterId = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (questions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.quiz_outlined,
                        size: 60,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedSubject == null
                            ? 'No questions yet'
                            : 'No questions for ${selectedSubject.name}',
                        style: const TextStyle(color: AppColors.textGrey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...questions.map((question) {
                  final subject = _subjectForId(
                    data.subjects,
                    question.subjectId,
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject?.name ??
                                        'Subject #${question.subjectId}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.purple,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    question.text,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _openQuestionDialog(
                                question: question,
                                subjects: data.subjects,
                              ),
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: AppColors.purple,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteQuestion(question),
                              icon: const Icon(
                                Icons.delete_rounded,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(question.options.length, (index) {
                          final isCorrect = index == question.correctIndex;
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? AppColors.correct.withOpacity(.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCorrect
                                    ? AppColors.correct
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              '${String.fromCharCode(65 + index)}. ${question.options[index]}',
                              style: TextStyle(
                                color: isCorrect
                                    ? AppColors.correct
                                    : AppColors.textDark,
                                fontWeight: isCorrect
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _QuestionAdminData {
  final List<SubjectEntity> subjects;
  final List<QuestionEntity> questions;

  const _QuestionAdminData({required this.subjects, required this.questions});
}
