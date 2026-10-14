// Optional actual Flutter screenshot QA, outside the default test suite.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/illustrated_lesson_data.dart';
import 'package:test_app/data/lesson_timing_data.dart';
import 'package:test_app/screens/illustrated_lesson_screen.dart';
import 'package:test_app/widgets/lesson_character_figure.dart';

void main() {
  testWidgets('Actual teaching UI and every generated pose', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final entry in {
      'LessonChinese': r'C:\Windows\Fonts\msjh.ttc',
      'MaterialIcons': r'C:\development\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
    }.entries) {
      final font = FontLoader(entry.key)
        ..addFont(
          Future.value(
            ByteData.sublistView(File(entry.value).readAsBytesSync()),
          ),
        );
      await font.load();
    }
    final directory = Directory('preview/illustrated_courses')
      ..createSync(recursive: true);
    for (final lesson in illustratedLessons) {
      final capture = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: capture,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'LessonChinese',
              scaffoldBackgroundColor: const Color(0xFFF5F7F5),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1B5E20),
              ),
            ),
            home: IllustratedLessonScreen(lesson: lesson),
          ),
        ),
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byType(IllustratedLessonScreen));
        for (var i = 0; i < lesson.steps.length; i++) {
          await precacheImage(
            ResizeImage(AssetImage(lesson.assetAt(i)), width: 512),
            context,
          );
        }
      });
      await tester.pumpAndSettle();
      Future<void> save(String name) async {
        await tester.runAsync(() async {
          final boundary =
              capture.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('${directory.path}/$name.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      final contact = lessonTiming[lesson.key]!.contactStep;
      for (var i = 0; i < lesson.steps.length; i++) {
        await tester.ensureVisible(find.byKey(ValueKey('lesson-step-$i')));
        await tester.tap(find.byKey(ValueKey('lesson-step-$i')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(LessonCharacterFigure));
        await tester.pumpAndSettle();
        await save('${lesson.key}-step-${i + 1}');
        if (i == (contact < 0 ? 2 : contact)) {
          await save('${lesson.key}-contact');
        }
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }
  });
}
