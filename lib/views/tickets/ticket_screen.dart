import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/views/home/home_screen.dart';
import 'package:sumarg/views/search/buss_search_result_screen.dart';
import 'package:sumarg/views/widgets/ticket_card_widget.dart';
import 'package:sumarg/views/widgets/qr_code_widget.dart';
import 'dart:io';
import 'dart:ui' as ui;

class TicketScreen extends StatefulWidget {
  final String ticketId;
  final String name;
  final String role;
  final String profilePic;
  final String selectedSeats;
  final TripData busData;
  final String? scratchCardId;

  const TicketScreen({
    super.key,
    required this.ticketId,
    required this.selectedSeats,
    required this.busData,
    required this.name,
    required this.role,
    required this.profilePic,
    this.scratchCardId,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();

    // Haptic feedback for successful booking
    HapticFeedback.mediumImpact();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scratchCardId != null && widget.scratchCardId!.isNotEmpty) {
        _showScratchCardNotification();
      }
    });
  }

  void _showScratchCardNotification() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.card_giftcard, color: AppTheme.accentLime),
            const SizedBox(width: 8),
            const Text('Cashback Won!', style: TextStyle(color: AppTheme.accentLime)),
          ],
        ),
        content: const Text(
          'You just earned a scratch card for this booking!\n\nGo to your wallet to scratch and reveal your cashback.',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome!', style: TextStyle(color: AppTheme.accentLime, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Navigate to return booking with reversed route
  void _navigateToReturnBooking() {
    final currentDate = DateTime.now();
    final formattedDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    final returnSearchData = {
      "from": widget.busData.routeDetail.to,
      "to": widget.busData.routeDetail.from,
      "date": formattedDate,
      "shift": ["day", "night"],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusResultsScreen(
          searchData: returnSearchData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketData = TicketData(
      ticketId: widget.ticketId,
      passengerName: widget.name,
      operatorName: widget.busData.busDetail.busName,
      from: widget.busData.routeDetail.from,
      to: widget.busData.routeDetail.to,
      date: widget.busData.tripDate,
      time: widget.busData.departureTime,
      arrivalTime: widget.busData.arrivalTime,
      duration: widget.busData.routeDetail.duration,
      busNumber: widget.busData.busDetail.busNumber,
      busName: widget.busData.busDetail.busName,
      seats: [widget.selectedSeats],
      price: widget.busData.tripFare.toDouble(),
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: SafeArea(
          child: Column(
            children: [
              // ── Glass Header ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppTheme.cardBg,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.stroke, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.inputBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.stroke, width: 1),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Booking Confirmed',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _shareTicketInfo,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.inputBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.stroke, width: 1),
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          color: AppTheme.accentLime,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ──
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      ),
                    );
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ── Success Banner ──
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLime.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppTheme.accentLime.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLime.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppTheme.accentLime,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Booking Confirmed!',
                                      style: TextStyle(
                                        color: AppTheme.accentLime,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Your ticket has been booked successfully.',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Ticket Card ──
                        TicketCardWidget(
                          ticketData: ticketData,
                          qrCodeWidget: QRCodeWidget(
                            qrData: '${widget.ticketId}_${widget.busData.id}',
                            size: 120.0,
                            description: 'Show this QR to the conductor for verification',
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Action Buttons ──
                        _buildActionButtons(),

                        const SizedBox(height: 16),

                        // ── Book Return Ticket CTA ──
                        _buildReturnTicketCard(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _generateAndDownloadTicket,
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentLime,
              foregroundColor: AppTheme.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _shareTicketInfo,
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: const BorderSide(color: AppTheme.stroke),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReturnTicketCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.stroke, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDarkest.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppTheme.info,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need a return ticket?',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.busData.routeDetail.to} → ${widget.busData.routeDetail.from}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _navigateToReturnBooking,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.info,
                side: BorderSide(color: AppTheme.info.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Book Return Ticket',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareTicketInfo() async {
    try {
      final pdfFile = await _generatePDF();
      final directory = await getTemporaryDirectory();
      final fileName = 'sumarg_ticket_${widget.ticketId}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdfFile.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Sumarg bus ticket: ${widget.busData.routeDetail.from} → ${widget.busData.routeDetail.to}',
        subject: 'Sumarg Bus Ticket',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _generateAndDownloadTicket() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating ticket PDF...'),
        duration: Duration(seconds: 1),
        backgroundColor: AppTheme.primary,
      ),
    );

    final pdf = await _generatePDF();

    try {
      bool hasPermission = true;
      if (Platform.isAndroid) {
        hasPermission = await Permission.manageExternalStorage.isGranted ||
            await Permission.storage.isGranted;
        if (!hasPermission) {
          final status = await Permission.storage.request();
          hasPermission = status.isGranted;
          if (!hasPermission) {
            final manageStatus = await Permission.manageExternalStorage.request();
            hasPermission = manageStatus.isGranted;
          }
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) throw Exception('Could not access storage');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'sumarg_ticket_${widget.ticketId}_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Saved to ${Platform.isAndroid ? 'Downloads' : 'Documents'}'),
                ),
              ],
            ),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 2),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Sumarg Bus Ticket',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                    pw.Text(
                      'E-Ticket',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 20),

                // Passenger Info
                pw.Row(
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Passenger', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(widget.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Route Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('From', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(widget.busData.routeDetail.from, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Text('→', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('To', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(widget.busData.routeDetail.to, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Date, Time and Seat
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Date', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(widget.busData.tripDate, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Time', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(widget.busData.departureTime, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Seat', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(widget.selectedSeats, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 20),

                // Bus Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Bus Name', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(widget.busData.busDetail.busName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Bus No', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(widget.busData.busDetail.busNumber, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Ticket ID
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Ticket ID:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.ticketId, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Footer
                pw.Center(
                  child: pw.Text(
                    'Thank you for choosing Sumarg Bus Services!',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'This is a computer-generated ticket and does not require a signature.',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }
}
