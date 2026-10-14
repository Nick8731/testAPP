class BadmintonSkill {
  final String name;
  final String englishName;
  final String level;
  final String category;

  final String description;
  final String videoPath;

  final List<String> steps;
  final List<String> muscles;
  final List<String> mistakes;
  final List<String> corrections;

  final List<SkillPhase> phases;

  const BadmintonSkill({
    required this.name,
    required this.englishName,
    required this.level,
    required this.category,
    required this.description,
    required this.videoPath,
    required this.steps,
    required this.muscles,
    required this.mistakes,
    required this.corrections,
    required this.phases,
  });

  bool get hasVideo => videoPath.trim().isNotEmpty;
}

class SkillPhase {
  final String name;
  final double startSecond;
  final double endSecond;
  final String description;
  final List<String> muscles;

  const SkillPhase({
    required this.name,
    required this.startSecond,
    required this.endSecond,
    required this.description,
    required this.muscles,
  });
}
