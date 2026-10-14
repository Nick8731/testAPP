/// One offline illustrated pilot. These are cues, not a calibrated motion model.
enum DrivePose { ready, backswing, contact, recovery }

class DriveLessonStep {
  final String title;
  final String cue;
  final DrivePose pose;

  const DriveLessonStep(this.title, this.cue, this.pose);
}

const driveLessonSteps = [
  DriveLessonStep('準備', '球拍放在身前，膝蓋保持彈性，觀察來球。', DrivePose.ready),
  DriveLessonStep(
    '短引拍',
    '球拍留在正手側身前，手肘與前臂小幅後收，拍頭維持迎球準備，不降到腰旁或拉到身後。',
    DrivePose.backswing,
  ),
  DriveLessonStep(
    '向前擊球',
    '手肘與前臂短促向前配合旋轉，在正手側身前迎球；本圖示範胸前來球，不是僵直手臂往前推或向上挑。',
    DrivePose.contact,
  ),
  DriveLessonStep('收拍回位', '擊球後迅速收拍，恢復準備姿勢，接下一球。', DrivePose.recovery),
];

const driveSelfChecks = [
  '準備時，球拍有保持在身體前方',
  '引拍沒有拉到身後，動作幅度保持小',
  '每次揮拍後，都有回到準備姿勢',
];

const drivePracticeInstructions =
    '先不打球，慢速做「準備 → 短引拍 → 向前揮拍 → 收拍」5 次，'
    '再檢查下面三項。先試一組就好，熟悉後可再做，最多記 3 組。';
const drivePracticeSafety = '先確認周圍有足夠空間；不要追求用力或速度。若有不適，先停止。';
const driveLessonReference =
    'https://www.sikana.tv/en/sport/badminton/how-to-hit-a-forehand-drive';
