import '../test/test_skill.dart';
import 'skill_data.dart';

/// Teaching-only additions must NOT silently enter the existing AI selector.
const trainingSkills = <BadmintonSkill>[
  ...badmintonSkills,
  BadmintonSkill(
    name: '推球',
    englishName: 'Forehand Push Shot',
    level: '基礎',
    category: '前場',
    videoPath: '',
    description: '前場來球可在身前控制時，以穩定拍面短促推向對方中場空檔；不是撲殺、放網或挑高。',
    steps: ['拍在身前', '右腳迎球', '短促平推', '快收回位'],
    muscles: ['前臂肌群', '核心肌群', '下肢肌群'],
    mistakes: ['大幅後引', '把推球打成下壓撲殺', '只甩手腕或全程握死'],
    corrections: ['球拍提早在前', '右腳可控跨步', '拍面穩定並縮短揮拍'],
    phases: [],
  ),
  BadmintonSkill(
    name: '撲球',
    englishName: 'Forehand Net Kill',
    level: '基礎',
    category: '前場',
    videoPath: '',
    description: '網前來球高於網帶且有空間時，以短促動作下壓；低球改放網或挑球。',
    steps: ['拍高判斷', '右腳迎球', '手指短促下壓', '收拍推回'],
    muscles: ['前臂肌群', '核心肌群', '下肢肌群'],
    mistakes: ['低球硬撲', '大幅掄拍碰網', '全程握死拍柄'],
    corrections: ['確認高於網帶', '右腳可控跨步', '觸球才短暫收緊手指'],
    phases: [],
  ),
  BadmintonSkill(
    name: '反手短發球',
    englishName: 'Backhand Low Serve',
    level: '基礎',
    category: '發球',
    videoPath: '',
    description: '低弧線發到對角接發球區前端，先求穩定合法，再求貼網。',
    steps: ['站穩握拍', '持球對拍', '短促前送', '準備接下一球'],
    muscles: ['前臂肌群', '核心肌群'],
    mistakes: ['發到直線區域', '大幅甩拍', '發球時移動腳步'],
    corrections: ['對角發球', '小幅前送', '雙腳保持接觸地面'],
    phases: [],
  ),
  BadmintonSkill(
    name: '正手高遠發球',
    englishName: 'Forehand High Serve',
    level: '基礎',
    category: '發球',
    videoPath: '',
    description: '以低點下手擊球發向對角後場，常作為單打入門發球。',
    steps: ['側身持球', '下引準備', '低點向上送', '隨揮準備'],
    muscles: ['前臂肌群', '核心肌群', '下肢肌群'],
    mistakes: ['把發球當頭頂高遠球', '只求高而不夠深', '發到錯誤半場'],
    corrections: ['下手低點擊球', '練習高度與深度', '對角發球'],
    phases: [],
  ),
];

class TrainingGroup {
  final String name, hint;
  final List<String> skills;
  const TrainingGroup(this.name, this.hint, this.skills);
}

const trainingGroups = [
  TrainingGroup('入門與步法', '先學正反手握拍與換握，再練啟動', ['啟動步']),
  TrainingGroup('發球', '開始一分：短發球與高遠發球', ['反手短發球', '正手高遠發球']),
  TrainingGroup('後場', '打深、下壓、調動前場', ['高遠球', '殺球', '吊球', '切球']),
  TrainingGroup('前場', '依來球高度與空檔選放網、挑球、推球或撲球', ['放網', '挑球', '推球', '撲球']),
  TrainingGroup('中場', '快節奏對抽：短引拍、快收拍', ['平球']),
  TrainingGroup('防守', '面對下壓球，先穩定擋回', ['接殺']),
];

class TrainingProblem {
  final String title, explanation;
  final List<String> skills;
  const TrainingProblem(this.title, this.explanation, this.skills);
}

const trainingProblems = [
  TrainingProblem('球打不遠／常落半場', '先檢查到位、觸球是否在身後，以及是否只靠手臂。', [
    '高遠球',
    '挑球',
    '正手高遠發球',
  ]),
  TrainingProblem('吊球太長／切球不穩', '先分清一般吊球與斜向擦擊，再看高點觸球、拍面控制。', ['吊球', '切球']),
  TrainingProblem('殺球不夠往下／打完失衡', '先看到位與前上方觸球，再看自然減速，不先追求大力。', ['殺球', '高遠球']),
  TrainingProblem('網前一直掛網／挑球不到後場', '先看跨步距離與拍面；放網和挑球的出球目的不同。', ['放網', '挑球']),
  TrainingProblem('網前只能放短／推球太高', '先讓球拍提早到身前，穩定拍面並縮短揮拍，把球推向對方中場空檔。', [
    '推球',
    '放網',
  ]),
  TrainingProblem('對抽、接殺總是來不及', '先檢查拍是否在前、引拍是否太大及有沒有快收拍。', ['平球', '接殺', '啟動步']),
  TrainingProblem('發球太高／發錯位置', '看對角發球區、低點觸球和短促前送，不靠大甩手腕。', ['反手短發球', '正手高遠發球']),
  TrainingProblem('起步慢／一直追著球跑', '觀察對手，練小幅卸重、彈性落地與向球啟動。', ['啟動步']),
  TrainingProblem('網前高球打不下／撲球碰網', '先確認球高於網帶且在我方可觸球空間；動作短，低球改放網或挑球。', [
    '撲球',
    '放網',
    '挑球',
  ]),
];

TrainingGroup groupFor(String name) =>
    trainingGroups.firstWhere((g) => g.skills.contains(name));
