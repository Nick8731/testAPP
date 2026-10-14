/// Foundation teaching is not an AI-analyzable badminton stroke.
const beginnerCourseName = '正反手握拍與換握';
const beginnerCourseKeywords = '入門 握拍 正拍 反拍 正手 反手 V型 V 型 拇指 虎口 換握 手指 放鬆';
const beginnerGripAssets = [
  'assets/images/beginner/forehand-grip.png',
  'assets/images/beginner/backhand-grip.png',
];

class GripLessonStep {
  final String title, scope, how, why, avoid, exercise;
  final List<String> checkpoints;
  const GripLessonStep({
    required this.title,
    required this.scope,
    required this.how,
    required this.why,
    required this.avoid,
    required this.exercise,
    required this.checkpoints,
  });
}

const gripLessonSteps = [
  GripLessonStep(
    title: '正手 V 型握拍',
    scope: '正手基本握拍的入門起點；可接續正手放網、挑球、平球與頭頂球。實際握法仍隨擊球位置微調。',
    how: '先用左手扶拍頸，右手像與拍柄握手。拇指與食指的虎口形成自然 V 型；食指與中指稍有間隔，其餘手指輕扣拍柄，手腕舒服中立。拇指沿側面自然包住，不把它長時間直頂在寬面，也不把掌心整個拍扁在拍柄後面。',
    why: '手指有活動空間，才方便控制拍面、前臂轉動與換握。不是用握力把球拍鎖在一個角度。',
    avoid: '握成整個拳頭、食指僵直、拇指壓住食指，或正手頭頂球一直用像握平底鍋的拍面朝前握法。不要為了照圖而硬扭手腕。',
    exercise: '站穩、球拍留身前，左手先扶拍頸，右手重新輕握 5 次。每次檢查手指是否有空間、拍子仍牢靠；不需要揮大力球。',
    checkpoints: ['虎口能看到自然 V 型，手指不擠成拳頭', '食指自然彎曲、與中指稍有空間', '手腕不硬折，握鬆仍不會掉拍'],
  ),
  GripLessonStep(
    title: '身前反手拇指握拍',
    scope: '本課只教身前基本反手：反手放網、挑球、短發球及部分身前擋球。後場反手高遠球、球在身後等情況，不能直接套用此握法。',
    how: '從放鬆握拍開始，手指小幅轉動拍柄，讓拇指指腹貼在拍柄較寬的背面，方向大致順著拍桿；其餘手指自然彎曲支撐，掌心留少量空間。不是把拇指關節硬打直或靠指尖猛戳。',
    why: '拇指提供短促支撐，配合前臂和手指控制身前球；「用拇指」不代表只有拇指獨自發力。',
    avoid: '把所有反手都用同一個直頂拇指握法、持續握緊、手肘貼死身體，或向身後球硬折手腕。',
    exercise: '球拍在身前，左手扶拍頸，找出拇指貼面的感覺 5 次；只做小幅向前支撐再放鬆，不做最大力量或高速甩腕。',
    checkpoints: [
      '拇指指腹支撐拍柄背面，不用指尖猛戳',
      '其餘手指仍握住球拍，掌心有活動空間',
      '知道本握法只適用本課的身前基本反手',
    ],
  ),
  GripLessonStep(
    title: '放鬆、換握與短暫收緊',
    scope: '先無球慢練，再配合身前正、反手來球。換握不是整隻手腕轉到極限，也不是把球拍鬆到會滑落。',
    how: '先放鬆手指但保留握住球拍的控制；讓拍柄在指間小幅轉動，由 V 型換到拇指支撐，再換回。手肘保留身前空間。接近觸球才短暫加強手指支撐，觸球後恢復可換握的鬆握。',
    why: '準備期能快速調整拍面，觸球附近能控制，之後又能處理下一球；不是全程用最大握力。',
    avoid: '先握死再硬扭手腕、等球到身旁才換握、握得太鬆掉拍，或把「放鬆」誤認為手臂與身體全部失去支撐。',
    exercise: '低強度做 V 型 → 拇指握法 → V 型，共 5 次；每換一次停下檢查。熟悉後請搭檔慢速指示正／反手，不必加速或拿握力器。',
    checkpoints: ['換握主要靠手指小幅轉動，不猛折手腕', '準備時可放鬆，觸球附近才短暫加強', '拍子始終握穩，收拍後能再換回'],
  ),
];
