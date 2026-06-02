import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/widgets/glass_card.dart';

class RunningStatusWidget extends StatefulWidget {
  const RunningStatusWidget({super.key});

  @override
  State<RunningStatusWidget> createState() => _RunningStatusWidgetState();
}

class _RunningStatusWidgetState extends State<RunningStatusWidget> {
  bool _isRouteSearch = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.stroke),
                      color: Colors.white.withOpacity(0.04),
                    ),
                    child: const Icon(
                      Icons.radar_outlined,
                      color: AppTheme.accentLime,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Track Journey",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Track your bus in real-time",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // "COMING SOON" badge — tracking not yet live on backend
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.stroke),
                ),
                child: const Text(
                  "SOON",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── PNR / Route Segmented Toggle ─────────────
          Container(
            height: 38,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.stroke),
            ),
            child: Row(
              children: [
                _buildTab("Search by PNR", isActive: !_isRouteSearch,
                    onTap: () => setState(() => _isRouteSearch = false)),
                _buildTab("Search by Route", isActive: _isRouteSearch,
                    onTap: () => setState(() => _isRouteSearch = true)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Animated input form ──────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: _isRouteSearch
                ? _buildRouteInputForm()
                : _buildPNRInputForm(),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // Segmented tab pill
  // ────────────────────────────────────────────────────
  Widget _buildTab(String label,
      {required bool isActive, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentLime.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isActive
                  ? AppTheme.accentLime.withOpacity(0.4)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isActive ? AppTheme.accentLime : AppTheme.textSecondary,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // PNR Input Form
  // ────────────────────────────────────────────────────
  Widget _buildPNRInputForm() {
    return Container(
      key: const ValueKey('PNRForm'),
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.stroke),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontFamily: AppTheme.fontFamily,
              ),
              decoration: InputDecoration(
                hintText: "Enter PNR or Bus Number",
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontFamily: AppTheme.fontFamily,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            child: TextButton(
              onPressed: () => FocusScope.of(context).unfocus(),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.accentLime.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                "Track",
                style: TextStyle(
                  color: AppTheme.accentLime,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // Route Input Form (From + To)
  // ────────────────────────────────────────────────────
  Widget _buildRouteInputForm() {
    return Container(
      key: const ValueKey('RouteForm'),
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.stroke),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontFamily: AppTheme.fontFamily,
              ),
              decoration: InputDecoration(
                hintText: "From (e.g. KTM)",
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontFamily: AppTheme.fontFamily,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 24,
            color: AppTheme.stroke,
          ),
          const Expanded(
            child: TextField(
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontFamily: AppTheme.fontFamily,
              ),
              decoration: InputDecoration(
                hintText: "To (e.g. PKR)",
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontFamily: AppTheme.fontFamily,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            child: TextButton(
              onPressed: () => FocusScope.of(context).unfocus(),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.accentLime.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.accentLime,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
