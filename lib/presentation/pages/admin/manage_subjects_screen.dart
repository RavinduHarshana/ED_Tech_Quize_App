// lib/presentation/pages/admin/manage_subjects_screen.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/core/di/injection.dart';
import '../../../domain/entities/subject_entity.dart';
import '../../../domain/usecases/subject_usecases.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  late Future<List<SubjectEntity>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _loadSubjects();
  }

  Future<List<SubjectEntity>> _loadSubjects() async {
    final (subjects, failure) = await sl<GetAllSubjectsUseCase>()();
    if (failure != null) {
      throw failure.message;
    }
    return subjects;
  }

  Future<void> _refresh() async {
    setState(() {
      _subjectsFuture = _loadSubjects();
    });
    await _subjectsFuture;
  }

  Future<void> _openSubjectDialog({SubjectEntity? subject}) async {
    final nameCtrl = TextEditingController(text: subject?.name ?? '');
    final iconCtrl = TextEditingController(text: subject?.icon ?? '');
    final colorCtrl = TextEditingController(
      text: subject?.colorHex ?? '7C3AED',
    );
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(subject == null ? 'Add Subject' : 'Edit Subject'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Subject name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a subject name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: iconCtrl,
                    decoration: const InputDecoration(labelText: 'Icon text'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter an icon label';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: colorCtrl,
                    decoration: const InputDecoration(labelText: 'Color hex'),
                    validator: (value) {
                      final cleaned = value?.trim() ?? '';
                      final valid = RegExp(
                        r'^[0-9A-Fa-f]{6}$',
                      ).hasMatch(cleaned);
                      if (!valid) {
                        return 'Use a 6-digit hex value';
                      }
                      return null;
                    },
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
                final payload = SubjectEntity(
                  id: subject?.id,
                  name: nameCtrl.text.trim(),
                  icon: iconCtrl.text.trim(),
                  totalQuestions: subject?.totalQuestions ?? 0,
                  colorHex: colorCtrl.text.trim().toUpperCase(),
                );
                if (subject == null) {
                  final (id, failure) = await sl<CreateSubjectUseCase>()(
                    payload,
                  );
                  if (!mounted) return;
                  if (failure != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(failure.message)));
                    return;
                  }
                  if (id != null) {
                    Navigator.pop(dialogContext, true);
                  }
                } else {
                  final (ok, failure) = await sl<UpdateSubjectUseCase>()(
                    payload,
                  );
                  if (!mounted) return;
                  if (failure != null || !ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          failure?.message ?? 'Failed to update subject',
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

    nameCtrl.dispose();
    iconCtrl.dispose();
    colorCtrl.dispose();

    if (saved == true) {
      await _refresh();
    }
  }

  Future<void> _deleteSubject(SubjectEntity subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete subject?'),
        content: Text('Delete ${subject.name} and all of its questions?'),
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

    final (ok, failure) = await sl<DeleteSubjectUseCase>()(subject.id!);
    if (!mounted) return;
    if (failure != null || !ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure?.message ?? 'Failed to delete subject')),
      );
      return;
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<SubjectEntity>>(
        future: _subjectsFuture,
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

          final subjects = snapshot.data ?? const <SubjectEntity>[];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Subjects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openSubjectDialog(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (subjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No subjects yet',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                )
              else
                ...subjects.map(
                  (subject) => Container(
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
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: subject.color.withOpacity(.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              subject.icon,
                              style: TextStyle(
                                color: subject.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${subject.totalQuestions} questions',
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openSubjectDialog(subject: subject),
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.purple,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteSubject(subject),
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
