/// Original teaching cues, not a calibrated pose/grip model or mastery score.
class IllustratedStep {
  final String title, how, why, avoid;
  const IllustratedStep(this.title, this.how, this.why, this.avoid);
}

class IllustratedLesson {
  final String skillName, key, variant, goal, drill, prerequisite;
  final List<IllustratedStep> steps;
  final List<String> checks, sources;
  const IllustratedLesson({
    required this.skillName,
    required this.key,
    required this.variant,
    required this.goal,
    required this.drill,
    required this.prerequisite,
    required this.steps,
    required this.checks,
    required this.sources,
  });
  String assetAt(int index) => key == 'clear' && index == 3
      ? 'assets/images/lessons/clear/contact-v2.png'
      : key == 'drive'
      ? 'assets/images/drive/${['ready', 'backswing-v2', 'contact-v2', 'recovery'][index]}.png'
      : key == 'defence' ||
            key == 'serve_short' ||
            ((key == 'lift' || key == 'net') && (index == 1 || index == 2))
      ? 'assets/images/lessons/$key/step_${index + 1}-v2.png'
      : 'assets/images/lessons/$key/step_${index + 1}.png';
}

const bwfLessonSource = 'BWF Shuttle Time 教師手冊（動作順序與用途）';
const bwfLessonUrl =
    'https://www.badminton.org.au/wp-content/uploads/2022/11/1.-BWF-ST-Teachers-Manual_Inclusivity_ENGLISH.pdf';
const illustratedLessons = <IllustratedLesson>[
  IllustratedLesson(
    skillName: '撲球',
    key: 'net_kill',
    variant: '右手正手・網前高球短促下壓',
    goal: '搶到高於網帶的球，在我方空間短促下壓。球低時選放網或挑球，不勉強硬撲。',
    prerequisite: '先會放鬆握拍及右腳跨步；本課不教貼網刷撲、反手撲球或後場殺球。',
    drill: '先無球慢做四步 5 次；搭檔從網前輕餵明顯高於網帶的球，短促撲向空前場 5 球，再交替餵低球，練改放網或挑球。搭檔避開下壓路線，先求不碰網、不失衡。',
    steps: [
      IllustratedStep(
        '拍高判斷',
        '拍頭在身前抬起、肩頸放鬆；先判斷球高於網帶且已到我方可觸球空間。',
        '提早舉拍，才能用短動作抓住高球機會。',
        '不要看到網前球就硬撲；低於網帶改放網或挑球。',
      ),
      IllustratedStep(
        '右腳迎球',
        '右腳（持拍側）向前可控跨步，左腳留後，右膝沿腳尖；左手自然張開平衡，握拍仍放鬆。',
        '穩定的跨步讓拍面提早到位，不靠身體撞向網。',
        '不要跨左腳示範，也不要過大跨步、膝內扣或把拍子引到頭後。',
      ),
      IllustratedStep(
        '手指短促下壓',
        '在身前、網帶上方觸球；小幅前臂帶拍配合手指瞬間收緊拍柄，拍面控制向前下方，右腳穩定支撐。',
        '手指的握放產生短促加速，無需大掄臂；不是用食指單獨指球或硬壓手腕。',
        '初次觸球必須在我方；不可碰網。球太貼網、沒有安全揮拍空間時不硬撲。',
      ),
      IllustratedStep(
        '收拍推回',
        '短隨揮後恢復放鬆，拍回身前；右腳推地回到能接下一拍的位置，觀察對手。',
        '撲球不保證得分，仍需保持平衡並準備回球。',
        '不要長隨揮撞網、全程握死或撲完站著不動。',
      ),
    ],
    checks: ['球高於網帶才撲', '右腳在前、膝沿腳尖', '觸球才短暫收緊手指', '不碰網、能推回'],
    sources: [
      'Badminton Insight：How To Play A Net Kill In Badminton',
      bwfLessonSource,
      'BWF 發球與觸網／越網規則（依適用版本）',
    ],
  ),
  IllustratedLesson(
    skillName: '高遠球',
    key: 'clear',
    variant: '右手正手・後場高遠球',
    goal: '把球送到對方後場，給自己時間重新站穩。先學穩定與深度，再追求速度。',
    prerequisite: '先會放鬆的正手握拍及側身站位；本課不教跳躍擊球。',
    drill: '無球慢速串起六步，做 5 次。有人餵球時先原地打高、打深，不要一開始就全場跑動。',
    steps: [
      IllustratedStep(
        '準備到位',
        '提早移到球後方，右腳稍後，膝蓋有彈性，球拍在身前。',
        '先有支撐，才有空間向上舒展完成高遠球。',
        '不要等球落到背後才開始移動。',
      ),
      IllustratedStep(
        '側身架拍',
        '雙腳約與肩同寬，側身略前後錯開，膝微彎；左手追球，右肘舒服抬起，球拍後引。',
        '建立連續揮拍的空間，也幫助身體平衡。',
        '不要站成大跨步、聳肩、握死球拍或用腰硬折向後。',
      ),
      IllustratedStep(
        '轉體帶拍',
        '由腳步重心轉移配合髖、軀幹轉向，手肘帶動上臂向前上方。',
        '讓身體與手臂協調，而非只靠手臂硬推。',
        '不要先把全身繃緊，也不要猛甩手腕。',
      ),
      IllustratedStep(
        '高點擊球',
        '在持拍肩上方、能舒展向上觸到的高點擊球；高遠球不刻意像殺球往前探。伸肘配合前臂旋轉，觸球附近短暫收緊手指。',
        '持拍肩上方的高點觸球，配合拍面與揮拍方向，較容易把球送高、送深。',
        '不要在頭後擊球；不要鎖死手肘。',
      ),
      IllustratedStep(
        '自然隨揮',
        '觸球後讓球拍順勢向前下方減速，保持軀幹與腳步穩定。',
        '順暢減速，銜接下一步而不是突然煞停。',
        '不要刻意甩到背後，或為了大幅度而失衡。',
      ),
      IllustratedStep(
        '收拍回位',
        '球拍回身前，依下一球可能的位置調整基地，留意對手。',
        '一拍結束仍要能處理下一球。',
        '不要停在原地看球，也不是每次都要跑到幾何中心。',
      ),
    ],
    checks: ['高點觸球在持拍肩上方，不刻意往前探', '揮拍連續、肩頸放鬆', '完成後能站穩並回到準備'],
    sources: [bwfLessonSource, 'Sikana 正手頭頂高遠球'],
  ),
  IllustratedLesson(
    skillName: '殺球',
    key: 'smash',
    variant: '右手正手・站姿殺球（不跳殺）',
    goal: '有充分到位時間時，將球向下打向空檔或身體；失去平衡時不要硬殺。',
    prerequisite: '先掌握高遠球、正手握拍及穩定隨揮；先控制，再增加力量。',
    drill: '無球慢速做 5 次站姿揮拍。餵球時以低強度打向中場目標區，不練連續跳殺。',
    steps: [
      IllustratedStep(
        '移到球後',
        '先移到球後方，側身、右腳稍後，確認自己站穩。',
        '留出前上方觸球空間，避免被球壓到身後。',
        '來不及到位時不要強行殺球。',
      ),
      IllustratedStep(
        '抬肘架拍',
        '雙腳約與肩同寬，側身略前後錯開、膝微彎；左手追球，右肘舒服抬起，肩頸放鬆。',
        '準備姿勢與高遠球相近，便於選擇不同球路。',
        '不要站成大跨步或把肩聳到耳朵旁。',
      ),
      IllustratedStep(
        '放鬆引拍',
        '球拍自然後引，軀幹側身，保留肩部活動空間。',
        '準備加速的行程，不是把肩膀硬拉到極限。',
        '不要過度後仰或扭腰蓄力。',
      ),
      IllustratedStep(
        '轉體加速',
        '重心轉移配合轉髖、轉體，手肘向前上方帶動揮拍。',
        '讓揮拍連貫，把速度集中到接近觸球時。',
        '不要只有手臂用力，也不要全程最大力量。',
      ),
      IllustratedStep(
        '前上方擊球',
        '在持拍肩前上方伸肘與前臂旋轉，控制拍面使球向下。',
        '擊球位置與拍面一起決定下壓方向，不靠手腕硬折。',
        '不要在身後觸球，也不要把手腕猛壓到底。',
      ),
      IllustratedStep(
        '減速隨揮',
        '球拍順勢經身前減速，腳步支撐身體，這版不需要起跳。',
        '保留平衡與接下一球的能力。',
        '不要把手臂強行煞停或繞到背後。',
      ),
      IllustratedStep(
        '立即準備',
        '收拍至身前，調整位置，準備對方的擋網或挑球。',
        '殺球不是必定得分，下一拍準備同樣重要。',
        '不要殺完就站著看結果。',
      ),
    ],
    checks: ['沒有為了大力而失衡', '擊球位置在前上方', '隨揮後立刻收拍準備'],
    sources: [bwfLessonSource, '本課將跳躍示範簡化為站姿入門'],
  ),
  IllustratedLesson(
    skillName: '平球',
    key: 'drive',
    variant: '右手正手・中場平抽',
    goal: '用短引拍、快收拍，把球平直送過網；適合中場快速對抽。',
    prerequisite: '先認識正手握拍；球太低時不要勉強平抽。',
    drill: '無球慢速做四步 5 次，再用輕球練短距離對抽。',
    steps: [
      IllustratedStep(
        '準備',
        '球拍在身前，膝蓋有彈性，觀察來球。',
        '縮短移拍時間，保留下一拍反應空間。',
        '不要拍頭垂下或站得太直。',
      ),
      IllustratedStep('短引拍', '移到來球方向，用短距離引拍。', '來球快，過大的引拍容易來不及。', '不要把球拍拉到身後。'),
      IllustratedStep(
        '向前擊球',
        '在身前以短促揮拍與前臂、手指配合送出球。',
        '控制平直球路，比一味發力更容易連續對抽。',
        '不要只用整條手臂大幅掄拍。',
      ),
      IllustratedStep(
        '收拍回位',
        '球拍迅速回到身前，恢復準備。',
        '下一拍可能立刻回來，不能停在隨揮末端。',
        '不要打完就看球。',
      ),
    ],
    checks: ['拍在身前', '引拍小', '快收拍'],
    sources: ['Sikana 正手平球'],
  ),
  IllustratedLesson(
    skillName: '挑球',
    key: 'lift',
    variant: '右手正手・前場挑高球',
    goal: '前場低點接球時，向上送到後場，爭取恢復平衡的時間。',
    prerequisite: '先練可控制的跨步與正手握拍，不要求跨很深。',
    drill: '不拿球先做小跨步、低點向前上方揮拍、推回 5 次。餵球時練落在後場的高度與深度。',
    steps: [
      IllustratedStep(
        '拍先迎球',
        '球拍在前，判斷落點，向正手前場移動。',
        '提早接近球，不必最後一刻用肩膀硬伸。',
        '不要讓球拍一直拖在身後。',
      ),
      IllustratedStep(
        '跨步下引',
        '右腳（持拍側）向前可控跨步、左腳留後；右膝與腳尖同方向，球拍伸到球下方。',
        '穩定跨步與合適距離提供低點擊球的空間。',
        '不要膝蓋向內倒，也不要靠過近擠住揮拍。',
      ),
      IllustratedStep(
        '向上送深',
        '右腳在前穩定支撐、左腳留後；握拍放鬆，前臂與手指配合向前上方送球。',
        '挑球要有高度也要有深度，不能只在網前上拋。',
        '不要單靠手腕甩動或用頭頂揮拍方式。',
      ),
      IllustratedStep(
        '推回收拍',
        '由右前腳推地恢復站位，球拍回到身前。',
        '挑球後可能面對進攻，需要重新組織防守。',
        '不要跨步後僵在網前。',
      ),
    ],
    checks: ['球拍有到球下方', '跨步能穩定推回', '球高且能送深'],
    sources: [bwfLessonSource, 'Sikana 正手下手高遠球（挑球）'],
  ),
  IllustratedLesson(
    skillName: '吊球',
    key: 'drop',
    variant: '右手正手・後場一般吊球',
    goal: '從後場把球送到對方前場，調動對手；本課先不加切球。',
    prerequisite: '先掌握正手頭頂擊球與高遠球的準備。',
    drill: '無球慢速做四步 5 次。有餵球時先用相同架拍交替打高遠球與吊球，控制前場落點。',
    steps: [
      IllustratedStep(
        '到位側身',
        '移到球後，站穩，保持與高遠球相近的準備。',
        '同一準備姿勢能保留球路選擇。',
        '不要還沒到位就伸手勾球。',
      ),
      IllustratedStep(
        '一致引拍',
        '雙腳約與肩同寬，側身略前後錯開；左手追球，右肘抬起，放鬆後引。',
        '不提早暴露要吊球，也保留高點觸球的空間。',
        '不要一開始就改成很小的推拍姿勢。',
      ),
      IllustratedStep(
        '高點控制',
        '在肩前上方接觸球，降低最後加速，控制拍面送向前場。',
        '控制速度與落點，不等於在低點用手腕勾下來。',
        '不要擊球過晚或只追求貼網而忽略過網。',
      ),
      IllustratedStep(
        '隨揮回位',
        '順勢短而自然隨揮，收拍並依球路調整位置。',
        '對手可能放網或挑球，仍要銜接下一拍。',
        '不要觸球後把拍子硬停住。',
      ),
    ],
    checks: ['準備與高遠球相近', '觸球高且在前', '能控制送到前場'],
    sources: [bwfLessonSource],
  ),
  IllustratedLesson(
    skillName: '切球',
    key: 'slice',
    variant: '右手正手・一般切吊（非反切）',
    goal: '用斜向擦擊改變球速與方向；先有穩定吊球，再加入切球。',
    prerequisite: '中階內容：先練正手高點觸球。微小拍面角度及擦擊方向需教練實際校正。',
    drill: '先無球慢速走四步 5 次。有人餵球時用低強度交替一般吊球、切吊，先求穩定過網。',
    steps: [
      IllustratedStep(
        '到位準備',
        '站到球後，保留正手頭頂擊球的空間。',
        '切球仍需良好站位，不是救球時的硬扭手腕。',
        '不要在身後強行切球。',
      ),
      IllustratedStep(
        '相同架拍',
        '雙腳約與肩同寬，側身略前後錯開，保持與高遠球、吊球相近的架拍。',
        '差異集中在接近觸球的拍面與路徑。',
        '不要為了切球提早把整個姿勢改掉。',
      ),
      IllustratedStep(
        '斜向擦擊',
        '在肩前上方讓拍面與揮拍方向形成斜向接觸，輕掃過球托。',
        '擦擊會減少直接向前的傳力，改變球路與速度。',
        '不要硬扭手腕；單張全身圖無法判定精細擦擊是否正確。',
      ),
      IllustratedStep(
        '自然回位',
        '沿原路徑自然減速，回到身前準備。',
        '需要控制而非誇張旋轉，才容易接下一拍。',
        '不要把手臂繞到背後。',
      ),
    ],
    checks: ['有穩定一般吊球基礎', '沒有硬扭手腕', '先求過網與落點穩定'],
    sources: [
      'Badminton Insight：Slice Drop Shot – 4 Steps To MASTER This Shot',
    ],
  ),
  IllustratedLesson(
    skillName: '放網',
    key: 'net',
    variant: '右手正手・直線放網',
    goal: '前場用小動作送過網，迫使對手低點回球；不是後場吊球。',
    prerequisite: '先練放鬆正手握拍、小跨步與穩定拍面。',
    drill: '先定點輕送球過網 5 次，再加入小跨步。先求能過網，不追求極貼網。',
    steps: [
      IllustratedStep(
        '持拍在前',
        '觀察來球，球拍先伸向正手前場。',
        '提早準備，能用較小動作控制。',
        '不要拍子落在身後才追球。',
      ),
      IllustratedStep(
        '穩定迎球',
        '右腳（持拍側）向前小跨步、左腳留後；右膝沿腳尖方向，拍面迎向球托。',
        '穩定的身體讓手指能做細小控制。',
        '不要過度跨步或把身體撞向網。',
      ),
      IllustratedStep(
        '輕送過網',
        '右腳在前穩定支撐、左腳留後；放鬆握拍，以很小的前送控制拍面，不做大幅上甩。',
        '放網靠速度與拍面控制，不是越用力越好。',
        '不要握死球拍；也不是把球挑到後場。',
      ),
      IllustratedStep(
        '拍高回位',
        '收拍保持在前，由右前腳推地回位，準備下一球。',
        '對手可能回放網，也可能挑球。',
        '不要留在網前等球落地。',
      ),
    ],
    checks: ['揮拍幅度小', '跨步後能推回', '能控制過網而非大幅挑高'],
    sources: [bwfLessonSource, 'Sikana 正手放網'],
  ),
  IllustratedLesson(
    skillName: '接殺',
    key: 'defence',
    variant: '右手持拍・反手擋網入門',
    goal: '用短促穩定的反手動作擋回前場；不是所有來球都只用反手。',
    prerequisite: '先會拇指握拍轉換；本課不包括正手接殺、抽回或防守挑球。',
    drill: '先慢速練準備、移拍、短擋、收拍 5 次。搭檔先輕餵，不要直接餵全力殺球。',
    steps: [
      IllustratedStep(
        '防守準備',
        '雙腳有彈性，重心適度降低，右手單手持拍在身前；左手放鬆張開於身側，觀察對手。',
        '身體與拍子都能快速調整來球方向。',
        '不要站直，也不要蹲得過低而動不了。',
      ),
      IllustratedStep(
        '轉握迎球',
        '對身前反手側來球，右手放鬆轉拇指握拍，手肘離開身體，短引拍；左手張開平衡，不碰拍柄或右手腕。',
        '拇指支撐拍柄，留出短距離擋球空間。',
        '不要所有球都勉強用反手，也不要拍面貼身。',
      ),
      IllustratedStep(
        '短促擋回',
        '右手在身前短促伸拍，穩定拍面，控制球送到前場；左手自然打開保持平衡。',
        '借來球速度控制回球，不需要大幅掄拍。',
        '不要猛甩手腕或把擋網變成用力抽球。',
      ),
      IllustratedStep(
        '快收快準備',
        '右手持拍立即回身前，左手保持自然張開，膝蓋有彈性。',
        '對方可能繼續進攻，需要連續防守。',
        '不要接到一球就站直。',
      ),
    ],
    checks: ['球拍一直在身前', '引拍與擋球幅度小', '接完仍能快速準備'],
    sources: [bwfLessonSource],
  ),
  IllustratedLesson(
    skillName: '啟動步',
    key: 'split',
    variant: '基本分腿墊步・向右啟動示例',
    goal: '配合對手擊球時機落地，再向來球方向啟動；不是越高越好。',
    prerequisite: '先確保地面止滑、周圍有空間；膝蓋不舒服時不要跳。',
    drill: '搭檔用拍手模擬擊球，做小墊步落地後向指定方向踏一步，共 5 次。不要做高跳。',
    steps: [
      IllustratedStep(
        '觀察準備',
        '球拍在前，膝蓋放鬆，觀察對手而不是固定節拍。',
        '時機來自對手動作，不能只背秒數。',
        '不要低頭看腳或完全站直。',
      ),
      IllustratedStep(
        '小幅卸重',
        '對手將擊球時做很小的墊步，雙腳只需輕微離地或卸重。',
        '為落地後的方向調整作準備，不是跳躍訓練。',
        '不要高跳或抱膝跳。',
      ),
      IllustratedStep(
        '彈性落地',
        '接近對手觸球後判斷方向，雙腳略分開，髖膝踝柔和屈曲。',
        '落地後能立即推地啟動，避免僵硬停住。',
        '不要膝蓋內扣；不要規定只能腳尖著地。',
      ),
      IllustratedStep(
        '向球啟動',
        '向右示例：左腳推地，右腳向來球方向移動，拍仍在前。',
        '墊步要銜接移動，才真正有用。',
        '不要先猜死方向或落地後停一拍。',
      ),
    ],
    checks: ['墊步小而不是高跳', '落地柔和不僵硬', '配合對手而非固定秒數'],
    sources: [bwfLessonSource, 'Badminton Insight 啟動步教學'],
  ),
  IllustratedLesson(
    skillName: '反手短發球',
    key: 'serve_short',
    variant: '右手持拍・反手短發球',
    goal: '把球以低弧線送到對角接發球區前端，先練穩定過網與正確半場。',
    prerequisite: '先會拇指握拍；確認發球區與適用發球規則。照片不是高度測量。',
    drill: '在對角接發球區放一個目標，連續發 5 球，記錄過網且落在有效發球區的數量。',
    steps: [
      IllustratedStep(
        '站穩握拍',
        '本課右腳稍前、左腳稍後，站距約肩寬；右手拇指支撐拍柄。發球開始至擊出，雙腳各有部分接觸地面且不移位；右腳在前是本課示範站姿，不是所有發球的硬性規定。',
        '穩定支撐，減少多餘動作。',
        '不要跳起發球，也不要握死拍柄。',
      ),
      IllustratedStep(
        '持球對拍',
        '左手輕持羽毛部位，球托朝向身前拍面；球拍只短距離後移。',
        '固定接觸位置，較容易用小動作送出球。',
        '不要旋轉捻球製造旋轉，也不要大幅引拍。',
      ),
      IllustratedStep(
        '短促前送',
        '左手放開球，以短促前送先擊球托，拇指短暫支撐、控制低弧線。',
        '短而穩定的前送，比大力甩拍更容易控制高度。',
        '不要向正前方半區發球；不能僅以腰高判定是否合法。',
      ),
      IllustratedStep(
        '收拍準備',
        '完成短隨揮，球拍回到身前，觀察對方接發。',
        '發球後仍要處理接發球。',
        '不要停著看球，也不要碰球前移動腳步。',
      ),
    ],
    checks: ['發到對角有效區', '動作小、沒有捻球', '發球期間雙腳保持接觸地面'],
    sources: ['Sikana 反手短發球', 'BWF 發球規則（以賽事採用版本為準）'],
  ),
  IllustratedLesson(
    skillName: '正手高遠發球',
    key: 'serve_high',
    variant: '右手正手・單打高遠發球',
    goal: '从發球區以低點下手擊球，送高、送深到對角單打後場。不是頭頂高遠球。',
    prerequisite: '先會正手握拍及對角發球區；照片不能判定發球高度是否合法。',
    drill: '對角單打後場放一個寬鬆目標區，發 5 球，先比較是否高且深，不要只看發球力量。',
    steps: [
      IllustratedStep(
        '側身持球',
        '左腳稍前、右腳稍後，站距約肩寬；右手正手握拍，左手持球於身前。',
        '準備重心轉移與低點下手揮拍。',
        '不要站成頭頂架拍，也不要大跨步。',
      ),
      IllustratedStep(
        '放鬆下引',
        '持拍手在身側下引，左手準備放球，肩頸與握拍放鬆。',
        '控制放球位置與揮拍節奏。',
        '不要把球拋高，也不要捻球。',
      ),
      IllustratedStep(
        '低點送高',
        '左手放球後，在身前低點先擊球托；重心配合前移，球拍向前上方揮動。',
        '下手揮拍形成高且深的球路，不是頭頂下壓。',
        '雙腳在發球期間保持接觸地面；不要只甩手腕。',
      ),
      IllustratedStep(
        '隨揮準備',
        '自然向前上方隨揮，站穩，球拍回身前準備接球。',
        '完成發球仍能處理下一拍。',
        '不要為了打深而過度甩腰或失衡。',
      ),
    ],
    checks: ['低點下手觸球', '對角單打有效區', '觸球前雙腳保持接觸地面'],
    sources: ['Sikana 正手高遠發球', 'BWF 發球規則（以賽事採用版本為準）'],
  ),
];

IllustratedLesson lessonFor(String skillName) =>
    illustratedLessons.firstWhere((lesson) => lesson.skillName == skillName);
