import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';

class RunningStatusWidget extends StatefulWidget {
  const RunningStatusWidget({super.key});

  @override
  State<RunningStatusWidget> createState() => _RunningStatusWidgetState();
}

class _RunningStatusWidgetState extends State<RunningStatusWidget> {
  // Navigation internal state mock
  bool _hasActiveJourney = false;
  
  // Tab toggle state
  bool _isRouteSearch = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _hasActiveJourney ? _buildActiveTrackingMode() : _buildSearchMode(),
    );
  }

  // ==========================================
  // MODE 1: UNBOOKED (SEARCH PNR)
  // ==========================================
  Widget _buildSearchMode() {
    return Container(
      key: const ValueKey('SearchMode'),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.radar,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Track Journey",
                        style: TextStyle(
                          color: AppColors.primaryDarkest,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "LIVE",
                        style: TextStyle(
                          color: AppColors.primaryDarkest,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Internal Layout Toggle (PNR vs Route)
          Container(
            height: 36,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRouteSearch = false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: !_isRouteSearch ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_isRouteSearch ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Search by PNR",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !_isRouteSearch ? AppColors.primaryDarkest : Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRouteSearch = true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isRouteSearch ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isRouteSearch ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Search by Route",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isRouteSearch ? AppColors.primaryDarkest : Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Dynamic Input Switcher based on Toggle State
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isRouteSearch
                ? _buildRouteInputForm()
                : _buildPNRInputForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildPNRInputForm() {
    return Container(
      key: const ValueKey('PNRForm'),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter PNR or Bus No.",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4),
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Track",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRouteInputForm() {
    return Container(
      key: const ValueKey('RouteForm'),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "From (ex. KTM)",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "To (ex. PKR)",
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(4),
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Icon(Icons.arrow_forward, size: 20),
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // MODE 2: ACTIVE JOURNEY (RUNNING STATUS)
  // ==========================================
  Widget _buildActiveTrackingMode() {
    return Container(
      key: const ValueKey('ActiveMode'),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const Text(
                  "Check Running Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigator hooks here
                },
                child: const Text(
                  "VIEW ALL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white70,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // The Live Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top tag row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "LIVE TRACKING",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        )
                      ],
                    ),
                    const Text(
                      "BV-402",
                      style: TextStyle(
                        color: AppColors.primaryDarkest,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                
                // Timeline Graphics
                Row(
                  children: [
                    // Start Time
                    const Text(
                      "09:00",
                      style: TextStyle(
                        color: AppColors.primaryDarkest,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Connected Line
                    Expanded(
                      child: Container(
                        height: 2,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    
                    // Bus Node
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    
                    // Connected Line 2
                    Expanded(
                      child: Container(
                        height: 2,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // End Time
                    const Text(
                      "14:30",
                      style: TextStyle(
                        color: AppColors.primaryDarkest,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Stations texts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "EV STATION",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "MISTY PEAKS",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                const SizedBox(height: 16),
                
                // Footer Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Currently near ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        children: const [
                          TextSpan(
                            text: "Cedar Ridge",
                            style: TextStyle(
                              color: AppColors.primaryDarkest,
                              fontWeight: FontWeight.bold,
                            )
                          )
                        ]
                      )
                    ),
                    const Text(
                      "Delayed 10m",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
