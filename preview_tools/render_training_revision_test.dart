import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/screens/skills_screen.dart';
import 'package:test_app/screens/drive_lesson_screen.dart';
import 'package:test_app/widgets/drive_pose_diagram.dart';

void main() {
  testWidgets('Training overview and corrected drive teaching UI', (
    tester,
  ) async {
    // Optional Flutter test lives outside test/ to avoid routine PNG writes.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
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
    late GlobalKey key;
    Future<void> show(Widget screen) async {
      await tester.pumpWidget(const SizedBox());
      key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Chinese',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1B5E20),
              ),
              scaffoldBackgroundColor: const Color(0xFFF5F7F5),
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
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('preview/training_revision').createSync(recursive: true);
        File('preview/training_revision/$name.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await show(const SkillsScreen());
    await save('overview');
    await tester.ensureVisible(
      find.byKey(const ValueKey('training-all-courses')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('training-all-courses')));
    await tester.pumpAndSettle();
    await save('all-courses');
    await show(const DriveLessonScreen());
    await tester.runAsync(() async {
      for (final asset in driveCharacterAssets) {
        await precacheImage(
          ResizeImage(AssetImage(asset), width: 512),
          tester.element(find.byType(DriveLessonScreen)),
        );
      }
    });
    for (final step in [1, 2]) {
      await tester.ensureVisible(find.byKey(ValueKey('drive-step-$step')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('drive-step-$step')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(ValueKey('drive-diagram-$step')));
      await tester.pumpAndSettle();
      await save('drive-$step');
    }
    await tester.pumpWidget(const SizedBox());
  });
}
