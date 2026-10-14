import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/screens/beginner_grip_screen.dart';
import 'package:test_app/data/beginner_course_data.dart';

void main() {
  testWidgets('Actual Chinese beginner grip screenshots', (tester) async {
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
    final capture = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: capture,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Chinese',
            scaffoldBackgroundColor: const Color(0xFFF5F7F5),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
            ),
          ),
          home: const BeginnerGripScreen(),
        ),
      ),
    );
    await tester.runAsync(() async {
      for (final asset in beginnerGripAssets) {
        await precacheImage(
          ResizeImage(AssetImage(asset), width: 512),
          tester.element(find.byType(BeginnerGripScreen)),
        );
      }
    });
    await tester.pumpAndSettle();
    final folder = Directory('preview/beginner_grips')
      ..createSync(recursive: true);
    Future<void> save(String name) async {
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (capture.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${folder.path}/$name.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    final scroll = find.byType(Scrollable).first;
    for (var step = 0; step < 3; step++) {
      tester.state<ScrollableState>(scroll).position.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('grip-step-$step')));
      await tester.pumpAndSettle();
      await save('step-${step + 1}');
      if (step < 2) {
        await tester.scrollUntilVisible(
          find.text('怎麼握／怎麼換'),
          300,
          scrollable: scroll,
        );
        await Scrollable.ensureVisible(
          tester.element(find.text('先摸出拍柄的平面與斜面')),
          alignment: .1,
        );
        await tester.pumpAndSettle();
        await save('guide-${step + 1}');
      }
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
