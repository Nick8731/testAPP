import 'package:flutter/material.dart';

import '../data/illustrated_lesson_data.dart';
import '../test/test_skill.dart';
import 'drive_lesson_screen.dart';
import 'illustrated_lesson_screen.dart';

/// Teaching stills are separate from user-uploaded AI analysis videos.
class SkillDetailScreen extends StatelessWidget {
  final BadmintonSkill skill;
  const SkillDetailScreen({super.key, required this.skill});
  @override
  Widget build(BuildContext context) => skill.name == '平球'
      ? const DriveLessonScreen()
      : IllustratedLessonScreen(lesson: lessonFor(skill.name));
}
