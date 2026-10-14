// Optional local visual QA, not part of the default test suite.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/screens/drive_lesson_screen.dart';
import 'package:test_app/widgets/drive_pose_diagram.dart';

void main() {
  testWidgets('Render the actual pilot widget for visual review', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final loader = FontLoader('DrivePreviewChinese');
    loader.addFont(
      Future.value(
        ByteData.sublistView(
          File(r'C:\Windows\Fonts\msjh.ttc').readAsBytesSync(),
        ),
      ),
    );
    await loader.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(
      Future.value(
        ByteData.sublistView(
          File(
            r'C:\development\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
          ).readAsBytesSync(),
        ),
      ),
    );
    await icons.load();
    final capture = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: capture,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'DrivePreviewChinese',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F7F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF5F7F5),
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: false,
            ),
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const DriveLessonScreen(),
                  ),
                ),
                child: const Text('開啟預覽'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('開啟預覽'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(DriveLessonScreen));
      for (final asset in driveCharacterAssets) {
        await precacheImage(AssetImage(asset), context);
        await precacheImage(ResizeImage(AssetImage(asset), width: 512), context);
      }
    });
    await tester.pumpAndSettle();
    Future<void> save(String name) async {
      await tester.runAsync(() async {
        final boundary =
            capture.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory('preview/drive_lesson')
          ..createSync(recursive: true);
        File('${directory.path}/$name.png')
            .writeAsBytesSync(png!.buffer.asUint8List());
        image.dispose();
      });
    }

    await save('ready');
    await tester.tap(find.byKey(const ValueKey('drive-step-2')));
    await tester.pumpAndSettle();
    await save('contact');
    await tester.tap(find.byKey(const ValueKey('drive-enlarge')).first);
    await tester.pumpAndSettle();
    await save('character-detail');
    await tester.tap(find.byKey(const ValueKey('drive-close-enlarged')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('drive-record-set')));
    await tester.pumpAndSettle();
    await save('practice');
    expect(tester.takeException(), isNull);
  });
}
