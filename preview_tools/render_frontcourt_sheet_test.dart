// Optional visual QA only. Does not change artwork or production progress.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/illustrated_lesson_data.dart';

void main() {
  testWidgets('frontcourt stance and free-hand visual review', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await (FontLoader('Chinese')..addFont(
          Future.value(
            ByteData.sublistView(
              File(r'C:\Windows\Fonts\msjh.ttc').readAsBytesSync(),
            ),
          ),
        ))
        .load();
    final names = ['挑球', '放網', '接殺', '反手短發球', '撲球'];
    final capture = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: capture,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Chinese'),
          home: Scaffold(
            backgroundColor: const Color(0xFFF5F7F5),
            body: Column(
              children: [
                for (final name in names)
                  Expanded(
                    child: Row(
                      children: [
                        for (var i = 0; i < 4; i++)
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    '$name · ${i + 1} ${lessonFor(name).steps[i].title}',
                                  ),
                                ),
                                Expanded(
                                  child: Image.asset(
                                    lessonFor(name).assetAt(i),
                                    fit: BoxFit.contain,
                                    cacheWidth: 512,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final context = tester.element(find.byType(Scaffold));
      for (final name in names) {
        for (var i = 0; i < 4; i++) {
          await precacheImage(
            ResizeImage(AssetImage(lessonFor(name).assetAt(i)), width: 512),
            context,
          );
        }
      }
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.runAsync(() async {
      final bitmap =
          await (capture.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage();
      final bytes = await bitmap.toByteData(format: ui.ImageByteFormat.png);
      Directory('preview/frontcourt_revision').createSync(recursive: true);
      File('preview/frontcourt_revision/contact-sheet.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
      bitmap.dispose();
    });
  });
}
