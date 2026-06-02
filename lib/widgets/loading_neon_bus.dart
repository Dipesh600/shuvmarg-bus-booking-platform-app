import 'package:flutter/material.dart';
import 'package:sumarg/utils/app_theme.dart';

class LoadingNeonBus extends StatefulWidget {
  final bool isLoading;
  final String title;
  final String subtitle;

  const LoadingNeonBus({
    super.key,
    this.isLoading = true,
    this.title = "Searching for buses...",
    this.subtitle = "Please wait while we find the best buses for you.",
  });

  @override
  State<LoadingNeonBus> createState() => _LoadingNeonBusState();
}

class _LoadingNeonBusState extends State<LoadingNeonBus>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated bus icon — no image dependency
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentLime
                      .withOpacity(0.08 * _pulseAnim.value),
                  border: Border.all(
                    color: AppTheme.accentLime
                        .withOpacity(0.3 * _pulseAnim.value),
                    width: 2,
                  ),
                  boxShadow: widget.isLoading
                      ? [
                          BoxShadow(
                            color: AppTheme.accentLime
                                .withOpacity(0.15 * _pulseAnim.value),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: child,
              );
            },
            child: const Icon(
              Icons.directions_bus_rounded,
              size: 52,
              color: AppTheme.accentLime,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            widget.title,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Animated dots (only when loading)
          if (widget.isLoading) ...[
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final double offset = index * 0.22;
                    final double value = (_controller.value - offset) % 1.0;
                    final double opacity =
                        value < 0 ? 0.3 : (1 - value).clamp(0.3, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppTheme.accentLime.withOpacity(opacity),
                        shape: BoxShape.circle,
                        boxShadow: opacity > 0.6
                            ? [
                                BoxShadow(
                                  color:
                                      AppTheme.accentLime.withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
