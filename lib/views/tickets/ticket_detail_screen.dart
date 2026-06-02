import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sumarg/views/widgets/ticket_card_widget.dart';
import 'package:sumarg/views/widgets/qr_code_widget.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:sumarg/providers/ticket_provider.dart';
import 'package:sumarg/models/cancel_estimate_response.dart';
import '../../models/trip_data.dart';

class TicketDetailScreen extends StatefulWidget {
  final TripData tripData;

  const TicketDetailScreen({
    super.key,
    required this.tripData,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ticketData = TicketData(
      ticketId: widget.tripData.ticketId,
      passengerName: widget.tripData.passengerName,
      operatorName: widget.tripData.operatorName,
      from: widget.tripData.from,
      to: widget.tripData.to,
      date: widget.tripData.date,
      time: widget.tripData.time,
      busNumber: widget.tripData.busNumber,
      busName: widget.tripData.operatorName.isNotEmpty
          ? widget.tripData.operatorName
          : widget.tripData.busNumber,
      seats: widget.tripData.seats,
      price: widget.tripData.price,
    );

    return Scaffold(
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
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: AppTheme.textPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Ticket Details',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.tripData.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: _getStatusColor(widget.tripData.status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(widget.tripData.status),
                      style: TextStyle(
                        color: _getStatusColor(widget.tripData.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Ticket Card
                    TicketCardWidget(
                      ticketData: ticketData,
                      qrCodeWidget: QRCodeWidget(
                        qrData: '${widget.tripData.ticketId}_${widget.tripData.tripId}',
                        size: 120.0,
                        description: 'Show this QR to the conductor for verification',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(),

                    // Refund Tracking (for cancelled tickets)
                    if (widget.tripData.status == 'cancelled' &&
                        widget.tripData.refundInfo != null)
                      _buildRefundTrackingCard(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Download and Share buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _downloadTicketPDF,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryDark,
                        ),
                      )
                    : const Icon(Icons.download_outlined, size: 18),
                label: Text(_isLoading ? 'Downloading...' : 'Download PDF'),
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
                onPressed: _shareTicketPDF,
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
        ),

        // Cancel button (only for upcoming trips)
        if (widget.tripData.status == 'upcoming') ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _showCancelConfirmation,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.error.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, size: 18, color: AppTheme.error),
                    SizedBox(width: 8),
                    Text(
                      'Cancel Ticket',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AppTheme.accentLime;
      case 'completed':
        return AppTheme.textSecondary;
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
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

  // ── Refund Tracking Card ──

  Widget _buildRefundTrackingCard() {
    final refund = widget.tripData.refundInfo!;
    final statusColor = _getRefundStatusColor(refund.status);
    final statusLabel = _getRefundStatusLabel(refund.status);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.stroke, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getRefundStatusIcon(refund.status),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Refund Status',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Amount breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.inputBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.stroke),
            ),
            child: Column(
              children: [
                _buildRefundRow('Ticket Fare', 'NPR ${refund.originalAmount}', AppTheme.textPrimary),
                if (refund.cancellationCharge > 0) ...[
                  const SizedBox(height: 8),
                  _buildRefundRow('Cancellation Fee', '- NPR ${refund.cancellationCharge}', AppTheme.error),
                ],
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 1,
                  color: AppTheme.stroke,
                ),
                _buildRefundRow(
                  'Refund Amount',
                  'NPR ${refund.refundAmount}',
                  AppTheme.accentLime,
                  bold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Timeline
          if (refund.requestedAt != null)
            _buildTimelineItem(
              'Cancellation Requested',
              _formatRefundDate(refund.requestedAt!),
              true,
              isFirst: true,
            ),
          if (refund.processedAt != null)
            _buildTimelineItem(
              'Refund Processing',
              _formatRefundDate(refund.processedAt!),
              true,
            ),
          if (refund.completedAt != null)
            _buildTimelineItem(
              'Refund Completed',
              _formatRefundDate(refund.completedAt!),
              true,
              isLast: true,
            ),
          if (refund.status == 'pending')
            _buildTimelineItem(
              'Awaiting Processing',
              'Expected: 3-7 business days',
              false,
              isLast: true,
            ),
          if (refund.status == 'processing' && refund.completedAt == null)
            _buildTimelineItem(
              'Refund in Progress',
              'Being processed by our team',
              false,
              isLast: true,
            ),

          // Rejection reason
          if (refund.status == 'rejected' && refund.remarks != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.error.withOpacity(0.7), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      refund.remarks!,
                      style: TextStyle(
                        color: AppTheme.error.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefundRow(String label, String value, Color valueColor, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool completed, {bool isFirst = false, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot and line
          Column(
            children: [
              if (!isFirst)
                Container(width: 1.5, height: 8, color: completed ? AppTheme.accentLime.withOpacity(0.3) : AppTheme.stroke),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? AppTheme.accentLime : AppTheme.stroke,
                  border: Border.all(
                    color: completed ? AppTheme.accentLime : AppTheme.textSecondary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Container(width: 1.5, height: 20, color: completed ? AppTheme.accentLime.withOpacity(0.3) : AppTheme.stroke),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: completed ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRefundStatusColor(String status) {
    switch (status) {
      case 'completed': return AppTheme.accentLime;
      case 'processing': return const Color(0xFFF59E0B);
      case 'pending': return const Color(0xFF3B82F6);
      case 'rejected': return AppTheme.error;
      default: return AppTheme.textSecondary;
    }
  }

  String _getRefundStatusLabel(String status) {
    switch (status) {
      case 'completed': return 'Refund Completed';
      case 'processing': return 'Refund Processing';
      case 'pending': return 'Refund Pending';
      case 'rejected': return 'Refund Rejected';
      default: return 'Unknown';
    }
  }

  IconData _getRefundStatusIcon(String status) {
    switch (status) {
      case 'completed': return Icons.check_circle_outline;
      case 'processing': return Icons.autorenew;
      case 'pending': return Icons.schedule;
      case 'rejected': return Icons.cancel_outlined;
      default: return Icons.help_outline;
    }
  }

  String _formatRefundDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  // ── PDF Generation ──

  Future<void> _downloadTicketPDF() async {
    setState(() => _isLoading = true);

    try {
      final pdfFile = await _generatePDF();

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final fileName =
            'sumarg_ticket_${widget.tripData.ticketId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(await pdfFile.save());

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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _shareTicketPDF() async {
    try {
      final pdfFile = await _generatePDF();
      final directory = await getTemporaryDirectory();
      final fileName = 'sumarg_ticket_${widget.tripData.ticketId}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdfFile.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Sumarg bus ticket: ${widget.tripData.from} → ${widget.tripData.to}',
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

  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();

    final qrData = '${widget.tripData.ticketId}_${widget.tripData.tripId}';
    final qrImage = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    ).toImageData(200);

    final qrPdfImage = pw.MemoryImage(qrImage!.buffer.asUint8List());

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
                    color: PdfColors.green800,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SUMARG BUS TICKET',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Booking ID: ${widget.tripData.ticketId}',
                        style: const pw.TextStyle(fontSize: 14, color: PdfColors.white),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Passenger
                _buildPdfSection('Passenger Information', [
                  _buildPdfRow('Name', widget.tripData.passengerName),
                ]),

                pw.SizedBox(height: 20),

                // Route
                _buildPdfSection('Route Information', [
                  _buildPdfRow('From', widget.tripData.from),
                  _buildPdfRow('To', widget.tripData.to),
                  _buildPdfRow('Date', widget.tripData.date),
                  _buildPdfRow('Time', widget.tripData.time),
                ]),

                pw.SizedBox(height: 20),

                // Booking
                _buildPdfSection('Booking Details', [
                  _buildPdfRow('Bus', widget.tripData.operatorName),
                  _buildPdfRow('Bus No.', widget.tripData.busNumber),
                  _buildPdfRow('Seats', widget.tripData.seats.join(', ')),
                  _buildPdfRow('Price', 'Rs. ${widget.tripData.price.toStringAsFixed(0)}'),
                  _buildPdfRow('Status', widget.tripData.status.toUpperCase()),
                ]),

                pw.SizedBox(height: 30),

                // QR Code
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('Scan to Verify', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
                      pw.SizedBox(height: 10),
                      pw.Image(qrPdfImage, width: 150, height: 150),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Center(
                  child: pw.Text(
                    'Generated on ${DateTime.now().toString().split('.')[0]}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
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

  pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Text('$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showCancelConfirmation() async {
    // Show loading indicator while fetching estimate
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentLime),
      ),
    );

    // Fetch refund estimate from backend
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final estimateResult = await ticketProvider.getCancelEstimate({
      'ticketId': widget.tripData.ticketId,
    });

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss loading

    if (!estimateResult.status || estimateResult.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(estimateResult.message),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final estimate = estimateResult.data!;

    if (!estimate.eligible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(estimate.reason ?? 'Cancellation not available'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Show the refund estimate breakdown dialog
    _showRefundEstimateDialog(estimate);
  }

  void _showRefundEstimateDialog(CancelEstimateData estimate) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: AppTheme.primaryDarker,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryDarker,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.stroke, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.error.withOpacity(0.25)),
                  ),
                  child: const Icon(Icons.receipt_long_outlined, color: AppTheme.error, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cancellation Breakdown',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),

                // Breakdown rows
                _buildEstimateRow('Ticket Fare', 'NPR ${estimate.ticketFare}', false),
                if (estimate.cancellationCharge > 0)
                  _buildEstimateRow(
                    'Cancellation Fee (${(100 - estimate.refundPercentage).toInt()}%)',
                    '- NPR ${estimate.cancellationCharge}',
                    true,
                  ),
                if (estimate.gatewayDeduction > 0)
                  _buildEstimateRow('Gateway Fee', '- NPR ${estimate.gatewayDeduction}', true),
                
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 1,
                  color: AppTheme.stroke,
                ),

                // Refund amount highlight
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLime.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accentLime.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Refund Amount',
                        style: TextStyle(color: AppTheme.accentLime, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'NPR ${estimate.refundAmount}',
                        style: const TextStyle(color: AppTheme.accentLime, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                // Policy info
                Text(
                  estimate.appliedPolicy?.description ?? '',
                  style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 11, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLime,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: AppTheme.accentLime.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Center(
                            child: Text('Keep Ticket', style: TextStyle(color: AppTheme.primaryDark, fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _showCancelReasonSheet(estimate);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.error.withOpacity(0.4), width: 1.2),
                          ),
                          child: const Center(
                            child: Text('Cancel', style: TextStyle(color: AppTheme.error, fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstimateRow(String label, String value, bool isDeduction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isDeduction ? AppTheme.error : AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelReasonSheet(CancelEstimateData estimate) {
    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.primaryDarker,
      barrierColor: Colors.black.withOpacity(0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool isSubmitting = false;
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryDarker,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
              top: BorderSide(color: AppTheme.stroke, width: 1.5),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              String selectedRefundMethod = 'wallet';

              Future<void> submit() async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a reason'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                  return;
                }

                setModalState(() => isSubmitting = true);
                final success = await _cancelTicketRequest(reason, selectedRefundMethod);
                if (!mounted) return;
                setModalState(() => isSubmitting = false);

                if (success) {
                  Navigator.of(context).pop();
                  final message = selectedRefundMethod == 'wallet'
                      ? 'Refund of NPR ${estimate.refundAmount} has been instantly credited to your Shuvmarg Money.'
                      : 'Ticket cancelled. Refund of NPR ${estimate.refundAmount} is being processed (3-5 days).';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                  try {
                    final ticketProvider =
                        Provider.of<TicketProvider>(context, listen: false);
                    await ticketProvider.refreshTickets();
                  } catch (_) {}
                  if (mounted) Navigator.of(context).pop();
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.stroke,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Refund Destination',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Wallet Option
                  GestureDetector(
                    onTap: () => setModalState(() => selectedRefundMethod = 'wallet'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedRefundMethod == 'wallet'
                            ? AppTheme.accentLime.withOpacity(0.1)
                            : AppTheme.inputBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedRefundMethod == 'wallet'
                              ? AppTheme.accentLime
                              : AppTheme.stroke,
                          width: selectedRefundMethod == 'wallet' ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: selectedRefundMethod == 'wallet' ? AppTheme.accentLime : AppTheme.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontFamily,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Shuvmarg ',
                                            style: TextStyle(
                                              color: selectedRefundMethod == 'wallet' ? AppTheme.textPrimary : AppTheme.textSecondary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Money',
                                            style: TextStyle(
                                              color: selectedRefundMethod == 'wallet' ? AppTheme.accentLime : AppTheme.textSecondary.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentLime,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Instant',
                                        style: TextStyle(color: AppTheme.primaryDark, fontSize: 10, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Refunded immediately to your wallet',
                                  style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (selectedRefundMethod == 'wallet')
                            const Icon(Icons.check_circle_rounded, color: AppTheme.accentLime, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Original Option
                  GestureDetector(
                    onTap: () => setModalState(() => selectedRefundMethod = 'original'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedRefundMethod == 'original'
                            ? AppTheme.primary.withOpacity(0.1)
                            : AppTheme.inputBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedRefundMethod == 'original'
                              ? AppTheme.primary
                              : AppTheme.stroke,
                          width: selectedRefundMethod == 'original' ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.credit_card_rounded,
                            color: selectedRefundMethod == 'original' ? AppTheme.primary : AppTheme.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Original Payment Method',
                                  style: TextStyle(
                                    color: selectedRefundMethod == 'original' ? AppTheme.textPrimary : AppTheme.textSecondary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Takes 3-5 business days',
                                  style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (selectedRefundMethod == 'original')
                            const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cancellation Reason',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please let us know why you\'re cancelling.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g., Change in travel plans',
                      hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.4)),
                      filled: true,
                      fillColor: AppTheme.inputBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppTheme.stroke),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppTheme.stroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppTheme.accentLime, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: isSubmitting ? null : submit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSubmitting 
                              ? AppTheme.error.withOpacity(0.5) 
                              : AppTheme.error,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (!isSubmitting)
                              BoxShadow(
                                color: AppTheme.error.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Center(
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Confirm Cancellation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> _cancelTicketRequest(String reason, String refundMethod) async {
    try {
      final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
      final data = {
        'ticketId': widget.tripData.ticketId,
        'cancelReason': reason,
        'refundMethod': refundMethod,
      };

      final result = await ticketProvider.cancelTicket(data);

      if (!mounted) return false;

      if (result.status == true) {
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppTheme.error,
          ),
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return false;
    }
  }
}
