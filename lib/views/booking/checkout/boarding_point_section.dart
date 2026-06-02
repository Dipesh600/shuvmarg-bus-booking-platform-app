import 'package:flutter/material.dart';
import 'package:sumarg/models/trip_response.dart';
import 'dart:ui';
import 'package:sumarg/utils/app_theme.dart';

/// Boarding point selection dropdown — uses StopPoint model with time display.
class BoardingPointSection extends StatelessWidget {
  final List<StopPoint> boardingPoints;
  final String? selectedPoint;
  final ValueChanged<String?> onChanged;

  const BoardingPointSection({
    super.key,
    required this.boardingPoints,
    required this.selectedPoint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (boardingPoints.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on_rounded, color: AppTheme.accentLime, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              "Boarding Point",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 64, // Slightly taller for subtitle
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04), // Glass input background
            borderRadius: BorderRadius.circular(18), // Glass radius
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedPoint,
              isExpanded: true,
              dropdownColor: AppTheme.primaryDark,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
              hint: const Text(
                'Choose a boarding stop',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              ),
              items: boardingPoints.map((StopPoint point) {
                return DropdownMenuItem<String>(
                  value: point.pointName,
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus_filled_rounded, color: AppTheme.secondary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              point.pointName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (point.time.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                point.time,
                                style: const TextStyle(color: AppTheme.accentLime, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
