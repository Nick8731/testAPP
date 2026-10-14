import 'package:flutter/material.dart';

import '../data/skill_data.dart';
import '../services/analysis_service.dart';
import '../widgets/progress_explanation.dart';
import '../widgets/account_request_error.dart';
import '../services/auth_service.dart';

class ProgressScreen extends StatefulWidget {
  final AnalysisService? service;
  const ProgressScreen({super.key, this.service});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final _service = widget.service ?? AnalysisService();
  late String _skillName = badmintonSkills.first.name;
  late Future<SkillProgress> _progress = _service.progress(_skillName);

  String? _version;
  @override
  void initState() {
    super.initState();
    AuthService.instance.currentUserChanges.addListener(_sessionChanged);
  }

  void _sessionChanged() {
    if (mounted) _load(_skillName);
  }

  @override
  void dispose() {
    AuthService.instance.currentUserChanges.removeListener(_sessionChanged);
    super.dispose();
  }

  void _load(String skillName, {String? version}) {
    setState(() {
      _skillName = skillName;
      _version = version;
      _progress = _service.progress(skillName, version: version);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('進步趨勢')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _skillName,
            decoration: const InputDecoration(
              labelText: '技術',
              border: OutlineInputBorder(),
            ),
            items: badmintonSkills
                .map(
                  (skill) => DropdownMenuItem(
                    value: skill.name,
                    child: Text(skill.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) _load(value);
            },
          ),
          const SizedBox(height: 20),
          FutureBuilder<SkillProgress>(
            future: _progress,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return AccountRequestError(
                  error: snapshot.error!,
                  onRetry: () => _load(_skillName, version: _version),
                );
              }
              final progress = snapshot.data!;
              return Column(
                children: [
                  if (progress.availableVersions.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      key: ValueKey('$_skillName-${progress.selectedVersion}'),
                      initialValue:
                          progress.availableVersions.contains(
                            progress.selectedVersion,
                          )
                          ? progress.selectedVersion
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '比較的評分版本',
                        border: OutlineInputBorder(),
                      ),
                      items: progress.availableVersions
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(switch (v) {
                                'pose-phase-v3' => '固定階段分析 v3',
                                'pose-still-v2' => '舊版姿勢分析 v2',
                                'legacy-unknown' => '舊紀錄（版本未記錄）',
                                _ => v,
                              }),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _load(_skillName, version: v);
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        '只計算所選版本，不混合新舊評分。舊紀錄仍可從選單查看；同版本也請固定鏡位、持拍側與動作階段。',
                      ),
                    ),
                  ],
                  if (progress.records.isEmpty) const Text('這項技術／版本還沒有分析紀錄。'),
                  if (progress.records.isNotEmpty)
                    Row(
                      children: [
                        _Metric(label: '最新', value: progress.latestScore),
                        _Metric(
                          label: '變化',
                          value: progress.change,
                          signed: true,
                        ),
                        _Metric(label: '最佳', value: progress.bestScore),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ...progress.records.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 86,
                            child: Text(
                              '${point.date.month}/${point.date.day}',
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: point.score / 100,
                                minHeight: 18,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 42,
                            child: Text(
                              '${point.score}',
                              textAlign: TextAlign.end,
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
          const SizedBox(height: 20),
          const ProgressExplanation(),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final int? value;
  final bool signed;

  const _Metric({
    required this.label,
    required this.value,
    this.signed = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayed = value == null
        ? '—'
        : '${signed && value! > 0 ? '+' : ''}$value';
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(label),
              const SizedBox(height: 4),
              Text(
                displayed,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
