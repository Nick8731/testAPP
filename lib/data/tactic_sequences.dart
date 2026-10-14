import 'package:flutter/material.dart';

/// Horizontal court: our side x<.5, opponents x>.5; y spans court width.
/// Opponent is right-handed in the backhand-pressure example (backhand y>.5).
class TacticBeat {
  final List<Offset> start, end;
  final int hitter, receiver;
  final String caption;
  final int milliseconds;
  const TacticBeat(
    this.start,
    this.end,
    this.hitter,
    this.receiver,
    this.caption,
    this.milliseconds,
  );
  Offset get shuttleStart => start[hitter];
  Offset get shuttleEnd => end[receiver];
}

class TacticSequence {
  final String id, setup, practice, check, progression, note;
  final List<TacticBeat> beats;
  const TacticSequence(
    this.id,
    this.beats,
    this.setup,
    this.practice,
    this.check,
    this.progression,
    this.note,
  );
  bool get doubles => beats.first.start.length == 4;
}

class _Cue {
  final int hitter, receiver, milliseconds;
  final Offset target;
  final String caption;
  final Map<int, Offset> recover;
  const _Cue(
    this.hitter,
    this.receiver,
    this.target,
    this.caption, {
    this.recover = const {},
    this.milliseconds = 1800,
  });
}

TacticSequence _sequence(
  String id,
  List<Offset> initial,
  List<_Cue> cues,
  String setup,
  String practice,
  String check,
  String progression,
  String note,
) {
  var players = List<Offset>.of(initial);
  final beats = <TacticBeat>[];
  for (final cue in cues) {
    final end = List<Offset>.of(players);
    cue.recover.forEach((index, point) => end[index] = point);
    end[cue.receiver] = cue.target;
    beats.add(
      TacticBeat(
        List.unmodifiable(players),
        List.unmodifiable(end),
        cue.hitter,
        cue.receiver,
        cue.caption,
        cue.milliseconds,
      ),
    );
    players = end;
  }
  return TacticSequence(
    id,
    List.unmodifiable(beats),
    setup,
    practice,
    check,
    progression,
    note,
  );
}

final tacticSequences = <String, TacticSequence>{
  'singles-four-corners': _sequence(
    'singles-four-corners',
    [const Offset(.22, .6), const Offset(.72, .5)],
    const [
      _Cue(
        0,
        1,
        Offset(.88, .80),
        '1 高遠到對方右手反手後場；我方向可調整基地回位。',
        recover: {0: Offset(.30, .5)},
      ),
      _Cue(
        1,
        0,
        Offset(.44, .80),
        'A 回直線吊球，我方到前場迎球。',
        recover: {1: Offset(.72, .55)},
      ),
      _Cue(
        0,
        1,
        Offset(.88, .22),
        '1 從前場挑向另一後角，再恢復平衡。',
        recover: {0: Offset(.32, .55)},
      ),
      _Cue(
        1,
        0,
        Offset(.44, .22),
        'A 吊向另一前角，1 移動接球；四角不是同時四條球路。',
        recover: {1: Offset(.72, .5)},
      ),
    ],
    '兩人，一人回指定球；四角用寬鬆標記，先不追邊線。',
    '慢速走完四拍順序 4 次，交換角色；每次先站穩再餵下一球。',
    '能依來球到位，打完保持動態基地；不強制每拍踩固定中央點。',
    '穩定後由陪練隨機選前／後角，觀察再移動。',
    '固定四角只用來理解空間，實戰不死背順序；基地隨出球與對手調整。',
  ),
  'singles-rear-pressure': _sequence(
    'singles-rear-pressure',
    [const Offset(.2, .65), const Offset(.73, .5)],
    const [
      _Cue(
        0,
        1,
        Offset(.88, .8),
        '1 先打深到後場，不急著強攻。',
        recover: {0: Offset(.3, .5)},
      ),
      _Cue(
        1,
        0,
        Offset(.28, .4),
        'A 回球變短；1 確認到位與平衡。',
        recover: {1: Offset(.72, .5)},
      ),
      _Cue(
        0,
        1,
        Offset(.75, .65),
        '1 選擇下壓空檔，向較前的基地調整。',
        recover: {0: Offset(.35, .52)},
      ),
      _Cue(1, 0, Offset(.44, .65), 'A 擋網；1 觀察後再上網，不盲目衝前。'),
    ],
    '兩人；陪練交替回長球、半場球。',
    '做 6 個回合；長球維持高遠，只有到位的短球才低強度突擊。',
    '先說「長／短」再選球；突擊後能處理擋網或挑球。',
    '改成隨機長短，再加入擋網／挑球二選一。',
    '動畫只示範短球機會，不代表壓後場一定有短球；不能每次殺完都往網前衝。',
  ),
  'singles-net-control': _sequence(
    'singles-net-control',
    [const Offset(.44, .7), const Offset(.58, .7)],
    const [
      _Cue(
        0,
        1,
        Offset(.55, .7),
        '1 放網，稍回收，留出處理挑球的空間。',
        recover: {0: Offset(.39, .65)},
      ),
      _Cue(
        1,
        0,
        Offset(.16, .7),
        'A 被迫挑球；1 看清後退到球後。',
        recover: {1: Offset(.72, .5)},
      ),
      _Cue(
        0,
        1,
        Offset(.77, .35),
        '1 到位後選擇低強度下壓，而非必定重殺。',
        recover: {0: Offset(.33, .5)},
      ),
      _Cue(1, 0, Offset(.44, .35), 'A 擋到另一側網前；1 再向來球方向移動。'),
    ],
    '兩人；先做放網—挑球—後退擊球的慢速組合。',
    '4 球一組做 4 組，交換角色；先求穩定，不追求極貼網。',
    '放網後沒有貼死網，能看見來球並後退；不能等到球到身後才轉身。',
    '陪練可回放網或挑球，練判斷而非自動後退。',
    '前場基地是動態選擇，不固定要求站在短發球線；放網不保證逼出挑球。',
  ),
  'singles-defense-transition': _sequence(
    'singles-defense-transition',
    [const Offset(.25, .7), const Offset(.86, .3)],
    const [
      _Cue(
        1,
        0,
        Offset(.22, .7),
        'A 殺球；1 先穩定短擋，不勉強反抽。',
        recover: {1: Offset(.78, .35)},
      ),
      _Cue(
        0,
        1,
        Offset(.55, .7),
        '1 擋網，回到能處理下一球的基地。',
        recover: {0: Offset(.35, .6)},
      ),
      _Cue(
        1,
        0,
        Offset(.15, .3),
        'A 挑球，1 後退到位；機會仍要看回球品質。',
        recover: {1: Offset(.72, .5)},
      ),
      _Cue(
        0,
        1,
        Offset(.88, .72),
        '1 打深恢復主動；不一定立刻強攻。',
        recover: {0: Offset(.31, .5)},
      ),
    ],
    '兩人；進攻方先以低強度殺球，防守方可擋網或挑深。',
    '6 回合後交換，不用全力連殺。',
    '守住後能重新站穩，再選落點；擋網後仍準備撲球。',
    '加入隨機殺／吊，依實際來球選擇擋或挑。',
    '低點防守挑球與頭頂高遠球不同；本段是一條可能轉換，不是必勝套路。',
  ),
  'singles-backhand-pressure': _sequence(
    'singles-backhand-pressure',
    [const Offset(.2, .65), const Offset(.73, .5)],
    const [
      _Cue(0, 1, Offset(.83, .5), '1 先用中路深球試探。', recover: {0: Offset(.30, .5)}),
      _Cue(
        1,
        0,
        Offset(.19, .72),
        'A 回高遠；1 到球後準備下一拍。',
        recover: {1: Offset(.72, .5)},
      ),
      _Cue(
        0,
        1,
        Offset(.88, .8),
        '1 送到右手對手的反手後場（畫面下側）。',
        recover: {0: Offset(.31, .55)},
      ),
      _Cue(
        1,
        0,
        Offset(.44, .8),
        'A 示範回直線吊球；1 仍保留處理斜線的準備。',
        recover: {1: Offset(.72, .58)},
      ),
      _Cue(
        0,
        1,
        Offset(.56, .8),
        '1 接著放直線網前，觀察對手重心。',
        recover: {0: Offset(.39, .6)},
      ),
    ],
    '兩人，先確認對手慣用手；反手後角放一個寬鬆目標。',
    '中路—後角—網前組合做 4 次，交換角色。',
    '看對手擊球方式與平衡，不只看標記；沒有把基地過度偏向一側。',
    '陪練允許斜線回球，避免背套路。',
    '本段對手 A 是右撇子；左撇子的反手區在另一側。不是每個人反手都較弱。',
  ),
  'singles-tempo': _sequence(
    'singles-tempo',
    [const Offset(.2, .65), const Offset(.75, .5)],
    const [
      _Cue(
        0,
        1,
        Offset(.88, .65),
        '1 打較高弧線深球，增加對手處理時間。',
        recover: {0: Offset(.30, .5)},
        milliseconds: 2400,
      ),
      _Cue(
        1,
        0,
        Offset(.18, .3),
        'A 回高遠，1 保持到位。',
        recover: {1: Offset(.72, .5)},
        milliseconds: 2400,
      ),
      _Cue(
        0,
        1,
        Offset(.88, .8),
        '1 改較快深球，準備姿勢仍相近。',
        recover: {0: Offset(.31, .55)},
        milliseconds: 1300,
      ),
      _Cue(
        1,
        0,
        Offset(.2, .8),
        'A 回深，1 先到位而不為假動作延誤。',
        recover: {1: Offset(.72, .5)},
      ),
      _Cue(
        0,
        1,
        Offset(.56, .8),
        '1 控制吊到前場，改變前後與時間。',
        recover: {0: Offset(.35, .6)},
        milliseconds: 2200,
      ),
    ],
    '兩人；同一後場位置練高遠、較快深球與一般吊球。',
    '每種低強度球路 5 次，再混合 6 個回合。',
    '準備相近、到位不延誤；用高度與球路改變節奏。',
    '陪練不預先知道球路，檢查是否提早暴露。',
    '播放快慢只示相對節奏，不是實際飛行秒數；不要靠刻意長時間停拍製造變化。',
  ),
  'doubles-front-back': _sequence(
    'doubles-front-back',
    [
      const Offset(.40, .50),
      const Offset(.18, .65),
      const Offset(.75, .28),
      const Offset(.75, .72),
    ],
    const [
      _Cue(
        1,
        2,
        Offset(.74, .28),
        '2 後場下壓；1 向直線回球區微調。',
        recover: {0: Offset(.40, .28), 1: Offset(.23, .6)},
      ),
      _Cue(2, 0, Offset(.45, .28), 'A 擋網，由前場 1 接管；2 留後方。'),
      _Cue(
        0,
        2,
        Offset(.56, .28),
        '1 網前控制，2 保留後場支撐。',
        recover: {0: Offset(.41, .28), 3: Offset(.86, .55)},
      ),
      _Cue(2, 1, Offset(.16, .70), 'A 挑球，由後場 2 處理；不自動交換前後。'),
    ],
    '四人低強度定式；我方先為前後、對方先並排防守。',
    '下壓—擋網—放網—挑球 4 次後換角色。',
    '前場接短球、後場接深球；兩人不一起搶同一球。',
    '對方隨機擋兩側，前場隨球調整；只有條件合適才輪轉。',
    '前後是進攻基礎分工，不是任何球都適用；後場球員前移不表示必須輪轉。',
  ),
  'doubles-drive': _sequence(
    'doubles-drive',
    [
      const Offset(.36, .28),
      const Offset(.33, .72),
      const Offset(.67, .28),
      const Offset(.70, .72),
    ],
    const [
      _Cue(0, 2, Offset(.67, .28), '1 與 A 短引拍平抽，搭檔維持另一側覆蓋。'),
      _Cue(
        2,
        1,
        Offset(.35, .72),
        'A 變線到 2，1 收拍準備，不追球一起前衝。',
        recover: {0: Offset(.38, .35)},
      ),
      _Cue(
        1,
        3,
        Offset(.64, .72),
        '2 平抽壓迫 B，1 準備中前場短球。',
        recover: {0: Offset(.40, .5)},
      ),
      _Cue(
        3,
        1,
        Offset(.17, .70),
        'B 起高球後，2 後退擊球，1 留前場形成進攻。',
        recover: {0: Offset(.43, .5)},
      ),
    ],
    '四人，先半場慢速平抽，拍保持在身前。',
    '連續控制 8 拍算一組，先試 3 組，再加入一個高球。',
    '短引拍快收拍；對方起高後才調整成前後。',
    '可變線，但先約定中間球由誰處理。',
    '平抽是中性爭奪，不強制每拍前後站位，也不要求擊球者每次跟進。',
  ),
  'doubles-side-defense': _sequence(
    'doubles-side-defense',
    [
      const Offset(.42, .35),
      const Offset(.21, .68),
      const Offset(.65, .50),
      const Offset(.82, .65),
    ],
    const [
      _Cue(
        0,
        3,
        Offset(.88, .65),
        '1 挑深球後，1 與 2 分開成左右防守。',
        recover: {0: Offset(.27, .27), 1: Offset(.27, .73)},
      ),
      _Cue(3, 1, Offset(.25, .73), 'B 下壓由 2 接；1 覆蓋另一側與約定中路。'),
      _Cue(
        1,
        2,
        Offset(.56, .72),
        '2 擋網；球質夠好才稍跟進，1 補後方。',
        recover: {1: Offset(.38, .72), 0: Offset(.20, .35)},
      ),
      _Cue(
        2,
        0,
        Offset(.15, .35),
        'A 被迫挑球，1 接後場，2 前封；回球後才確認轉攻。',
        recover: {1: Offset(.43, .65)},
      ),
    ],
    '四人；己方挑深後轉左右，對方只做低強度下壓。',
    '挑—殺—擋—挑 4 次後換位，先慢速站位再接球。',
    '挑球後確實覆蓋左右；中間球有約定，不只由正手固定優先。',
    '加入擋球品質不佳的情境，維持防守而不勉強跟進。',
    '回平球不一定已取得進攻；對方起高或我方確實能下壓才轉前後。',
  ),
  'doubles-serve-third-shot': _sequence(
    'doubles-serve-third-shot',
    [
      const Offset(.33, .72),
      const Offset(.20, .5),
      const Offset(.69, .28),
      const Offset(.82, .55),
    ],
    const [
      _Cue(
        0,
        2,
        Offset(.67, .28),
        '1 右發球區短發到對角 A 的有效接發球區。',
        recover: {0: Offset(.37, .65)},
      ),
      _Cue(
        2,
        0,
        Offset(.44, .28),
        'A 接發放網；發球者 1 移到短球位置。',
        recover: {2: Offset(.62, .28)},
      ),
      _Cue(
        0,
        3,
        Offset(.76, .45),
        '1 第三拍推向中場，2 保留中後場覆蓋。',
        recover: {0: Offset(.4, .35), 1: Offset(.22, .45)},
      ),
    ],
    '四人，先確認合法發球區；示範偶數分右區對角發球。',
    '只打前三拍，做 6 個回合後換發球者與接發者。',
    '短發過網且落在對角有效區；第三拍分工依接發落點，不一律由發球者接。',
    '接發可放網、推中場或挑球，第三拍由最近且有空間的人處理。',
    '這是一條短發—放網—推球示例；換發球區時需換對角，接發方搭檔準備的是第四拍。',
  ),
  'doubles-rotation': _sequence(
    'doubles-rotation',
    [
      const Offset(.40, .40),
      const Offset(.18, .72),
      const Offset(.73, .72),
      const Offset(.76, .28),
    ],
    const [
      _Cue(
        1,
        2,
        Offset(.55, .72),
        '2 吊直線並喊前；1 先橫移讓出該側，再準備補後。',
        recover: {1: Offset(.40, .72), 0: Offset(.30, .30)},
      ),
      _Cue(
        2,
        0,
        Offset(.15, .30),
        'A 挑另一後角，由 1 補後場；2 留前封網。',
        recover: {1: Offset(.42, .60), 3: Offset(.75, .32)},
      ),
      _Cue(
        0,
        3,
        Offset(.72, .32),
        '新後場 1 下壓；新前場 2 覆蓋回球區。',
        recover: {0: Offset(.23, .3), 1: Offset(.42, .32)},
      ),
      _Cue(3, 1, Offset(.44, .32), 'B 擋網由 2 處理，完成有溝通的角色交換。'),
    ],
    '四人；先不拿球用兩條不同側路線走位，互相能看見。',
    '慢速吊—挑—下壓—擋網做 4 次；每次先喊前／後再移動。',
    '兩人移動路線不交叉；新前場與新後場責任清楚。',
    '由對方決定擋／挑；沒有讓位與溝通就不強行輪轉。',
    '輪轉是條件式示例，不是每次吊球自動換位；不固定順時針或逆時針。',
  ),
  'doubles-middle': _sequence(
    'doubles-middle',
    [
      const Offset(.40, .40),
      const Offset(.20, .65),
      const Offset(.74, .32),
      const Offset(.74, .68),
    ],
    const [
      _Cue(
        1,
        2,
        Offset(.74, .50),
        '2 下壓兩人之間；本例 A 明確喊我接，B 讓出空間。',
        recover: {0: Offset(.41, .5), 3: Offset(.76, .75)},
      ),
      _Cue(2, 0, Offset(.44, .5), 'A 勉強擋網，1 接前場；不期待對手一定碰拍。'),
      _Cue(
        0,
        3,
        Offset(.78, .80),
        '1 改送另一側空檔，觀察對手調整。',
        recover: {0: Offset(.40, .5)},
      ),
    ],
    '四人，防守搭檔先約定中間球責任；使用低強度球。',
    '每回合兩次中路壓迫後可變線，先做 6 回合。',
    '目標是兩人移動間的縫隙，不是固定幾何中心；不可故意製造碰撞。',
    '改變防守站距，攻方重新觀察中間區域。',
    '動畫指定 A 接中路只是本例約定；持拍側不是唯一優先條件。',
  ),
  'doubles-communication': _sequence(
    'doubles-communication',
    [
      const Offset(.27, .30),
      const Offset(.27, .70),
      const Offset(.60, .5),
      const Offset(.87, .65),
    ],
    const [
      _Cue(
        3,
        0,
        Offset(.26, .48),
        'B 殺中間，1 提早喊我，2 留另一側。',
        recover: {1: Offset(.28, .75)},
      ),
      _Cue(
        0,
        2,
        Offset(.56, .5),
        '1 擋網並提醒前；2 補後方，兩人保持視線與空間。',
        recover: {0: Offset(.40, .5), 1: Offset(.20, .7)},
      ),
      _Cue(
        2,
        1,
        Offset(.17, .7),
        'A 挑球，2 喊後接管，1 留前場。',
        recover: {0: Offset(.42, .5)},
      ),
    ],
    '四人；先約定我、你、前、後、出界等短口令。',
    '低強度 6 個回合，記錄有提早喊的次數，回合後只討論一個問題。',
    '口令在碰球前而非球落地後；搭檔不搶同一球，也不背對來球練習。',
    '取消固定回球，在可控球速下練中間球與前後補位。',
    '依來球、慣用手與站位事前約定，不用一條固定優先規則處理全部中間球。',
  ),
};
