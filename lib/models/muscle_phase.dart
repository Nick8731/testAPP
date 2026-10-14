enum MuscleRegion {
  shoulders,
  chest,
  upperBack,
  upperArms,
  forearms,
  core,
  glutes,
  quadriceps,
  hamstrings,
  calves,
}

class MusclePhase {
  final String phaseName;
  final double startSecond;
  final double endSecond;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> stabilizingMuscles;
  final Set<MuscleRegion> primaryRegions;
  final Set<MuscleRegion> secondaryRegions;
  final Set<MuscleRegion> stabilizingRegions;
  final String forceDescription;
  final List<String> mistakes;

  /// Stable tags reserved for a future AI issue-to-muscle recommendation map.
  final List<String> aiIssueTags;

  const MusclePhase({
    required this.phaseName,
    required this.startSecond,
    required this.endSecond,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.stabilizingMuscles,
    required this.primaryRegions,
    required this.secondaryRegions,
    required this.stabilizingRegions,
    required this.forceDescription,
    required this.mistakes,
    this.aiIssueTags = const [],
  });

  bool containsSecond(double second) =>
      second >= startSecond && second < endSecond;
}

class MusclePhaseOffset {
  final int phaseIndex;
  final double startOffset;
  final double endOffset;

  const MusclePhaseOffset({
    required this.phaseIndex,
    required this.startOffset,
    required this.endOffset,
  });
}

class MuscleTimelineMatch {
  final int phaseIndex;
  final double? startSecond;
  final double? endSecond;

  const MuscleTimelineMatch({
    required this.phaseIndex,
    this.startSecond,
    this.endSecond,
  });

  bool get hasVideoRange => startSecond != null && endSecond != null;
}

class MuscleSkillData {
  final String skillName;
  final String englishName;
  final String videoPath;
  final String overview;
  final List<String> forceChain;
  final List<MusclePhase> phases;
  final List<double> contactSeconds;
  final List<MusclePhaseOffset> phaseOffsets;

  const MuscleSkillData({
    required this.skillName,
    required this.englishName,
    required this.videoPath,
    required this.overview,
    required this.forceChain,
    required this.phases,
    this.contactSeconds = const [],
    this.phaseOffsets = const [],
  });

  bool get isAvailable => phases.isNotEmpty;

  MuscleTimelineMatch timelineMatchAt(double second) {
    for (final contactSecond in contactSeconds) {
      for (final offset in phaseOffsets) {
        final start = contactSecond + offset.startOffset;
        final end = contactSecond + offset.endOffset;
        if (second >= start && second < end) {
          return MuscleTimelineMatch(
            phaseIndex: offset.phaseIndex,
            startSecond: start,
            endSecond: end,
          );
        }
      }
    }

    // Intro, walking, shuttle collection and gaps between repetitions are all
    // preparation rather than an inferred swing phase.
    return const MuscleTimelineMatch(phaseIndex: 0);
  }

  MuscleTimelineMatch? nextMatchForPhase(int phaseIndex, double currentSecond) {
    final matches = <MuscleTimelineMatch>[];
    for (final contactSecond in contactSeconds) {
      for (final offset in phaseOffsets) {
        if (offset.phaseIndex != phaseIndex) continue;
        matches.add(
          MuscleTimelineMatch(
            phaseIndex: phaseIndex,
            startSecond: contactSecond + offset.startOffset,
            endSecond: contactSecond + offset.endOffset,
          ),
        );
      }
    }
    if (matches.isEmpty) return null;
    return matches.firstWhere(
      (match) => match.startSecond! >= currentSecond - 0.05,
      orElse: () => matches.first,
    );
  }
}
