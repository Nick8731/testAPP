import 'package:flutter/material.dart';

import '../data/skill_data.dart';
import '../services/analysis_service.dart';
import '../services/auth_service.dart';
import 'analysis_record_detail_screen.dart';
import '../widgets/account_request_error.dart';
import '../services/api_service.dart';

class AnalysisHistoryScreen extends StatefulWidget {
  final AnalysisService? service;
  const AnalysisHistoryScreen({super.key, this.service});

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  static const _allSkills = '全部技術';
  late final _service = widget.service ?? AnalysisService();
  late Future<List<AnalysisSummary>> _records;
  String _selectedSkill = _allSkills;
  List<AnalysisSummary> _loaded = [];
  int _page = 0, _total = 0, _generation = 0;
  bool _loadingMore = false;
  Object? _moreError;

  @override
  void initState() {
    super.initState();
    AuthService.instance.currentUserChanges.addListener(_sessionChanged);
    _reload();
  }

  void _sessionChanged() {
    if (mounted) setState(_reload);
  }

  @override
  void dispose() {
    AuthService.instance.currentUserChanges.removeListener(_sessionChanged);
    _generation++;
    super.dispose();
  }

  void _reload() {
    final generation = ++_generation;
    _loaded = [];
    _page = 0;
    _total = 0;
    _loadingMore = false;
    _moreError = null;
    _records = _firstPage(generation);
  }

  Future<List<AnalysisSummary>> _firstPage(int generation) async {
    final data = await _service.listPage(
      skill: _selectedSkill == _allSkills ? null : _selectedSkill,
    );
    if (mounted && generation == _generation) {
      _loaded = data.items;
      _page = data.page;
      _total = data.total;
    }
    return data.items;
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loaded.length >= _total) return;
    final generation = _generation;
    setState(() {
      _loadingMore = true;
      _moreError = null;
    });
    try {
      final data = await _service.listPage(
        skill: _selectedSkill == _allSkills ? null : _selectedSkill,
        page: _page + 1,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        final ids = _loaded.map((r) => r.id).toSet();
        _loaded = [..._loaded, ...data.items.where((r) => ids.add(r.id))];
        _page = data.page;
        _total = data.items.isEmpty ? _loaded.length : data.total;
        _records = Future.value(_loaded);
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _moreError = error);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loadingMore = false);
      }
    }
  }

  Future<void> _refresh() async {
    setState(_reload);
    try {
      await _records;
    } catch (_) {
      /* FutureBuilder shows retry. */
    }
  }

  String _date(DateTime date) {
    final local = date.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 分析紀錄')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '目前帳號：${AuthService.instance.currentUser?.name ?? "尚未登入"}。紀錄依帳號分開；只有儲存成功才會列在這裡。',
              style: const TextStyle(height: 1.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedSkill,
              decoration: const InputDecoration(
                labelText: '篩選技術',
                prefixIcon: Icon(Icons.filter_list),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: _allSkills,
                  child: Text('全部技術'),
                ),
                ...badmintonSkills.map(
                  (skill) => DropdownMenuItem<String>(
                    value: skill.name,
                    child: Text(skill.name),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                _selectedSkill = value;
                setState(_reload);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AnalysisSummary>>(
              future: _records,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return AccountRequestError(
                    error: snapshot.error!,
                    onRetry: () => setState(_reload),
                  );
                }
                final records = snapshot.data!;
                if (records.isEmpty) {
                  return _Message(
                    text: _selectedSkill == _allSkills
                        ? '目前帳號沒有已儲存紀錄。請確認登入原本儲存資料的帳號；分析後需按「儲存分析紀錄」並看到成功提示。'
                        : '$_selectedSkill目前還沒有分析紀錄。',
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: records.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == records.length) {
                        return Column(
                          children: [
                            Text('已載入 ${records.length} / $_total 筆'),
                            if (_moreError != null)
                              AccountRequestError(
                                error: _moreError!,
                                onRetry: () =>
                                    _moreError is ApiException &&
                                        (_moreError as ApiException)
                                                .statusCode ==
                                            401
                                    ? setState(_reload)
                                    : _loadMore(),
                              ),
                            if (_moreError == null && records.length < _total)
                              OutlinedButton(
                                key: const ValueKey('history-load-more'),
                                onPressed: _loadingMore ? null : _loadMore,
                                child: Text(_loadingMore ? '載入中…' : '載入更多'),
                              ),
                          ],
                        );
                      }
                      final record = records[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE8F5E9),
                            foregroundColor: const Color(0xFF1B5E20),
                            child: Text('${record.totalScore}'),
                          ),
                          title: Text(
                            record.skillName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_date(record.analyzedAt)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final changed = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnalysisRecordDetailScreen(
                                  analysisId: record.id,
                                ),
                              ),
                            );
                            if (changed == true && mounted) setState(_reload);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  const _Message({required this.text});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(text, textAlign: TextAlign.center)],
      ),
    ),
  );
}
