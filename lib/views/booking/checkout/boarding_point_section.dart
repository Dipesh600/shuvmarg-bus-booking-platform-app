import 'package:flutter/material.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/color_constants.dart';

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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryDark.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.secondary, size: 20),
              const SizedBox(width: 10),
              Text(
                "Select Boarding Point",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryLight.withOpacity(0.3), width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPoint,
                isExpanded: true,
                dropdownColor: AppColors.primaryDark,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.7)),
                hint: Text(
                  'Choose a boarding stop',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
                ),
                items: boardingPoints.map((StopPoint point) {
                  return DropdownMenuItem<String>(
                    value: point.pointName,
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bus_filled, color: AppColors.primaryLight, size: 18),
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
                                  color: Colors.white,
                                ),
                              ),
                              if (point.time.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  point.time,
                                  style: TextStyle(color: AppColors.secondary.withOpacity(0.8), fontSize: 12),
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
      ),
    );
  }
}
