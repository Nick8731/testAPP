import 'package:flutter/material.dart';

import '../models/muscle_phase.dart';

class MusclePhaseCard extends StatelessWidget {
  final MusclePhase phase;
  final int number;
  final bool selected;
  final VoidCallback onTap;

  const MusclePhaseCard({
    super.key,
    required this.phase,
    required this.number,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    width: 126,
    margin: const EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFF123524) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: selected ? const Color(0xFF123524) : const Color(0xFFDDE5DD),
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$number',
              style: TextStyle(
                color: selected ? Colors.white60 : const Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              phase.phaseName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '點選定位示範',
              style: TextStyle(
                color: selected ? Colors.white60 : Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
