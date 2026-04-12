import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sumarg/views/widgets/ticket_card_widget.dart';
import 'package:sumarg/views/widgets/qr_code_widget.dart';
import '../utils/color_constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/ticket_provider.dart';
import '../models/trip_data.dart';

class TicketDetailScreen extends StatefulWidget {
  final TripData tripData;

  const TicketDetailScreen({
    super.key,
    required this.tripData,
  });

  @override
  State<TicketDetailScreen> createState() =>
      _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Create TicketData from TripData
    final ticketData = TicketData(
      ticketId: widget.tripData.ticketId,
      passengerName: widget.tripData.passengerName,
      operatorName: widget.tripData.operatorName,
      from: widget.tripData.from,
      to: widget.tripData.to,
      date: widget.tripData.date,
      time: widget.tripData.time,
      busNumber: widget.tripData.busNumber,
      busName: widget.tripData
          .busNumber, // Using busNumber as busName since TripData doesn't have separate busName
      seats: widget.tripData.seats,
      price: widget.tripData.price,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text(
          'Ticket Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareTicketPDF,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ticket Card
            TicketCardWidget(
              ticketData: ticketData,
              qrCodeWidget: QRCodeWidget(
                qrData:
                    '${widget.tripData.ticketId}_${widget.tripData.tripId}',
                size: 100.0,
                description: 'Scan QR code to verify',
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
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
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download, size: 18),
                label: Text(
                    _isLoading ? 'Downloading...' : 'Download PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareTicketPDF,
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
            child: ElevatedButton.icon(
              onPressed: _showCancelConfirmation,
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Cancel Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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

  // Generate and save PDF to Downloads folder
  Future<void> _downloadTicketPDF() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pdfFile = await _generatePDF();

      // Save to Downloads directory (Android) or Documents directory (iOS)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        // If Downloads folder doesn't exist, use external storage directory
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final fileName =
            'bus_ticket_${widget.tripData.ticketId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(await pdfFile.save());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'PDF saved to ${Platform.isAndroid ? 'Downloads' : 'Documents'} folder'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () {
                  // You can add code here to open the file if needed
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Share PDF file
  Future<void> _shareTicketPDF() async {
    try {
      final pdfFile = await _generatePDF();

      // Save PDF to temporary directory for sharing
      final directory = await getTemporaryDirectory();
      final fileName = 'ticket_${widget.tripData.ticketId}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdfFile.save());

      // Share PDF file
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'My bus ticket from ${widget.tripData.from} to ${widget.tripData.to}',
        subject: 'Bus Ticket PDF',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Generate PDF document
  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();

    // Generate QR code data
    final qrData =
        '${widget.tripData.ticketId}_${widget.tripData.tripId}';

    // Create QR code image
    final qrImage = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    ).toImageData(200);

    // Convert QR image to PDF image
    final qrPdfImage = pw.MemoryImage(qrImage!.buffer.asUint8List());

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
                    borderRadius:
                        pw.BorderRadius.all(pw.Radius.circular(10)),
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
                        'Booking ID: ${widget.tripData.ticketId}',
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Passenger Information
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
                        'Passenger Information',
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
                            'Name: ',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(widget.tripData.passengerName),
                        ],
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
                          pw.Text(widget.tripData.busNumber),
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
                          pw.Text(widget.tripData.operatorName),
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
                          pw.Text(
                              widget.tripData.status.toUpperCase()),
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
                          pw.Text(widget.tripData.from),
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
                          pw.Text(widget.tripData.to),
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
                          pw.Text(widget.tripData.date),
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
                          pw.Text(widget.tripData.time),
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
                          pw.Text(widget.tripData.seats.join(', ')),
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
                              'Rs. ${widget.tripData.price.toStringAsFixed(0)}'),
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

    return pdf;
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Ticket'),
          content: Text(
            'Are you sure you want to cancel your ticket from ${widget.tripData.from} to ${widget.tripData.to}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCancelReasonSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelReasonSheet() {
    final TextEditingController reasonController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        bool isSubmitting = false;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> submit() async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a cancel reason'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setModalState(() => isSubmitting = true);
                final success = await _cancelTicketRequest(reason);
                if (!mounted) return;
                setModalState(() => isSubmitting = false);

                if (success) {
                  // Close the bottom sheet
                  Navigator.of(context).pop();
                  // Show success
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ticket cancelled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Refresh tickets so lists update immediately
                  try {
                    final ticketProvider =
                        Provider.of<TicketProvider>(context, listen: false);
                    await ticketProvider.refreshTickets();
                  } catch (_) {}
                  // Navigate back to previous screen (e.g., My Trips)
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: SizedBox(
                      width: 40,
                      height: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius:
                              BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cancel Ticket',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please provide a reason for cancellation.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Cancel Reason',
                      hintText: 'e.g., Change in travel plans',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                              ),
                            )
                          : const Text('Confirm Cancel'),
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

  Future<bool> _cancelTicketRequest(String reason) async {
    try {
      final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
      final data = {
        'ticketId': widget.tripData.ticketId,
        'cancelReason': reason,
      };
      
      final result = await ticketProvider.cancelTicket(data);
      
      if (!mounted) return false;
      
      if (result.status == true) {
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
