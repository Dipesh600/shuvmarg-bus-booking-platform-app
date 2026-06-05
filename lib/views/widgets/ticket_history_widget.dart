import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../../utils/app_theme.dart';
import '../../models/ticket_history_response.dart';
import '../../models/trip_data.dart';
import '../../views/review/review_screen.dart';
import '../tickets/ticket_detail_screen.dart';

class TicketHistoryWidget extends StatefulWidget {
  final List<TicketHistoryData> ticketHistoryData;

  const TicketHistoryWidget({
    super.key,
    required this.ticketHistoryData,
  });

  @override
  State<TicketHistoryWidget> createState() => _TicketHistoryWidgetState();
}

class _TicketHistoryWidgetState extends State<TicketHistoryWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TripData> _allTrips = [];
  final List<TripData> _upcomingTrips = [];
  final List<TripData> _completedTrips = [];
  final List<TripData> _cancelledTrips = [];

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  @override
  void didUpdateWidget(covariant TicketHistoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticketHistoryData != widget.ticketHistoryData) {
      _initializeData();
    }
  }

  DateTime? _parseTicketDate(String dateString) {
    try {
      // Strip any potential literal quotes or extra spaces that might break tryParse
      dateString = dateString.replaceAll('"', '').replaceAll("'", '').trim();
      debugPrint('parsing clean date string: $dateString');
      
      // Try native parse first (handles ISO 8601 like 2026-05-21T00:00:00.000Z)
      final parsed = DateTime.tryParse(dateString);
      if (parsed != null) {
        debugPrint('native parse success: $parsed');
        return parsed;
      }
      
      // Fallback for custom formats
      if (dateString.contains('-')) {
        final dateParts = dateString.split('-');
        if (dateParts.length >= 3) {
          return DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2].substring(0, 2)), // safely grab just the day digits
          );
        }
      } else if (dateString.contains('/')) {
        final dateParts = dateString.split('/');
        if (dateParts.length == 3) {
          return DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
        }
      }
    } catch (e) {
      debugPrint('Error parsing ticket date: $dateString, error: $e');
    }
    debugPrint('returning null for dateString: $dateString');
    return null;
  }

  Future<void> _initializeData() async {
    await _convertApiDataToTripData();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Future<void> _convertApiDataToTripData() async {
    final List<TripData> newAllTrips = [];
    final List<TripData> newUpcomingTrips = [];
    final List<TripData> newCompletedTrips = [];
    final List<TripData> newCancelledTrips = [];

    final prefs = await SharedPreferences.getInstance();
    final passengerName = prefs.getString('name') ?? 'Passenger';
    final currentDate = DateTime.now();
    final todayStart = DateTime(currentDate.year, currentDate.month, currentDate.day);

    for (var ticketData in widget.ticketHistoryData) {
      final booking = ticketData.booking;
      final trip = ticketData.trip;
      final ticketDate = trip != null ? _parseTicketDate(trip.tripDate) : null;
      String status;
      
      if (booking.status.toLowerCase() == 'cancelled' ||
          booking.status.toLowerCase() == 'canceled' ||
          booking.refundStatus.toLowerCase() == 'refunded') {
        status = 'cancelled';
      } else if (ticketDate != null) {
        if (ticketDate.isAfter(todayStart)) {
          status = 'upcoming';
        } else {
          status = 'completed';
        }
      } else {
        if (booking.status.toLowerCase() == 'completed') {
          status = 'completed';
        } else {
          status = 'upcoming';
        }
      }

      final tripData = TripData(
        tripId: trip?.id ?? booking.ticketId,
        busNumber: trip?.busId.busNumber ?? 'N/A',
        from: trip?.routeDetail.from ?? 'N/A',
        to: trip?.routeDetail.to ?? 'N/A',
        date: ticketDate != null ? _formatDate(ticketDate) : (trip?.tripDate ?? 'N/A'),
        time: trip?.departureTime ?? 'N/A',
        arrivalTime: trip?.arrivalTime ?? 'N/A',
        status: status,
        operatorName: trip?.busId.busName ?? 'N/A',
        seats: booking.seats,
        price: booking.totalAmount.toDouble(),
        bookingId: booking.bookingId.isNotEmpty ? booking.bookingId : booking.id,
        ticketId: booking.ticketId,
        review: booking.review,
        passengerName: passengerName,
        fleetId: trip?.busId.id ?? '',
        refundInfo: ticketData.refund,
      );

      newAllTrips.add(tripData);
      switch (status) {
        case 'upcoming': newUpcomingTrips.add(tripData); break;
        case 'completed': newCompletedTrips.add(tripData); break;
        case 'cancelled': newCancelledTrips.add(tripData); break;
      }
    }
    
    // Only update state after processing is fully complete
    _allTrips.clear();
    _allTrips.addAll(newAllTrips);
    _upcomingTrips.clear();
    _upcomingTrips.addAll(newUpcomingTrips);
    _completedTrips.clear();
    _completedTrips.addAll(newCompletedTrips);
    _cancelledTrips.clear();
    _cancelledTrips.addAll(newCancelledTrips);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming': return AppTheme.accentLime;
      case 'completed': return AppTheme.textSecondary;
      case 'cancelled': return const Color(0xFFFF4D4F);
      default: return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming': return 'Upcoming';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming': return Icons.schedule_rounded;
      case 'completed': return Icons.check_circle_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Minimal Tab Navigation
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            indicatorColor: AppTheme.accentLime,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppTheme.accentLime,
            unselectedLabelColor: AppTheme.textSecondary,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        // Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTripList(_allTrips, 'All Trips'),
              _buildTripList(_upcomingTrips, 'Upcoming Trips'),
              _buildTripList(_completedTrips, 'Completed Trips'),
              _buildTripList(_cancelledTrips, 'Cancelled Trips'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripList(List<TripData> trips, String title) {
    return Column(
      children: [
        // Header with count
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.stroke, width: 1),
                ),
                child: Text('${trips.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        // Trip list
        Expanded(
          child: trips.isEmpty
              ? _buildEmptyState(title)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return _buildTripCard(trips[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTripCard(TripData trip) {
    final statusColor = _getStatusColor(trip.status);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailScreen(tripData: trip),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.stroke, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDarkest.withOpacity(0.35),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
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
                      Row(
                        children: [
                          Icon(_getStatusIcon(trip.status), color: statusColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusText(trip.status),
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      Text('ID: ${trip.ticketId}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 12)),
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
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              children: [
                                const Icon(Icons.circle_outlined, color: AppTheme.textSecondary, size: 12),
                                Container(
                                  height: 32, 
                                  width: 1.5, 
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  color: AppTheme.stroke
                                ),
                                const Icon(Icons.location_on_outlined, color: AppTheme.accentLime, size: 14),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Locations
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trip.from, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 24),
                                Text(trip.to, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          // Right side (Time & Bus)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(trip.time, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(trip.date, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.inputBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.stroke)
                                ),
                                child: Text(trip.operatorName, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
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
                          Row(
                            children: [
                              const Icon(Icons.chair_alt_outlined, color: AppTheme.textSecondary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                trip.seats.map((s) => s.toUpperCase()).join(', '),
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryDarkest.withOpacity(0.5),
                              border: Border.all(color: AppTheme.accentLime.withOpacity(0.3), width: 1),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentLime.withOpacity(0.1),
                                  blurRadius: 8,
                                )
                              ]
                            ),
                            child: Text(
                              'Rs. ${trip.price.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppTheme.accentLime, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                _buildCardActions(trip),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardActions(TripData trip) {
    if (trip.status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: AppTheme.primaryDarker,
          border: Border(top: BorderSide(color: AppTheme.stroke, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _viewDetails(trip),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.stroke),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.cancel_rounded, size: 16),
                label: const Text('Cancelled', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error.withOpacity(0.1),
                  disabledBackgroundColor: AppTheme.error.withOpacity(0.1),
                  disabledForegroundColor: AppTheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryDarker,
        border: Border(top: BorderSide(color: AppTheme.stroke, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _viewDetails(trip),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: const BorderSide(color: AppTheme.stroke),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          if (trip.status == 'completed' && trip.review == false) ...[
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _addReview(trip),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentLime,
                  foregroundColor: AppTheme.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Add Review', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _viewDetails(TripData trip) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TicketDetailScreen(tripData: trip)));
  }

  void _addReview(TripData trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          trip: TripData(
            tripId: trip.tripId,
            busNumber: trip.busNumber,
            from: trip.from,
            to: trip.to,
            date: trip.date,
            time: trip.time,
            arrivalTime: trip.arrivalTime,
            status: trip.status,
            operatorName: trip.operatorName,
            seats: trip.seats,
            price: trip.price,
            ticketId: trip.ticketId,
            passengerName: trip.passengerName,
            bookingId: trip.bookingId,
            review: trip.review,
            fleetId: trip.fleetId,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.inputBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.stroke, width: 1),
            ),
            child: const Icon(FontAwesomeIcons.ticket, size: 40, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          Text(
            'No $title',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your trips will appear here',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
