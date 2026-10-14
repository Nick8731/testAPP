import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/tactic_sequences.dart';
import 'package:test_app/data/muscle_data.dart';
import 'package:test_app/data/illustrated_lesson_data.dart';
import 'package:test_app/data/lesson_timing_data.dart';
import 'package:test_app/screens/muscle_detail_screen.dart';
import 'package:test_app/widgets/lesson_character_figure.dart';
import 'package:test_app/widgets/tactic_animation.dart';

void main() {
  testWidgets('Actual Chinese UI screenshots for tactics and muscle lessons', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final entry in {
      'LessonChinese': r'C:\Windows\Fonts\msjh.ttc',
      'MaterialIcons': r'C:\development\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
    }.entries) {
      await (FontLoader(entry.key)..addFont(
            Future.value(
              ByteData.sublistView(File(entry.value).readAsBytesSync()),
            ),
          ))
          .load();
    }
    final folder = Directory('preview/tactics_muscles')
      ..createSync(recursive: true);
    late GlobalKey capture;
    Future<void> show(Widget screen) async {
      await tester.pumpWidget(const SizedBox());
      capture = GlobalKey();
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
            home: screen,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> save(String name) async {
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            capture.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${folder.path}/$name.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    for (final plan in tacticSequences.values) {
      await show(
        Scaffold(
          appBar: AppBar(title: Text(plan.id)),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TacticAnimation(sequence: plan),
            ),
          ),
        ),
      );
      for (var beat = 0; beat < plan.beats.length; beat++) {
        if (beat > 0) {
          await tester.tap(find.byKey(const ValueKey('tactic-next')));
          await tester.pumpAndSettle();
        }
        for (final progress in [0.0, .5, 1.0]) {
          tester
              .widget<Slider>(find.byKey(const ValueKey('tactic-scrub')))
              .onChanged!(progress);
          await tester.pumpAndSettle();
          await save('${plan.id}-${beat + 1}-$progress');
        }
      }
    }
    for (final skill in muscleSkills) {
      final lesson = lessonFor(skill.skillName);
      await show(MuscleDetailScreen(skill: skill));
      await tester.runAsync(() async {
        final context = tester.element(find.byType(MuscleDetailScreen));
        for (var i = 0; i < lesson.steps.length; i++) {
          await precacheImage(
            ResizeImage(AssetImage(lesson.assetAt(i)), width: 512),
            context,
          );
        }
      });
      await tester.pumpAndSettle();
      final phase = lessonTiming[lesson.key]!.contactStep;
      final chip = find.byKey(
        ValueKey('muscle-phase-${phase < 0 ? 2 : phase}'),
      );
      await tester.scrollUntilVisible(
        chip,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await Scrollable.ensureVisible(tester.element(chip), alignment: .25);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(LessonCharacterFigure));
      await tester.pumpAndSettle();
      await save('muscle-${lesson.key}');
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
