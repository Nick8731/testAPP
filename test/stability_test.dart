import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test_app/services/auth_service.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/analysis_service.dart';
import 'package:test_app/screens/analysis_history_screen.dart';
import 'package:test_app/screens/progress_screen.dart';
import 'package:test_app/widgets/account_request_error.dart';
import 'package:test_app/screens/login_screen.dart';

const _me = '{"userId":1,"name":"Nick","email":"nick@example.com"}';

class PagedHistory extends AnalysisService {
  final List<int> requested = [];
  @override
  Future<AnalysisHistoryPage> listPage({
    String? skill,
    int page = 1,
    int pageSize = 20,
  }) async {
    requested.add(page);
    final first = (page - 1) * pageSize;
    return AnalysisHistoryPage(
      page: page,
      total: 101,
      items: [
        for (var i = first; i < first + pageSize && i < 101; i++)
          AnalysisSummary(
            id: i + 1,
            skillName: '高遠球',
            totalScore: 80,
            analyzedAt: DateTime(2026, 1, 1),
          ),
      ],
    );
  }
}

class VersionProgress extends AnalysisService {
  final List<String?> requested = [];
  @override
  Future<SkillProgress> progress(String name, {String? version}) async {
    requested.add(version);
    return SkillProgress(
      skillName: name,
      latestScore: 85,
      previousScore: null,
      change: null,
      bestScore: 85,
      records: [ProgressPoint(date: DateTime(2026), score: 85)],
      selectedVersion: version ?? 'pose-phase-v3',
      availableVersions: ['pose-phase-v3', 'pose-still-v2'],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  tearDown(() => ApiService.onUnauthorized = null);

  test('登入姓名立即更新，401 清除失效登入；舊回應不清除新憑證', () async {
    var issued = 0;
    final api = ApiService(
      client: MockClient(
        (r) async => http.Response(
          r.url.path.endsWith('/login')
              ? jsonEncode({'accessToken': 'token-${++issued}'})
              : _me,
          200,
        ),
      ),
    );
    final auth = AuthService.forTesting(
      api: api,
      storage: const FlutterSecureStorage(),
    );
    await auth.login(email: 'nick@example.com', password: 'test-password');
    expect(auth.currentUser!.name, 'Nick');
    final old = (await auth.token)!;
    await auth.login(email: 'nick@example.com', password: 'test-password');
    await auth.invalidateToken(old);
    expect(await auth.token, 'token-2');
    final failed = ApiService(
      client: MockClient((_) async => http.Response('{}', 401)),
    );
    await expectLater(
      failed.getJson('/analysis', token: await auth.token),
      throwsA(isA<ApiException>()),
    );
    expect(auth.currentUser, isNull);
    expect(await auth.token, isNull);
    expect(auth.sessionMessage.value, contains('登入已過期'));
  });

  test('暫時離線保留憑證，背景驗證不覆蓋登出', () async {
    FlutterSecureStorage.setMockInitialValues({
      'smashcoach_access_token': 'saved',
    });
    final offline = AuthService.forTesting(
      api: ApiService(
        client: MockClient((_) async => throw http.ClientException('offline')),
      ),
      storage: const FlutterSecureStorage(),
    );
    await offline.restoreSession();
    expect(await offline.token, 'saved');
    expect(offline.sessionMessage.value, contains('教學仍可使用'));
    final response = Completer<http.Response>(), started = Completer<void>();
    final auth = AuthService.forTesting(
      api: ApiService(
        client: MockClient((_) {
          started.complete();
          return response.future;
        }),
      ),
      storage: const FlutterSecureStorage(),
    );
    final pending = auth.restoreSession();
    await started.future;
    await auth.logout();
    response.complete(http.Response(_me, 200));
    await pending;
    expect(auth.currentUser, isNull);
    expect(await auth.token, isNull);
    final main = File('lib/main.dart').readAsStringSync();
    expect(main.indexOf('runApp('), lessThan(main.indexOf('unawaited(')));
  });

  test('背景舊401不取消正在進行的新登入', () async {
    FlutterSecureStorage.setMockInitialValues({
      'smashcoach_access_token': 'old',
    });
    final loginResponse = Completer<http.Response>(),
        started = Completer<void>();
    final auth = AuthService.forTesting(
      api: ApiService(
        client: MockClient((r) {
          if (r.url.path.endsWith('/login')) {
            started.complete();
            return loginResponse.future;
          }
          return Future.value(http.Response(_me, 200));
        }),
      ),
      storage: const FlutterSecureStorage(),
    );
    final login = auth.login(
      email: 'nick@example.com',
      password: 'test-password',
    );
    await started.future;
    await auth.invalidateToken('old');
    loginResponse.complete(http.Response('{"accessToken":"new"}', 200));
    await login;
    expect(await auth.token, 'new');
    expect(auth.currentUser!.name, 'Nick');
  });

  testWidgets('歷史可載入101筆，不限於前100筆', (tester) async {
    final service = PagedHistory();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: AnalysisHistoryScreen(service: service)),
    );
    await tester.pumpAndSettle();
    for (var page = 2; page <= 6; page++) {
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('history-load-more')),
        400,
        scrollable: find.byType(Scrollable).last,
        maxScrolls: 80,
      );
      await tester.tap(find.byKey(const ValueKey('history-load-more')));
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(
      find.text('已載入 101 / 101 筆'),
      400,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 80,
    );
    expect(service.requested, [1, 2, 3, 4, 5, 6]);
    expect(find.byKey(const ValueKey('history-load-more')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('趨勢可選版本，過期提示可開啟重新登入', (tester) async {
    final service = VersionProgress();
    await tester.pumpWidget(
      MaterialApp(home: ProgressScreen(service: service)),
    );
    await tester.pumpAndSettle();
    final selector = find.byType(DropdownButtonFormField<String>).last;
    await tester.ensureVisible(selector);
    tester.widget<DropdownButtonFormField<String>>(selector).onChanged!(
      'pose-still-v2',
    );
    await tester.pumpAndSettle();
    expect(service.requested, [null, 'pose-still-v2']);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountRequestError(
            error: const ApiException('登入已失效', statusCode: 401),
            onRetry: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('重新登入'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
