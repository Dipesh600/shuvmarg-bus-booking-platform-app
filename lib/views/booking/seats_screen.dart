import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/seatas_controller/seats_provider.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/models/seat_response.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/views/booking/proceeding_to_checkout.dart';
import 'package:sumarg/views/booking/seats_policy_info.dart';
import 'package:sumarg/views/booking/bus_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final TripData busData;

  const SeatSelectionScreen({super.key, required this.busData});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // ── Design tokens ────────────────────────────────────────────────────────
  static const Color _bg          = AppTheme.primaryDark;
  static const Color _primary     = AppTheme.primary;
  static const Color _accentLime  = AppTheme.accentLime;
  static const Color _textPrimary = AppTheme.textPrimary;
  static const Color _textSec     = AppTheme.textSecondary;
  static const Color _stroke      = AppTheme.stroke;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProviderAndFetchSeats();
    });
  }

  Future<void> _initProviderAndFetchSeats() async {
    final provider = Provider.of<SeatSelectionProvider>(context, listen: false);
    provider.clearSeats();
    provider.setPricePerSeat(widget.busData.tripFare);
    await provider.fetchSeats(widget.busData.id);
  }

  void _onCheckoutPressed(BuildContext context, int totalPrice) {
    HapticFeedback.mediumImpact();
    final selectedSeats =
        context.read<SeatSelectionProvider>().selectedSeats.join(", ");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProceedingToCheckout(
                  totalPrice: totalPrice,
                  selectedSeats: selectedSeats,
                  busData: widget.busData,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SeatSelectionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                
                if (provider.isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: _accentLime)))
                else if (provider.seatResponse == null || provider.seatResponse!.data == null)
                  Expanded(
                    child: Center(
                      child: Text(
                        provider.error.isNotEmpty ? provider.error : 'No seats available',
                        style: const TextStyle(fontSize: 16, color: _textSec),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        _buildBusSummaryCard(),
                        _buildLegend(),
                        const SizedBox(height: 12),
                        // Bus Layout Container
                        Expanded(child: _buildBusInterior(provider)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomCheckout(provider),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          // Glass Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.chevron_left_rounded, color: _textPrimary, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          
          // Route and Date Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.busData.routeDetail.from,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, color: _accentLime, size: 16),
                    ),
                    Flexible(
                      child: Text(
                        widget.busData.routeDetail.to,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: _accentLime, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        widget.busData.tripDate.split('T')[0],
                        style: const TextStyle(color: _textSec, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Glass Info Button
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SeatsPolicyInfo()));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _stroke, width: 1),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: _textPrimary, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating Bus Details Card ─────────────────────────────────────────────
  Widget _buildBusSummaryCard() {
    final bus = widget.busData;
    final isLowSeats = bus.availableSeats <= 10;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BusDetailsScreen(busData: bus)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xE000564E), // rgba(0, 86, 78, 0.88)
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _stroke, width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x4000564E), blurRadius: 40, offset: Offset(0, 10))
          ],
        ),
        child: Column(
          children: [
            // Row 1: Bus Name and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bus.busDetail.busName,
                    style: const TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "Rs. ${bus.tripFare}",
                  style: const TextStyle(color: _accentLime, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Row 2: Bus Type and Rating + Chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bus.busDetail.busType.toUpperCase(),
                  style: const TextStyle(color: _textSec, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: _accentLime, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      bus.busDetail.averageRating > 0 ? bus.busDetail.averageRating.toStringAsFixed(1) : 'New',
                      style: const TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, color: _textSec, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Row 3: Timeline (Departure -> Duration -> Arrival)
            Row(
              children: [
                Text(bus.departureTime, style: const TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(bus.routeDetail.duration, style: const TextStyle(color: _textSec, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _accentLime, width: 1.5))),
                            Expanded(child: Container(height: 1, color: _stroke)),
                            const Icon(Icons.arrow_forward_rounded, color: _accentLime, size: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Text(bus.arrivalTime, style: const TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            // Row 4: Amenities and Seats Left
            Row(
              children: [
                ...bus.busDetail.amenities.take(4).map((a) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(_getAmenityIcon(a), color: _textSec, size: 16),
                )),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLowSeats ? _accentLime.withOpacity(0.15) : _primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLowSeats ? _accentLime.withOpacity(0.5) : _primary.withOpacity(0.5)),
                  ),
                  child: Text(
                    "${bus.availableSeats} Seats Left",
                    style: TextStyle(
                      color: isLowSeats ? _accentLime : _textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'ac': return Icons.ac_unit_outlined;
      case 'wifi': return Icons.wifi_outlined;
      case 'charging port': return Icons.power_outlined;
      case 'blanket': return Icons.bed_outlined;
      case 'water bottle': return Icons.water_drop_outlined;
      default: return Icons.check_circle_outline;
    }
  }

  // ── Legend ────────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem("Available", color: Colors.transparent, borderColor: _accentLime),
          const SizedBox(width: 16),
          _legendItem("Selected", color: _accentLime, borderColor: _accentLime),
          const SizedBox(width: 16),
          _legendItem("Occupied", color: const Color(0xFF1E2D2B), borderColor: Colors.transparent),
        ],
      ),
    );
  }

  Widget _legendItem(String label, {required Color color, required Color borderColor}) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _textSec, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Bus Interior Layout ───────────────────────────────────────────────────
  Widget _buildBusInterior(SeatSelectionProvider provider) {
    final seatConfig = provider.seatResponse?.data?.seatConfig;

    if (seatConfig != null && seatConfig.floors.isNotEmpty) {
      return _buildDynamicBusInterior(provider, seatConfig);
    }

    // Fallback to legacy layout if no config exists
    return _buildLegacyBusInterior(provider);
  }

  Widget _buildDynamicBusInterior(SeatSelectionProvider provider, SeatConfig config) {
    final floor = config.floors.first; // Usually only 1 floor for now
    
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _primary.withOpacity(0.3), width: 2),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: floor.rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.cells.map((cell) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildDynamicCell(cell, provider),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDynamicCell(SeatCell cell, SeatSelectionProvider provider) {
    if (cell.cellType == 'AISLE') {
      return const SizedBox(height: 48); // Blank space for aisle
    } else if (cell.cellType == 'EMPTY') {
      return const SizedBox(height: 48); // Blank space for empty cell
    } else if (cell.cellType == 'DRIVER') {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.drive_eta_rounded, color: _textSec, size: 20),
      );
    } else if (cell.cellType == 'DOOR') {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.info.withOpacity(0.5), width: 1.5, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Icon(Icons.door_front_door_outlined, color: AppTheme.info, size: 20),
        ),
      );
    } else if (cell.cellType == 'SEAT' && cell.seatLabel != null) {
      final isBooked = provider.isSeatBooked(cell.seatLabel!);
      return SizedBox(
        height: 48,
        child: _buildSeatNode(cell.seatLabel!.toUpperCase(), isBooked, provider, seatType: cell.seatType),
      );
    }
    return const SizedBox(height: 48);
  }

  Widget _buildLegacyBusInterior(SeatSelectionProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          // Front of the bus (Driver)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.drive_eta_rounded, color: _textSec, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Main Seat Columns
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Seats (seata)
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: provider.seatResponse!.data!.seata.length,
                    itemBuilder: (context, index) {
                      final seat = provider.seatResponse!.data!.seata[index];
                      return _buildSeatNode(seat.seatNo.toUpperCase(), seat.booked, provider);
                    },
                  ),
                ),
                
                // Aisle Space
                const SizedBox(width: 32),
                
                // Right Seats (seatb)
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: provider.seatResponse!.data!.seatb.length,
                    itemBuilder: (context, index) {
                      final seat = provider.seatResponse!.data!.seatb[index];
                      return _buildSeatNode(seat.seatNo.toUpperCase(), seat.booked, provider);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Back Row (seatc)
          if (provider.seatResponse!.data!.seatc.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 24),
              height: 55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: provider.seatResponse!.data!.seatc.map((seat) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildSeatNode(seat.seatNo.toUpperCase(), seat.booked, provider),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ── Custom Geometric Seat ─────────────────────────────────────────────────
  Widget _buildSeatNode(String seatLabel, bool isBooked, SeatSelectionProvider provider, {String seatType = 'STANDARD'}) {
    final isSelected = provider.isSelected(seatLabel);
    
    // UI Rules: Occupied = Dark Gray, Selected = Lime, Available = Transparent + Lime border
    final bgColor = isBooked ? const Color(0xFF1E2D2B) : isSelected ? _accentLime : Colors.transparent;
    final borderColor = isBooked ? Colors.transparent : _accentLime;
    final textColor = isBooked ? _textSec.withOpacity(0.4) : isSelected ? const Color(0xFF003D38) : _accentLime;

    // Optional: Render different shapes based on seatType (SLEEPER, SOFA)
    final bool isSleeper = seatType.contains('SLEEPER');
    final double height = isSleeper ? 64.0 : 48.0;

    return GestureDetector(
      onTap: isBooked ? null : () {
        HapticFeedback.selectionClick();
        provider.toggleSeat(seatLabel);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isSleeper ? 12 : 8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          children: [
            // Seat Headrest Indicator
            Container(
              height: 6,
              margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              decoration: BoxDecoration(
                color: isBooked ? Colors.white.withOpacity(0.05) : isSelected ? const Color(0xFF003D38).withOpacity(0.2) : _accentLime.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (isSleeper) const Spacer(), // Extra space for sleeper bed representation
            Expanded(
              flex: isSleeper ? 2 : 1,
              child: Center(
                child: Text(
                  seatLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Floating Bottom Checkout Bar ──────────────────────────────────────────
  Widget _buildBottomCheckout(SeatSelectionProvider provider) {
    if (provider.isLoading || provider.seatResponse == null || provider.seatResponse!.data == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xE000564E),
        border: const Border(top: BorderSide(color: _stroke, width: 1)),
        boxShadow: [BoxShadow(color: _bg.withOpacity(0.8), blurRadius: 20, offset: const Offset(0, -10))],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              // Price Details
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.selectedSeats.isEmpty ? "Select a seat" : "${provider.selectedSeats.length} Seats",
                    style: const TextStyle(color: _textSec, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Rs. ${provider.totalPrice}",
                    style: const TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              // CTA Button
              GestureDetector(
                onTap: provider.selectedSeats.isEmpty ? null : () => _onCheckoutPressed(context, provider.totalPrice),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: provider.selectedSeats.isEmpty ? _primary : _accentLime,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: provider.selectedSeats.isNotEmpty
                        ? [BoxShadow(color: _accentLime.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(
                          color: provider.selectedSeats.isEmpty ? _textSec : const Color(0xFF003D38),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: provider.selectedSeats.isEmpty ? _textSec : const Color(0xFF003D38),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ), // Closing Padding
        ),
      ),
    );
  }
}
