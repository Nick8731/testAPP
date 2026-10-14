import 'package:flutter/material.dart';

import '../services/analysis_service.dart';
import '../widgets/account_request_error.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class AnalysisRecordDetailScreen extends StatefulWidget {
  final int analysisId;

  const AnalysisRecordDetailScreen({super.key, required this.analysisId});

  @override
  State<AnalysisRecordDetailScreen> createState() =>
      _AnalysisRecordDetailScreenState();
}

class _AnalysisRecordDetailScreenState
    extends State<AnalysisRecordDetailScreen> {
  final _service = AnalysisService();
  late Future<AnalysisRecord> _record = _service.get(widget.analysisId);
  bool _deleting = false;
  @override
  void initState() {
    super.initState();
    AuthService.instance.currentUserChanges.addListener(_sessionChanged);
  }

  void _sessionChanged() {
    if (mounted) setState(() => _record = _service.get(widget.analysisId));
  }

  @override
  void dispose() {
    AuthService.instance.currentUserChanges.removeListener(_sessionChanged);
    super.dispose();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除分析紀錄？'),
        content: const Text('刪除後無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _deleting = true);
    try {
      await _service.delete(widget.analysisId);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            action: error is ApiException && error.statusCode == 401
                ? SnackBarAction(
                    label: '重新登入',
                    onPressed: () async {
                      final success = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                      if (success == true && mounted) {
                        setState(
                          () => _record = _service.get(widget.analysisId),
                        );
                      }
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分析詳情'),
        actions: [
          IconButton(
            onPressed: _deleting ? null : _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<AnalysisRecord>(
        future: _record,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return AccountRequestError(
              error: snapshot.error!,
              onRetry: () =>
                  setState(() => _record = _service.get(widget.analysisId)),
            );
          }
          final record = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: const Color(0xFF123524),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '${record.skillName}  ${record.totalScore} / 100',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...record.scores.map(
                (item) => ListTile(
                  title: Text(item.name),
                  trailing: Text('${item.score}'),
                ),
              ),
              ...record.details.entries.map(
                (item) =>
                    ListTile(title: Text(item.key), trailing: Text(item.value)),
              ),
              _feedback('表現良好', record.goodPoints),
              _feedback('需要調整', record.problems),
              _feedback('修正建議', record.suggestions),
            ],
          );
        },
      ),
    );
  }

  Widget _feedback(String title, List<String> values) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (values.isEmpty)
            const Text('暫無')
          else
            ...values.map((value) => Text('• $value')),
        ],
      ),
    ),
  );
}
