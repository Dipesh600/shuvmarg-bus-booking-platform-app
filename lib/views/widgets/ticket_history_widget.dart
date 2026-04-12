import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../utils/color_constants.dart';
import '../../models/ticket_history_response.dart';
import '../../models/trip_data.dart';
import '../../views/review_screen.dart';
import '../ticket_detail_screen.dart';

class TicketHistoryWidget extends StatefulWidget {
  final List<TicketHistoryData> ticketHistoryData;

  const TicketHistoryWidget({
    super.key,
    required this.ticketHistoryData,
  });

  @override
  State<TicketHistoryWidget> createState() =>
      _TicketHistoryWidgetState();
}

class _TicketHistoryWidgetState extends State<TicketHistoryWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TripData> _allTrips = [];
  final List<TripData> _upcomingTrips = [];
  final List<TripData> _completedTrips = [];
  final List<TripData> _cancelledTrips = [];

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

  /// Parse ticket date from various formats
  DateTime? _parseTicketDate(String dateString) {
    try {
      // Remove any extra whitespace
      dateString = dateString.trim();

      if (dateString.contains('-')) {
        // Format: 2025-10-05 or 2025-9-28
        final dateParts = dateString.split('-');
        if (dateParts.length == 3) {
          return DateTime(
            int.parse(dateParts[0]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[2]), // day
          );
        }
      } else if (dateString.contains('/')) {
        // Format: 05/10/2025 or 28/09/2025
        final dateParts = dateString.split('/');
        if (dateParts.length == 3) {
          return DateTime(
            int.parse(dateParts[2]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[0]), // day
          );
        }
      }
    } catch (e) {
      print('Error parsing ticket date: $dateString, error: $e');
    }
    return null;
  }

  Future<void> _initializeData() async {
    await _convertApiDataToTripData();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _convertApiDataToTripData() async {
    _allTrips.clear();
    _upcomingTrips.clear();
    _completedTrips.clear();
    _cancelledTrips.clear();

    // Get passenger name from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final passengerName = prefs.getString('name') ?? 'Passenger';

    // Get current device date
    final currentDate = DateTime.now();
    final todayStart = DateTime(
        currentDate.year, currentDate.month, currentDate.day);

    for (var ticketData in widget.ticketHistoryData) {
      final booking = ticketData.booking;
      final trip = ticketData.trip;
      
      // Parse ticket date using helper method
      final ticketDate = trip != null ? _parseTicketDate(trip.tripDate) : null;

      // Determine status based on date comparison and booking status
      String status;
      
      // First check if it's cancelled or refunded
      if (booking.status.toLowerCase() == 'cancelled' ||
          booking.status.toLowerCase() == 'canceled' ||
          booking.refundStatus.toLowerCase() == 'refunded') {
        status = 'cancelled';
      }
      // Then check date-based logic for non-cancelled tickets
      else if (ticketDate != null) {
        if (ticketDate.isAfter(todayStart)) {
          status = 'upcoming';
        } else {
          status = 'completed';
        }
      }
      else {
        if (booking.status.toLowerCase() == 'completed') {
          status = 'completed';
        } else {
          status = 'upcoming';
        }
      }

      // Create TripData from API data
      final tripData = TripData(
        tripId: trip?.id ?? booking.ticketId,
        busNumber: trip?.busId.busNumber ?? 'N/A',
        from: trip?.routeDetail.from ?? 'N/A',
        to: trip?.routeDetail.to ?? 'N/A',
        date: trip?.tripDate ?? 'N/A',
        time: trip?.departureTime ?? 'N/A',
        status: status,
        operatorName: trip?.busId.busName ?? 'N/A',
        seats: booking.seats,
        price: booking.totalAmount.toDouble(),
        bookingId: booking.bookingId.isNotEmpty ? booking.bookingId : booking.id,
        ticketId: booking.ticketId,
        review: booking.review,
        passengerName: passengerName,
      );

      _allTrips.add(tripData);

      // Filter by status
      switch (status) {
        case 'upcoming':
          _upcomingTrips.add(tripData);
          break;
        case 'completed':
          _completedTrips.add(tripData);
          break;
        case 'cancelled':
          _cancelledTrips.add(tripData);
          break;
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Future<void> _generateAndDownloadPDF(TripData trip) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Generate QR code data
      final qrData = '${trip.ticketId}_${trip.tripId}';

      // Create QR code image
      final qrImage = await QrPainter(
        data: qrData,
        version: QrVersions.auto,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      ).toImageData(200);

      // Convert QR image to PDF image
      final qrPdfImage =
          pw.MemoryImage(qrImage!.buffer.asUint8List());

      // Add PDF page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(20),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue,
                      borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(10)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BUS TICKET',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Ticket ID: ${trip.ticketId}',
                          style: const pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Trip Details
                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                      borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Trip Details',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 15),

                        // Bus Info
                        pw.Row(
                          children: [
                            pw.Text(
                              'Bus Number: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(trip.busNumber),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Operator: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(trip.operatorName),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Status: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(trip.status.toUpperCase()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Route Details
                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                      borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Route Information',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Row(
                          children: [
                            pw.Text(
                              'From: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(trip.from),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Text(
                              'To: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(trip.to),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Date: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(trip.date),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Time: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(trip.time),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Booking Details
                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                      borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Booking Information',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Seats: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(trip.seats.join(', ')),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Price: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(
                                'Rs. ${trip.price.toStringAsFixed(0)}'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // QR Code
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Scan QR Code to Verify Ticket',
                          style: const pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Image(qrPdfImage, width: 150, height: 150),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Footer
                  pw.Center(
                    child: pw.Text(
                      'Generated on ${DateTime.now().toString().split('.')[0]}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save PDF to device
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/ticket_${trip.ticketId}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket PDF saved to: ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: AppColors.primary,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.white,
            indicatorWeight: 3,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          color: AppColors.primaryLightest,
          child: Text(
            '$title (${trips.length})',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        // Trip list
        Expanded(
          child: trips.isEmpty
              ? _buildEmptyState(title)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(trip.status),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.busNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trip.operatorName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Passenger: ${trip.passengerName}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ticket Status
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 12, vertical: 6),
                //   decoration: BoxDecoration(
                //     color: _getStatusColor(trip.status),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Icon(
                //         _getStatusIcon(trip.status),
                //         color: AppColors.white,
                //         size: 16,
                //       ),
                //       const SizedBox(width: 4),
                //       Text(
                //         _getStatusText(trip.status),
                //         style: const TextStyle(
                //           color: AppColors.white,
                //           fontWeight: FontWeight.bold,
                //           fontSize: 12,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),

          // Trip details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Route info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                trip.from,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                trip.to,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          trip.date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          trip.time,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Trip details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_seat,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          trip.seats.length == 1
                              ? 'Seat ${trip.seats.first}'
                              : 'Seats ${trip.seats.join(', ')}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${trip.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.receipt,
                        color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Ticket ID: ${trip.ticketId}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: trip.status == 'cancelled'
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketDetailScreen(
                                  tripData: trip,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side:
                                const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Canceled'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.red,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketDetailScreen(
                                  tripData: trip,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      if (trip.status == 'completed' && trip.review == false) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
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
                                      status: trip.status,
                                      operatorName: trip.operatorName,
                                      seats: trip.seats,
                                      price: trip.price,
                                      ticketId: trip.ticketId,
                                      passengerName: trip.passengerName,
                                      bookingId: trip.bookingId,
                                      review: trip.review,
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.star_border, size: 16),
                            label: const Text('Add Review'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.bus,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No $title',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your trips will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.5),
            ),
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
