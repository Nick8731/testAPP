import '../models/muscle_phase.dart';

/// Functional teaching groups, NOT measured activation rankings.
class MuscleRoleProfile {
  final List<String> main, assist, stabilize;
  final Set<MuscleRegion> mainRegions, assistRegions, stabilizeRegions;
  final String role;
  const MuscleRoleProfile(
    this.main,
    this.assist,
    this.stabilize,
    this.mainRegions,
    this.assistRegions,
    this.stabilizeRegions,
    this.role,
  );
}

const legSupport = MuscleRoleProfile(
  ['股四頭肌', '臀肌'],
  ['腿後肌群', '小腿肌群'],
  ['核心肌群', '臀中肌'],
  {MuscleRegion.quadriceps, MuscleRegion.glutes},
  {MuscleRegion.hamstrings, MuscleRegion.calves},
  {MuscleRegion.core},
  '髖膝控制支撐與減速，小腿配合踝部控制，核心維持軀幹穩定。',
);
const shoulderSetup = MuscleRoleProfile(
  ['三角肌（手臂抬起）'],
  ['斜方肌、前鋸肌（肩胛配合）'],
  ['肩袖肌群', '核心肌群'],
  {MuscleRegion.shoulders},
  {MuscleRegion.upperBack},
  {MuscleRegion.shoulders, MuscleRegion.core},
  '肩部抬臂與肩胛配合上轉，不聳肩、不把肩胛硬夾死；肩袖協助關節控制。',
);
const backswingControl = MuscleRoleProfile(
  ['肩部外旋相關肌群', '三角肌後束'],
  ['肩胛周圍肌群', '前臂肌群'],
  ['肩袖肌群', '核心肌群'],
  {MuscleRegion.shoulders},
  {MuscleRegion.upperBack, MuscleRegion.forearms},
  {MuscleRegion.core},
  '保留舒服的引拍空間，不靠腰過度後仰或把肩扭到極限。',
);
const turnAndSwing = MuscleRoleProfile(
  ['臀肌', '腹斜肌', '胸大肌'],
  ['三角肌', '上臂肌群'],
  ['肩袖肌群', '深層軀幹肌群'],
  {MuscleRegion.glutes, MuscleRegion.core, MuscleRegion.chest},
  {MuscleRegion.shoulders, MuscleRegion.upperArms},
  {MuscleRegion.core, MuscleRegion.shoulders},
  '下肢支撐與重心轉移配合髖、軀幹轉動，再帶動上臂；不要把順序理解成各部位完全分開動。',
);
const overheadContact = MuscleRoleProfile(
  ['肱三頭肌', '肩部內旋相關肌群', '前臂旋轉肌群'],
  ['三角肌', '手指屈伸肌群'],
  ['肩袖肌群', '核心肌群'],
  {MuscleRegion.upperArms, MuscleRegion.shoulders, MuscleRegion.forearms},
  {MuscleRegion.forearms},
  {MuscleRegion.core, MuscleRegion.shoulders},
  '伸肘、肩部轉動與前臂旋轉配合拍面控制；手指只短暫加強握拍，不靠猛壓手腕。',
);
const deceleration = MuscleRoleProfile(
  ['肩袖與肩後側肌群（控制減速）'],
  ['肩胛周圍肌群', '前臂肌群'],
  ['核心肌群', '臀肌'],
  {MuscleRegion.shoulders},
  {MuscleRegion.upperBack, MuscleRegion.forearms},
  {MuscleRegion.core, MuscleRegion.glutes},
  '揮拍後肩帶與軀幹一起控制減速；不是全部鬆掉，也不把手臂突然煞停。',
);
const shortControl = MuscleRoleProfile(
  ['前臂旋轉與手指控制肌群'],
  ['三角肌', '肘部屈伸相關肌群'],
  ['肩袖肌群', '核心肌群'],
  {MuscleRegion.forearms},
  {MuscleRegion.shoulders, MuscleRegion.upperArms},
  {MuscleRegion.core, MuscleRegion.shoulders},
  '依球路用前臂、手指與小幅伸拍控制，肩帶提供支撐；短動作不等於只有手腕用力。',
);
const netControl = MuscleRoleProfile(
  ['前臂與手指控制肌群'],
  ['三角肌（維持伸拍位置）'],
  ['核心肌群', '臀肌、股四頭肌（跨步支撐）'],
  {MuscleRegion.forearms},
  {MuscleRegion.shoulders},
  {MuscleRegion.core, MuscleRegion.glutes, MuscleRegion.quadriceps},
  '以前臂與手指穩定拍面、小幅前送，跨步腿和軀幹讓接觸位置穩定；不要用力甩腕。',
);
const liftControl = MuscleRoleProfile(
  ['前臂旋轉與手指控制肌群'],
  ['三角肌', '肘部屈伸相關肌群'],
  ['核心肌群', '臀肌、股四頭肌'],
  {MuscleRegion.forearms},
  {MuscleRegion.shoulders, MuscleRegion.upperArms},
  {MuscleRegion.core, MuscleRegion.glutes, MuscleRegion.quadriceps},
  '穩定跨步後，手臂與前臂、手指配合向前上方送球；前腳之後推回，不能只靠手腕甩高。',
);
const serveControl = MuscleRoleProfile(
  ['前臂旋轉與手指控制肌群'],
  ['三角肌', '肘部屈伸相關肌群'],
  ['核心肌群', '下肢支撐肌群'],
  {MuscleRegion.forearms},
  {MuscleRegion.shoulders, MuscleRegion.upperArms},
  {MuscleRegion.core, MuscleRegion.glutes, MuscleRegion.quadriceps},
  '重心前移配合下手揮拍；雙腳保持接觸地面且不移位，不套用跨步挑球的推回模式。',
);
const backhandControl = MuscleRoleProfile(
  ['前臂、手指及拇指控制肌群'],
  ['肱三頭肌等肘部伸展相關肌群'],
  ['肩袖肌群', '核心肌群'],
  {MuscleRegion.forearms},
  {MuscleRegion.upperArms},
  {MuscleRegion.shoulders, MuscleRegion.core},
  '拇指支撐拍柄配合短促前送或擋球，肩帶與軀幹穩定；不需過大的引拍。',
);
const splitPush = MuscleRoleProfile(
  ['臀肌', '股四頭肌', '小腿肌群'],
  ['腿後肌群'],
  ['核心肌群', '臀中肌'],
  {MuscleRegion.glutes, MuscleRegion.quadriceps, MuscleRegion.calves},
  {MuscleRegion.hamstrings},
  {MuscleRegion.core},
  '髖膝踝協調控制落地與推地；柔和落地後依方向啟動，不做高跳或大力跺地。',
);

MuscleRoleProfile roleFor(String key, int index, int contact) {
  if (key == 'split') return index >= 1 ? splitPush : legSupport;
  if (index == 0 ||
      index ==
          ((key == 'lift' || key == 'net' || key == 'push' || key == 'net_kill')
              ? 1
              : -1) ||
      index > (contact + 1)) {
    return legSupport;
  }
  if (key == 'clear' || key == 'smash' || key == 'drop' || key == 'slice') {
    if (index == 1) return shoulderSetup;
    if (key == 'smash' && index == 2) return backswingControl;
    if (index == contact - 1) return turnAndSwing;
    if (index == contact) return overheadContact;
    return deceleration;
  }
  if (index > contact) return key == 'serve_high' ? deceleration : legSupport;
  if (key == 'net' || key == 'push') return netControl;
  if (key == 'net_kill') return netKillControl;
  if (key == 'lift') return liftControl;
  if (key == 'serve_high') return serveControl;
  if (key == 'defence' || key == 'serve_short') return backhandControl;
  return shortControl;
}

const netKillControl = MuscleRoleProfile(
  ['前臂與手指控制肌群'],
  ['三角肌', '肘部屈伸相關肌群'],
  ['肩袖肌群', '核心肌群', '臀肌、股四頭肌'],
  {MuscleRegion.forearms},
  {MuscleRegion.shoulders, MuscleRegion.upperArms},
  {
    MuscleRegion.shoulders,
    MuscleRegion.core,
    MuscleRegion.glutes,
    MuscleRegion.quadriceps,
  },
  '跨步腿與軀幹支撐，肩帶穩定伸拍；觸球附近前臂配合手指短促收緊、向前下壓，隨後放鬆收拍。不全程繃緊或單靠手腕甩。',
);
