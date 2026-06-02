import 'package:flutter/material.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─── Design Token Aliases (from AppTheme) ─────────────────────────────────────
class _DT {
  static const Color primary       = AppTheme.primary;
  static const Color primaryDark   = AppTheme.primaryDark;
  static const Color primaryDarker = AppTheme.primaryDarker;
  static const Color primaryDarkest= AppTheme.primaryDarkest;
  static const Color accentLime    = AppTheme.accentLime;
  static const Color textPrimary   = AppTheme.textPrimary;
  static const Color textSecondary = AppTheme.textSecondary;
  static const Color stroke        = AppTheme.stroke;
  static const Color cardBg        = AppTheme.cardBg;
}
// ──────────────────────────────────────────────────────────────────────────────

class BusListCommon extends StatelessWidget {
  final List<TripData> busList;
  final void Function(TripData)? onBusTap;

  const BusListCommon({super.key, required this.busList, this.onBusTap});

  @override
  Widget build(BuildContext context) {
    if (busList.isEmpty) {
      return _EmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      itemCount: busList.length,
      itemBuilder: (context, index) {
        final bus = busList[index];
        return _BusCard(
          bus: bus,
          isLast: index == busList.length - 1,
          onTap: onBusTap != null ? () => onBusTap!(bus) : null,
        );
      },
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _DT.primary.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: _DT.stroke, width: 1),
            ),
            child: const Icon(Icons.directions_bus_outlined,
                color: _DT.textSecondary, size: 34),
          ),
          const SizedBox(height: 16),
          const Text(
            'No buses available',
            style: TextStyle(
              color: _DT.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bus Card ─────────────────────────────────────────────────────────────────
class _BusCard extends StatefulWidget {
  final TripData bus;
  final bool isLast;
  final VoidCallback? onTap;

  const _BusCard({required this.bus, required this.isLast, this.onTap});

  @override
  State<_BusCard> createState() => _BusCardState();
}

class _BusCardState extends State<_BusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final bus = widget.bus;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 16),
          decoration: BoxDecoration(
            color: _DT.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _DT.stroke, width: 1),
            boxShadow: [
              BoxShadow(
                color: _DT.primary.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _TopSection(bus: bus),
              _TimelineSection(bus: bus),
              _BottomRibbon(bus: bus),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Top Section: Image + Name + Price + Type + Rating ────────────────────────
class _TopSection extends StatelessWidget {
  final TripData bus;
  const _TopSection({required this.bus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus image
          _BusImage(bus: bus),
          const SizedBox(width: 14),
          // Name + type
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bus.busDetail.busName,
                        style: const TextStyle(
                          color: _DT.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Rating / Review Short Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: _DT.accentLime, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          bus.busDetail.averageRating > 0
                              ? bus.busDetail.averageRating.toStringAsFixed(1)
                              : 'New',
                          style: const TextStyle(
                            color: _DT.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${bus.busDetail.totalReviews})',
                          style: const TextStyle(
                            color: _DT.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${bus.busDetail.vehicleType.toUpperCase()} • ${bus.busDetail.busType}',
                        style: const TextStyle(
                          color: _DT.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ── Lime Price Badge ─────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _DT.accentLime,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _DT.accentLime.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Rs. ${bus.tripFare}',
                        style: const TextStyle(
                          color: _DT.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusImage extends StatelessWidget {
  final TripData bus;
  const _BusImage({required this.bus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _DT.primaryDarker,
        border: Border.all(color: _DT.stroke, width: 1),
        image: bus.busDetail.fleetImages.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(bus.busDetail.fleetImages.first),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: bus.busDetail.fleetImages.isEmpty
          ? const Icon(Icons.directions_bus_outlined,
              color: _DT.textSecondary, size: 28)
          : null,
    );
  }
}

// ─── Timeline Section (Centered Airline-Ticket Style) ─────────────────────────
class _TimelineSection extends StatelessWidget {
  final TripData bus;
  const _TimelineSection({required this.bus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _DT.primaryDarker.withOpacity(0.55),
        border: Border.symmetric(
          horizontal: BorderSide(
              color: _DT.primary.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Left Cluster: Departure Station (Top) + Time (Bottom)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bus.routeDetail.from,
                  style: const TextStyle(
                    color: _DT.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  bus.departureTime,
                  style: const TextStyle(
                    color: _DT.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Middle Cluster: Centered line and Duration badge
          Expanded(
            flex: 4,
            child: Row(
              children: [
                // Starting Dot
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _DT.accentLime,
                    boxShadow: [
                      BoxShadow(
                        color: _DT.accentLime.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
                // Line
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _DT.accentLime.withOpacity(0.6),
                              _DT.accentLime.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                      // Centered duration badge
                      if (bus.routeDetail.duration.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _DT.primaryDarker,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _DT.stroke, width: 1),
                          ),
                          child: Text(
                            bus.routeDetail.duration,
                            style: const TextStyle(
                              color: _DT.accentLime,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Ending Arrow
                Icon(Icons.arrow_forward_rounded,
                    color: _DT.accentLime.withOpacity(0.8), size: 14),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right Cluster: Arrival Station (Top) + Time (Bottom)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bus.routeDetail.to,
                  style: const TextStyle(
                    color: _DT.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  bus.arrivalTime,
                  style: const TextStyle(
                    color: _DT.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Ribbon: Amenities + Seats ─────────────────────────────────────────
class _BottomRibbon extends StatelessWidget {
  final TripData bus;
  const _BottomRibbon({required this.bus});

  @override
  Widget build(BuildContext context) {
    final seats = bus.availableSeats;
    final isLow = seats <= 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Amenity icons (up to 4)
          ...bus.busDetail.amenities.take(4).map((a) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _amenityIcon(a),
            );
          }),
          const Spacer(),
          // Seats left pill
          _SeatsPill(seats: seats, isLow: isLow),
        ],
      ),
    );
  }

  Widget _amenityIcon(String amenity) {
    return Icon(
      _getAmenityIcon(amenity),
      color: _DT.textSecondary,
      size: 17,
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
}

class _SeatsPill extends StatelessWidget {
  final int seats;
  final bool isLow;
  const _SeatsPill({required this.seats, required this.isLow});

  @override
  Widget build(BuildContext context) {
    final color = isLow ? _DT.accentLime : _DT.primary;
    final textColor = isLow ? _DT.accentLime : _DT.textPrimary;
    final iconColor = isLow ? _DT.accentLime : _DT.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_seat_rounded, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text(
            '$seats ${isLow ? 'left!' : 'seats'}',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
