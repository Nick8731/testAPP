import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/screens/skills_screen.dart';
import 'package:test_app/data/training_catalog.dart';
import 'package:test_app/data/illustrated_lesson_data.dart';
import 'package:test_app/data/lesson_contact_points.dart';
import 'package:test_app/data/lesson_timing_data.dart';
import 'package:test_app/widgets/drive_pose_diagram.dart';

void main() {
  testWidgets('首頁不展開全部課程，可開啟全部並回到分類', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: SkillsScreen()));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('training-course-殺球')), findsNothing);
    final button = find.byKey(const ValueKey('training-all-courses'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(button), alignment: .25);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('回到分類'), findsOneWidget);
    final scroll = find.byType(Scrollable).first;
    for (final skill in trainingSkills) {
      tester.state<ScrollableState>(scroll).position.jumpTo(0);
      await tester.pumpAndSettle();
      final course = find.byKey(ValueKey('training-course-${skill.name}'));
      await tester.scrollUntilVisible(
        course,
        200,
        scrollable: scroll,
        maxScrolls: 80,
      );
      expect(course, findsOneWidget);
    }
    tester.state<ScrollableState>(scroll).position.jumpTo(0);
    await tester.pumpAndSettle();
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('回到分類'), findsNothing);
    expect(find.byKey(const ValueKey('training-course-殺球')), findsNothing);
    expect(tester.takeException(), isNull);
  });
  test('平球同一組修正圖供技術與肌肉課程使用，高遠球圖點文字一致', () {
    final drive = lessonFor('平球');
    expect(drive.assetAt(1), driveCharacterAssets[1]);
    expect(drive.assetAt(2), driveCharacterAssets[2]);
    expect(drive.assetAt(1), contains('backswing-v2'));
    expect(lessonFor('高遠球').assetAt(3), contains('contact-v2'));
    expect(lessonContactPoints['clear']!.$1, closeTo(.401, .001));
    expect(lessonTiming['clear']!.contact, contains('不刻意往前探'));
  });
}
