import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/feedback_provider.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/models/get_review_response.dart';
import 'package:sumarg/utils/app_theme.dart';

class BusDetailsScreen extends StatefulWidget {
  final TripData busData;

  const BusDetailsScreen({super.key, required this.busData});

  @override
  State<BusDetailsScreen> createState() => _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<FeedbackProvider>(context, listen: false);
      provider.clearFeedback();
      provider.fetchFeedback(
        fleetId: widget.busData.busDetail.id,
        forceRefresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final busData = widget.busData;
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),

            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bus Info Card
                    _buildBusInfoCard(busData),
                    const SizedBox(height: 24),

                    // Amenities Section
                    if (busData.busDetail.amenities.isNotEmpty) ...[
                      _buildAmenitiesSection(busData),
                      const SizedBox(height: 24),
                    ],

                    // Rating Summary + Reviews
                    Consumer<FeedbackProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingFeedback) {
                          return _buildLoadingState();
                        }
                        if (provider.error.isNotEmpty) {
                          return _buildErrorState(provider.error);
                        }
                        final reviews =
                            provider.currentFeedback?.data ?? [];
                        final stats =
                            provider.currentFeedback?.stats;

                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Rating Summary Card
                            _buildRatingSummary(stats, reviews.length),
                            const SizedBox(height: 24),

                            // Reviews Header
                            _buildReviewsHeader(reviews.length),
                            const SizedBox(height: 12),

                            // Reviews List
                            if (reviews.isEmpty)
                              _buildEmptyReviews()
                            else
                              ...reviews
                                  .map((r) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 12),
                                        child: _buildReviewCard(r),
                                      ))
                                  .toList(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(
            bottom: BorderSide(color: AppTheme.stroke, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Bus Details',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bus Info Card ─────────────────────────────────────────────────────────
  Widget _buildBusInfoCard(TripData busData) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.stroke, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDarkest.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Name and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          busData.busDetail.busName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${busData.busDetail.busType.toUpperCase()} • ${busData.busDetail.busNumber}',
                          style: const TextStyle(
                            color: AppTheme.accentLime,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLime.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.accentLime.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Rs. ${busData.tripFare}',
                      style: const TextStyle(
                        color: AppTheme.accentLime,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Timeline Route
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          busData.departureTime,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          busData.routeDetail.from,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          busData.routeDetail.duration,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.directions_bus_rounded,
                            color: AppTheme.accentLime, size: 20),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          busData.arrivalTime,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          busData.routeDetail.to,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bottom Date & Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        color: AppTheme.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      busData.tripDate.split('T')[0],
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentLime,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Scheduled',
                      style: TextStyle(
                          color: AppTheme.accentLime,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Amenities Section ─────────────────────────────────────────────────────
  Widget _buildAmenitiesSection(TripData busData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: busData.busDetail.amenities.map((amenity) {
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.inputBg,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppTheme.stroke, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getAmenityIcon(amenity),
                    color: AppTheme.accentLime,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amenity,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'ac':
        return Icons.ac_unit_outlined;
      case 'wifi':
        return Icons.wifi_outlined;
      case 'charging port':
        return Icons.power_outlined;
      case 'blanket':
        return Icons.bed_outlined;
      case 'water bottle':
        return Icons.water_drop_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  // ── Rating Summary Card ───────────────────────────────────────────────────
  Widget _buildRatingSummary(ReviewStats? stats, int reviewCount) {
    final avg = stats?.averageRating ?? 0.0;
    final total = stats?.totalReviews ?? reviewCount;
    final distribution = stats?.distribution ?? {};

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xE000564E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.stroke, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.25),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ratings & Reviews',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Big average number + stars
                  Column(
                    children: [
                      Text(
                        total > 0 ? avg.toStringAsFixed(1) : '—',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Star row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) {
                          final starValue = i + 1;
                          if (avg >= starValue) {
                            return const Icon(Icons.star_rounded,
                                color: AppTheme.accentLime,
                                size: 18);
                          } else if (avg >= starValue - 0.5) {
                            return const Icon(
                                Icons.star_half_rounded,
                                color: AppTheme.accentLime,
                                size: 18);
                          } else {
                            return Icon(
                                Icons.star_outline_rounded,
                                color: AppTheme.textSecondary
                                    .withOpacity(0.3),
                                size: 18);
                          }
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$total ${total == 1 ? 'review' : 'reviews'}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 24),

                  // Right: Distribution bars
                  Expanded(
                    child: Column(
                      children: List.generate(5, (i) {
                        final star = 5 - i;
                        final count = distribution[star] ?? 0;
                        final fraction =
                            total > 0 ? count / total : 0.0;
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                child: Text(
                                  '$star',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.star_rounded,
                                  color: AppTheme.accentLime,
                                  size: 12),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryDarker,
                                    borderRadius:
                                        BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: fraction,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentLime,
                                        borderRadius:
                                            BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 20,
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reviews Header ────────────────────────────────────────────────────────
  Widget _buildReviewsHeader(int count) {
    return Row(
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.stroke, width: 1),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ── Empty Reviews State ───────────────────────────────────────────────────
  Widget _buildEmptyReviews() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.inputBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.stroke, width: 1),
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              color: AppTheme.textSecondary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No reviews yet',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Be the first to share your experience',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading State ─────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.accentLime),
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────
  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppTheme.error.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: AppTheme.error.withOpacity(0.7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load reviews',
              style: TextStyle(
                color: AppTheme.error.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Review Card ───────────────────────────────────────────────────────────
  Widget _buildReviewCard(ReviewData r) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.stroke, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.accentLime.withOpacity(0.4),
                      width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: (r.user?.profilePicture != null &&
                          r.user!.profilePicture!.isNotEmpty)
                      ? NetworkImage(r.user!.profilePicture!)
                      : null,
                  backgroundColor: AppTheme.primaryDarker,
                  child: (r.user?.profilePicture == null ||
                          r.user!.profilePicture!.isEmpty)
                      ? Text(
                          (r.user?.name != null &&
                                  r.user!.name!.isNotEmpty)
                              ? r.user!.name![0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppTheme.accentLime,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),

              // Review Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.user?.name ?? 'Anonymous',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                r.createdAt ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary
                                      .withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rating badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDarker,
                            borderRadius:
                                BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.stroke),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppTheme.accentLime,
                                  size: 13),
                              const SizedBox(width: 3),
                              Text(
                                ((r.rating ?? 0).toDouble())
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if ((r.comment ?? '').isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        r.comment!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
