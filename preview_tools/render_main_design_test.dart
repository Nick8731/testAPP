import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/main.dart';
import 'package:test_app/screens/profile_screen.dart';
import 'package:test_app/theme/app_theme.dart';

void main() {
  testWidgets('Render actual main design with Chinese font', (tester) async {
    // Test-only renderer uses isolated local reading progress.
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
    for (final entry in {
      'home': const MainNavigationPage(),
      'profile': const ProfileScreen(),
    }.entries) {
      await tester.pumpWidget(const SizedBox());
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(fontFamily: 'Chinese'),
            home: entry.value,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final bitmap =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await bitmap.toByteData(format: ui.ImageByteFormat.png);
        Directory('preview/main_design').createSync(recursive: true);
        File('preview/main_design/${entry.key}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        bitmap.dispose();
      });
    }
  });
}
