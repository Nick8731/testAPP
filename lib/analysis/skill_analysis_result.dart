class SkillScoreItem {
  final String name;
  final int score;

  const SkillScoreItem({
    required this.name,
    required this.score,
  });
}

class SkillAnalysisResult {
  final String skillName;
  final int totalScore;

  final List<SkillScoreItem> scores;

  final List<String> goodPoints;
  final List<String> problems;
  final List<String> suggestions;

  final Map<String, String> details;

  const SkillAnalysisResult({
    required this.skillName,
    required this.totalScore,
    required this.scores,
    required this.goodPoints,
    required this.problems,
    required this.suggestions,
    required this.details,
  });
}