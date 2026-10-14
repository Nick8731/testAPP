import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/services/analysis_service.dart';
import 'package:test_app/screens/analysis_history_screen.dart';

class EmptyHistory extends AnalysisService {
  int requests = 0;
  @override
  Future<AnalysisHistoryPage> listPage({
    String? skill,
    int page = 1,
    int pageSize = 20,
  }) async {
    requests++;
    return AnalysisHistoryPage(items: [], total: 0, page: page);
  }
}

void main() {
  testWidgets('紀錄篩選刷新不讓setState回傳Future', (tester) async {
    final service = EmptyHistory();
    await tester.pumpWidget(
      MaterialApp(home: AnalysisHistoryScreen(service: service)),
    );
    await tester.pumpAndSettle();
    expect(service.requests, 1);
    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    dropdown.onChanged!('高遠球');
    await tester.pumpAndSettle();
    expect(service.requests, 2);
    expect(find.text('高遠球目前還沒有分析紀錄。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
