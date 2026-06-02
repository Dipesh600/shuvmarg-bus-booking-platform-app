import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class TicketSkeletonWidget extends StatefulWidget {
  const TicketSkeletonWidget({super.key});

  @override
  State<TicketSkeletonWidget> createState() => _TicketSkeletonWidgetState();
}

class _TicketSkeletonWidgetState extends State<TicketSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSkeletonBlock(double width, double height, {double borderRadius = 8}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.stroke.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.stroke, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Status Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.stroke, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSkeletonBlock(80, 16), // Status text
                  _buildSkeletonBlock(60, 14), // ID
                ],
              ),
            ),
            
            // Body
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Bus & Route Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route Timeline
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 16),
                        child: Column(
                          children: [
                            _buildSkeletonBlock(12, 12, borderRadius: 6),
                            Container(
                              height: 32, 
                              width: 1.5, 
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: AppTheme.stroke.withOpacity(0.3)
                            ),
                            _buildSkeletonBlock(14, 14, borderRadius: 7),
                          ],
                        ),
                      ),
                      // Locations
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSkeletonBlock(120, 20),
                            const SizedBox(height: 24),
                            _buildSkeletonBlock(100, 18),
                          ],
                        ),
                      ),
                      // Right side (Time & Bus)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildSkeletonBlock(70, 22),
                          const SizedBox(height: 8),
                          _buildSkeletonBlock(90, 14),
                          const SizedBox(height: 16),
                          _buildSkeletonBlock(80, 24, borderRadius: 8),
                        ],
                      ),
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppTheme.stroke, height: 1),
                  ),
                  
                  // Seats & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSkeletonBlock(100, 20),
                      _buildSkeletonBlock(90, 36, borderRadius: 12),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryDarker,
                border: Border(top: BorderSide(color: AppTheme.stroke, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildSkeletonBlock(double.infinity, 48, borderRadius: 16)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSkeletonBlock(double.infinity, 48, borderRadius: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildSkeletonCard();
      },
    );
  }
}
