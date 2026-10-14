import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/screens/analysis_history_screen.dart';
import 'package:test_app/screens/progress_screen.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/widgets/account_request_error.dart';

import '../test/stability_test.dart' as fixtures;

void main() {
  testWidgets('Stability UI Chinese previews', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final entry in {
      'Chinese': r'C:\Windows\Fonts\msjh.ttc',
      'MaterialIcons': r'C:\development\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
    }.entries) {
      await (FontLoader(entry.key)..addFont(
            Future.value(
              ByteData.sublistView(File(entry.value).readAsBytesSync()),
            ),
          ))
          .load();
    }
    final screens = <String, Widget>{
      'history': AnalysisHistoryScreen(service: fixtures.PagedHistory()),
      'versions': ProgressScreen(service: fixtures.VersionProgress()),
      'expired': Scaffold(
        appBar: AppBar(title: const Text('AI 分析紀錄')),
        body: AccountRequestError(
          error: const ApiException('登入狀態已失效，請重新登入', statusCode: 401),
          onRetry: () {},
        ),
      ),
    };
    for (final entry in screens.entries) {
      await tester.pumpWidget(const SizedBox());
      final capture = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: capture,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Chinese',
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1B5E20),
              ),
              scaffoldBackgroundColor: const Color(0xFFF5F7F5),
            ),
            home: entry.value,
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (entry.key == 'history') {
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('history-load-more')),
          400,
          scrollable: find.byType(Scrollable).last,
          maxScrolls: 80,
        );
      } else if (entry.key == 'versions') {
        await tester.ensureVisible(
          find.byType(DropdownButtonFormField<String>).last,
        );
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final bitmap =
            await (capture.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await bitmap.toByteData(format: ui.ImageByteFormat.png);
        Directory('preview/stability').createSync(recursive: true);
        File('preview/stability/${entry.key}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        bitmap.dispose();
      });
    }
  });
}
