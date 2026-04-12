
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sumarg/utils/color_constants.dart';

class ProfileLoading extends StatelessWidget {
  const ProfileLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Shimmer(
        color: Colors.grey[300]!,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 420,
              floating: false,
              pinned: true,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderSkeleton(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    _buildGroupSkeleton(titleWidth: 110, itemCount: 3),
                    _buildGroupSkeleton(titleWidth: 140, itemCount: 2),
                    _buildGroupSkeleton(titleWidth: 130, itemCount: 3),
                    _buildGroupSkeleton(titleWidth: 150, itemCount: 2),
                    _buildGroupSkeleton(titleWidth: 120, itemCount: 5),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _box(
                        height: 54,
                        radius: 14,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildHeaderSkeleton(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Stack(
                alignment: Alignment.center,
                children: [
                  _circle(size: 98),
                  _circle(size: 92),
                  _circle(size: 88),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: _circle(size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _box(height: 18, radius: 10, width: 160),
              const SizedBox(height: 8),
              _box(height: 12, radius: 10, width: 210),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _box(height: 12, radius: 10, width: 120),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _chipSkeleton()),
                  const SizedBox(width: 8),
                  Expanded(child: _chipSkeleton()),
                  const SizedBox(width: 8),
                  Expanded(child: _chipSkeleton()),
                ],
              ),
              const SizedBox(height: 12),
              _box(height: 54, radius: 18, width: double.infinity),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _chipSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circle(size: 30),
          const SizedBox(height: 5),
          _box(height: 14, radius: 8, width: 40),
          const SizedBox(height: 4),
          _box(height: 10, radius: 8, width: 65),
        ],
      ),
    );
  }

  static Widget _buildGroupSkeleton({
    required double titleWidth,
    required int itemCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: _box(height: 10, radius: 8, width: titleWidth),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(
                itemCount,
                (index) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          _box(height: 44, radius: 12, width: 44),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _box(height: 14, radius: 10, width: 170),
                                const SizedBox(height: 6),
                                _box(height: 12, radius: 10, width: 220),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _box(height: 14, radius: 6, width: 14),
                        ],
                      ),
                    ),
                    if (index != itemCount - 1)
                      Divider(height: 1, color: Colors.grey[200]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  static Widget _box({
    required double height,
    required double radius,
    required double width,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
