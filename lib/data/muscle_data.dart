import '../models/muscle_phase.dart';
import 'illustrated_lesson_data.dart';
import 'lesson_timing_data.dart';
import 'training_catalog.dart';
import 'muscle_role_profiles.dart';
import 'muscle_training_data.dart';

/// Each phase corresponds to the same-numbered reviewed illustration. Legacy
/// second fields are ordinal placeholders; no teaching timeline is inferred.
final muscleSkills = trainingSkills
    .map((skill) {
      final lesson = lessonFor(skill.name), timing = lessonTiming[lesson.key]!;
      final names = lesson.key == 'clear'
          ? ['準備', '架拍／引拍', '加速揮拍', '擊球', '隨揮', '回位']
          : lesson.key == 'smash'
          ? ['準備', '架拍', '引拍', '加速', '擊球', '隨揮', '回位']
          : lesson.steps.map((s) => s.title).toList();
      final phases = List.generate(lesson.steps.length, (index) {
        final role = roleFor(lesson.key, index, timing.contactStep);
        final cue = lesson.steps[index];
        final force = index == timing.contactStep
            ? timing.power
            : timing.contactStep < 0
            ? timing.power
            : index < timing.contactStep
            ? timing.relax
            : '觸球後有控制地減速、收拍與回位，握拍恢復放鬆；放鬆不是失去支撐。';
        final tags = lesson.key == 'clear'
            ? _clearTags[index]
            : lesson.key == 'smash'
            ? _smashTags[index]
            : <String>[];
        return MusclePhase(
          phaseName: names[index],
          startSecond: index.toDouble(),
          endSecond: (index + 1).toDouble(),
          primaryMuscles: role.main,
          secondaryMuscles: role.assist,
          stabilizingMuscles: role.stabilize,
          primaryRegions: role.mainRegions,
          secondaryRegions: role.assistRegions,
          stabilizingRegions: role.stabilizeRegions,
          forceDescription: '${cue.how}\n\n肌群角色：${role.role}\n\n時機：$force',
          mistakes: [cue.avoid, '不要從圖上高亮或 AI 分數直接推斷某塊肌肉無力。'],
          aiIssueTags: tags,
        );
      });
      return MuscleSkillData(
        skillName: skill.name,
        englishName: skill.englishName,
        videoPath: '',
        overview: muscleRoleNotes[skill.name]!,
        forceChain: lesson.key == 'serve_short'
            ? ['站穩', '拍面定位', '拇指支撐', '短促前送', '快收拍']
            : lesson.key == 'net' || lesson.key == 'push'
            ? ['穩定跨步', '軀幹控制', '前臂／手指控制', '推回準備']
            : lesson.key == 'net_kill'
            ? ['右腳跨步支撐', '肩帶穩定拍面', '前臂／手指短促握放', '短隨揮／推回']
            : lesson.key == 'split'
            ? ['觀察時機', '小幅卸重', '髖膝踝控制', '推地啟動']
            : ['下肢支撐', '重心／軀幹配合', '肩帶控制', '前臂／手指', '減速／回位'],
        phases: List.unmodifiable(phases),
      );
    })
    .toList(growable: false);

const _clearTags = <List<String>>[
  ['base_unstable', 'knee_preparation_low'],
  ['elbow_setup_low', 'shoulder_elevation_low'],
  ['trunk_rotation_low', 'arm_only_swing'],
  ['contact_point_low', 'elbow_extension_low'],
  ['follow_through_incomplete', 'body_balance_low'],
  ['recovery_slow', 'landing_unstable'],
];
const _smashTags = <List<String>>[
  ['base_unstable', 'contact_position_late'],
  ['elbow_setup_low', 'shoulder_elevation_low'],
  ['backswing_incomplete', 'trunk_extension_excessive'],
  ['lower_body_inactive', 'trunk_rotation_low', 'arm_only_swing'],
  ['contact_point_low', 'elbow_extension_low', 'forearm_rotation_low'],
  ['follow_through_incomplete', 'body_balance_low'],
  ['landing_unstable', 'recovery_slow'],
];
