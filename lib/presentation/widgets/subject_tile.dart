// lib/presentation/widgets/subject_tile.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/subject_entity.dart';

class SubjectTile extends StatelessWidget {
  final SubjectEntity subject;
  final VoidCallback onTap;

  const SubjectTile({super.key, required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: subject.color.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                subject.icon,
                style: TextStyle(color: subject.color, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
                Text('${subject.totalQuestions} questions', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: subject.color.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start', style: TextStyle(color: subject.color, fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(width: 4),
                Icon(Icons.play_arrow_rounded, color: subject.color, size: 16),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}