import '../analysis/skill_analysis_result.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AnalysisSummary {
  final int id;
  final String skillName;
  final int totalScore;
  final DateTime analyzedAt;

  const AnalysisSummary({
    required this.id,
    required this.skillName,
    required this.totalScore,
    required this.analyzedAt,
  });

  factory AnalysisSummary.fromJson(Map<String, dynamic> json) =>
      AnalysisSummary(
        id: json['analysisId'] as int,
        skillName: json['skillName'] as String,
        totalScore: json['totalScore'] as int,
        analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      );
}

class AnalysisRecord extends AnalysisSummary {
  final List<SkillScoreItem> scores;
  final List<String> goodPoints;
  final List<String> problems;
  final List<String> suggestions;
  final Map<String, String> details;

  const AnalysisRecord({
    required super.id,
    required super.skillName,
    required super.totalScore,
    required super.analyzedAt,
    required this.scores,
    required this.goodPoints,
    required this.problems,
    required this.suggestions,
    required this.details,
  });

  factory AnalysisRecord.fromJson(Map<String, dynamic> json) => AnalysisRecord(
    id: json['analysisId'] as int,
    skillName: json['skillName'] as String,
    totalScore: json['totalScore'] as int,
    analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    scores: (json['scores'] as List<dynamic>)
        .map(
          (item) => SkillScoreItem(
            name: (item as Map<String, dynamic>)['name'] as String,
            score: item['score'] as int,
          ),
        )
        .toList(),
    goodPoints: List<String>.from(json['goodPoints'] as List<dynamic>),
    problems: List<String>.from(json['problems'] as List<dynamic>),
    suggestions: List<String>.from(json['suggestions'] as List<dynamic>),
    details: Map<String, String>.from(json['details'] as Map<String, dynamic>),
  );
}

class ProgressPoint {
  final DateTime date;
  final int score;

  const ProgressPoint({required this.date, required this.score});
}

class SkillProgress {
  final String? selectedVersion;
  final List<String> availableVersions;
  final String skillName;
  final int? latestScore;
  final int? previousScore;
  final int? change;
  final int? bestScore;
  final List<ProgressPoint> records;

  const SkillProgress({
    this.selectedVersion,
    this.availableVersions = const [],
    required this.skillName,
    required this.latestScore,
    required this.previousScore,
    required this.change,
    required this.bestScore,
    required this.records,
  });

  factory SkillProgress.fromJson(Map<String, dynamic> json) => SkillProgress(
    selectedVersion: json['selectedVersion'] as String?,
    availableVersions: List<String>.from(
      json['availableVersions'] as List? ?? [],
    ),
    skillName: json['skillName'] as String,
    latestScore: json['latestScore'] as int?,
    previousScore: json['previousScore'] as int?,
    change: json['change'] as int?,
    bestScore: json['bestScore'] as int?,
    records: (json['records'] as List<dynamic>).map((item) {
      final value = item as Map<String, dynamic>;
      return ProgressPoint(
        date: DateTime.parse(value['date'] as String),
        score: value['score'] as int,
      );
    }).toList(),
  );
}

class AnalysisService {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService.instance;

  Future<AnalysisRecord> save(SkillAnalysisResult result) async {
    final accessToken = await _auth.requireToken();
    final json = await _api.postJson('/analysis', {
      'skillName': result.skillName,
      'totalScore': result.totalScore,
      'scores': result.scores
          .map((item) => {'name': item.name, 'score': item.score})
          .toList(),
      'goodPoints': result.goodPoints,
      'problems': result.problems,
      'suggestions': result.suggestions,
      'details': result.details,
    }, token: accessToken);
    return AnalysisRecord.fromJson(json);
  }

  Future<List<AnalysisSummary>> list({
    String? skill,
    int page = 1,
    int pageSize = 100,
  }) async {
    return (await listPage(skill: skill, page: page, pageSize: pageSize)).items;
  }

  Future<AnalysisHistoryPage> listPage({
    String? skill,
    int page = 1,
    int pageSize = 20,
  }) async {
    final accessToken = await _auth.requireToken();
    final parameters = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (skill != null && skill.isNotEmpty) 'skill': skill,
    };
    final query = Uri(queryParameters: parameters).query;
    final json = await _api.getJson('/analysis?$query', token: accessToken);
    final items = (json['items'] as List<dynamic>)
        .map((item) => AnalysisSummary.fromJson(item as Map<String, dynamic>))
        .toList();
    return AnalysisHistoryPage(
      items: items,
      total: json['total'] as int,
      page: json['page'] as int,
    );
  }

  Future<AnalysisRecord> get(int id) async {
    final accessToken = await _auth.requireToken();
    return AnalysisRecord.fromJson(
      await _api.getJson('/analysis/$id', token: accessToken),
    );
  }

  Future<void> delete(int id) async {
    final accessToken = await _auth.requireToken();
    await _api.delete('/analysis/$id', token: accessToken);
  }

  Future<SkillProgress> progress(String skillName, {String? version}) async {
    final accessToken = await _auth.requireToken();
    final json = await _api.getJson(
      '/progress/${Uri.encodeComponent(skillName)}${version == null ? '' : '?${Uri(queryParameters: {'version': version}).query}'}',
      token: accessToken,
    );
    return SkillProgress.fromJson(json);
  }
}

class AnalysisHistoryPage {
  final List<AnalysisSummary> items;
  final int total, page;
  const AnalysisHistoryPage({
    required this.items,
    required this.total,
    required this.page,
  });
}
