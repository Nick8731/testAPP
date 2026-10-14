import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/illustrated_lesson_data.dart';
import 'package:test_app/data/lesson_timing_data.dart';
import 'package:test_app/data/muscle_data.dart';
import 'package:test_app/data/muscle_role_profiles.dart';
import 'package:test_app/data/shot_route_data.dart';
import 'package:test_app/data/skill_data.dart';
import 'package:test_app/data/training_catalog.dart';

void main() {
  test('持拍侧前場跨步與接殺單手圖文一致', () {
    for (final name in ['挑球', '放網']) {
      final lesson = lessonFor(name);
      for (final i in [1, 2]) {
        expect(lesson.steps[i].how, contains('右腳'));
        expect(lesson.steps[i].how, contains('左腳留後'));
        expect(lesson.assetAt(i), endsWith('-v2.png'));
      }
    }
    final defence = lessonFor('接殺');
    for (var i = 0; i < 4; i++) {
      expect(defence.steps[i].how, contains('左手'));
      expect(defence.assetAt(i), endsWith('-v2.png'));
    }
    expect(defence.steps[1].how, contains('不碰拍柄'));
    expect(lessonFor('反手短發球').steps[0].how, contains('右腳稍前'));
    expect(lessonFor('反手短發球').steps[0].how, contains('不移位'));
  });

  test('撲球教學、球路與肌群完整，但不冒充既有 AI 評分項目', () {
    final lesson = lessonFor('撲球');
    expect(lesson.steps, hasLength(4));
    expect(groupFor('撲球').name, '前場');
    expect(lesson.goal, contains('低時'));
    expect(lesson.steps[1].how, contains('右腳'));
    expect(lesson.steps[2].how, contains('手指瞬間收緊'));
    expect(lesson.steps[2].avoid, contains('我方'));
    expect(lessonTiming[lesson.key]!.contactStep, 2);
    expect(shotRoutes[lesson.key]!.serve, isFalse);
    expect(shotRoutes[lesson.key]!.caution, contains('低於網帶'));
    final muscles = muscleSkills.firstWhere((s) => s.skillName == '撲球');
    expect(muscles.isAvailable, isTrue);
    expect(muscles.phases, hasLength(4));
    expect(muscles.phases[2].forceDescription, contains('手指'));
    expect(roleFor('net_kill', 1, 2), same(legSupport));
    expect(roleFor('net_kill', 2, 2), same(netKillControl));
    expect(badmintonSkills.any((s) => s.name == '撲球'), isFalse);
    expect(badmintonSkills, hasLength(9));
  });
}
