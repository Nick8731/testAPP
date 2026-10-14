import 'package:flutter/material.dart';

import '../data/beginner_course_data.dart';

class BeginnerCourseTile extends StatelessWidget {
  final bool read;
  final VoidCallback onTap;
  const BeginnerCourseTile({
    super.key,
    required this.read,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      key: const ValueKey('training-beginner-grips'),
      contentPadding: const EdgeInsets.all(16),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE8F5E9),
        child: Icon(Icons.back_hand_outlined, color: Color(0xFF1B5E20)),
      ),
      title: const Text(
        beginnerCourseName,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          '入門第一課｜正手 V 型、身前反手、放鬆與換握\n${read ? "教材已讀（本機）" : "3 段靜態教學｜不提供 AI 握拍評分"}',
          style: const TextStyle(height: 1.5),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
