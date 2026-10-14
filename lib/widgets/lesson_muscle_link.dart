import 'package:flutter/material.dart';

import '../data/muscle_data.dart';
import '../screens/muscle_detail_screen.dart';

/// Matches the teaching catalogue by its canonical technique name.
class LessonMuscleLink extends StatelessWidget {
  final String skillName;
  const LessonMuscleLink({super.key, required this.skillName});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const ValueKey('lesson-open-muscles'),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MuscleDetailScreen(
          skill: muscleSkills.firstWhere((s) => s.skillName == skillName),
        ),
      ),
    ),
    icon: const Icon(Icons.accessibility_new),
    label: Text('$skillName｜肌群與發力時機'),
  );
}
