import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test_app/data/skill_data.dart';
import 'package:test_app/screens/app_guide_screen.dart';
import 'package:test_app/screens/register_screen.dart';
import 'package:test_app/services/api_service.dart';

void main() {
  test('九項技術改用分解圖，不再宣稱可播放教學影片', () {
    final videoSkills = badmintonSkills.where((skill) => skill.hasVideo);
    final textOnlySkills = badmintonSkills.where((skill) => !skill.hasVideo);

    expect(videoSkills, isEmpty);
    expect(textOnlySkills, hasLength(9));
    for (final skill in videoSkills) {
      expect(
        File(skill.videoPath).existsSync(),
        isTrue,
        reason: '${skill.name} 的影片資產不存在：${skill.videoPath}',
      );
    }
  });

  test('API 連線問題轉換成使用者可理解的訊息', () async {
    final unavailable = ApiService(
      client: MockClient((_) async => http.Response('', 503)),
    );
    final disconnected = ApiService(
      client: MockClient((request) async {
        throw http.ClientException('Connection refused', request.url);
      }),
    );

    await expectLater(
      unavailable.getJson('/health'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          contains('伺服器暫時發生問題'),
        ),
      ),
    );
    await expectLater(
      disconnected.getJson('/health'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          contains('無法連接伺服器'),
        ),
      ),
    );
  });

  test('登入成功後先取得會員資料再通知個人頁更新', () {
    final authSource = File('lib/services/auth_service.dart')
        .readAsStringSync();
    final profileSource = File('lib/screens/profile_screen.dart')
        .readAsStringSync();

    expect(
      authSource,
      contains('final user = await _fetchCurrentUser(accessToken)'),
    );
    expect(profileSource, contains('ValueListenableBuilder<AppUser?>'));
    expect(profileSource, contains('AuthService.instance.currentUserChanges'));
    expect(profileSource, isNot(contains('FutureBuilder<AppUser?>')));
    expect(profileSource, contains('final loggedInUser ='));
    expect(profileSource, contains("Text('登入成功，歡迎 \${loggedInUser.name}')"));
    expect(profileSource, contains("SnackBar(content: Text('已登出'))"));
    expect(authSource, contains('currentUserChanges.value = null'));
    final mainSource = File('lib/main.dart').readAsStringSync();
    expect(
      mainSource,
      contains('unawaited(AuthService.instance.restoreSession())'),
    );
  });

  testWidgets('註冊頁清楚要求確認密碼且不宣稱自動登入', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    expect(find.text('再次輸入密碼'), findsOneWidget);
    expect(find.text('建立帳號'), findsWidgets);
    expect(find.text('註冊並登入'), findsNothing);
    expect(find.textContaining('回到登入頁'), findsOneWidget);
  });

  testWidgets('使用指南說明訓練流程、AI 限制與隱私', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: AppGuideScreen()));

    expect(find.text('建議使用流程'), findsOneWidget);
    expect(find.text('拍攝清楚，分析才有意義'), findsOneWidget);
    expect(find.text('如何理解 AI 分數'), findsOneWidget);
    expect(find.text('資料與隱私'), findsOneWidget);
  });
}
