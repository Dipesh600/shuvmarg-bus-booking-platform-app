import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/home/home_screen.dart';
import 'package:sumarg/views/search/buss_search_result_screen.dart';
import 'package:sumarg/views/widgets/ticket_card_widget.dart';
import 'package:sumarg/views/widgets/qr_code_widget.dart';
import 'dart:io';

class TicketScreen extends StatefulWidget {
  final String ticketId;
  final String name;
  final String role;
  final String profilePic;
  final String selectedSeats;
  final TripData busData;

  const TicketScreen({
    super.key,
    required this.ticketId,
    required this.selectedSeats,
    required this.busData,
    required this.name,
    required this.role,
    required this.profilePic,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showReturnTicketDialog();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showReturnTicketDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: 'Book Return Ticket?',
      desc:
          'You booked a ticket from ${widget.busData.routeDetail.from} to ${widget.busData.routeDetail.to}. Would you like to book a return ticket from ${widget.busData.routeDetail.to} to ${widget.busData.routeDetail.from} ?',
      btnCancelOnPress: () {},
      btnOkText: 'Book Now',
      btnOkOnPress: () {
        _navigateToReturnBooking();
      },
      btnCancelText: 'Not Now',
      btnCancelColor: Colors.grey,
      btnOkColor: AppColors.primary,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      descTextStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
    ).show();
  }

  /// Navigate to return booking with reversed route
  void _navigateToReturnBooking() {
    // Get current date for return booking
    final currentDate = DateTime.now();
    final formattedDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    // Create search data with reversed route
    final returnSearchData = {
      "from": widget.busData.routeDetail.to, // Destination becomes origin
      "to": widget.busData.routeDetail.from, // Origin becomes destination
      "date": formattedDate, // Use current date
      "shift": ["day", "night"], // Default to both shifts
    };

    // Navigate to search results screen with return booking data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusResultsScreen(
          searchData: returnSearchData,
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
                onPressed: _generateAndDownloadTicket,
                icon: const Icon(Icons.download, size: 18,color: AppColors.background,),
                label: const Text('Download PDF'),
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
                onPressed: _generateAndDownloadTicket,
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
      ],
    );
  }

  Future<void> _generateAndDownloadTicket() async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating ticket PDF...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Create PDF document
    final pdf = pw.Document();

    // Add page to the PDF
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
                        pw.Text(
                          'Passenger',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          widget.name,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          widget.role,
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
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
                        pw.Text(
                          'From',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          widget.busData.routeDetail.from,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          '→',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'To',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          widget.busData.routeDetail.to,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
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
                        pw.Text(
                          'Date',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          widget.busData.tripDate,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Time',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          widget.busData.departureTime,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Seat',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          widget.selectedSeats,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
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
                        pw.Text(
                          'Bus Name',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          widget.busData.busDetail.busName,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Bus No',
                          style: pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          widget.busData.busDetail.busNumber,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
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
                      pw.Text(
                        'Ticket ID:',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        widget.ticketId,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Footer
                pw.Center(
                  child: pw.Text(
                    'Thank you for choosing Sumarg Bus Services!',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'This is a computer-generated ticket and does not require a signature.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing your ticket...'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.blue,
        ),
      );

      // Check if we already have permission
      bool hasPermission = await _checkStoragePermission();

      // If not, request permissions
      if (!hasPermission && Platform.isAndroid) {
        // First try storage permission
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          hasPermission = true;
        } else {
          // Then try manage external storage (for Android 11+)
          final manageStorageStatus =
              await Permission.manageExternalStorage.request();
          if (manageStorageStatus.isGranted) {
            hasPermission = true;
          } else {
            // Try media permissions as last resort
            await Permission.photos.request();
            await Permission.videos.request();

            // Check if any permission was granted
            hasPermission = await _checkStoragePermission();
          }
        }
      } else if (Platform.isIOS) {
        // iOS doesn't need explicit permission for app's documents directory
        hasPermission = true;
      }

      if (hasPermission) {
        // Get the downloads directory
        Directory? directory;

        try {
          if (Platform.isAndroid) {
            // For Android, try different approaches to get the downloads directory
            try {
              // First try to get the downloads directory directly
              directory = Directory('/storage/emulated/0/Download');
              if (!await directory.exists()) {
                // If that fails, try to get the external storage directory
                final externalDir = await getExternalStorageDirectory();
                if (externalDir != null) {
                  // Navigate up to find the Download directory
                  final downloadDir = Directory('${externalDir.path}/Download');
                  if (await downloadDir.exists()) {
                    directory = downloadDir;
                  } else {
                    // Create Download directory if it doesn't exist
                    await downloadDir.create(recursive: true);
                    directory = downloadDir;
                  }
                } else {
                  // Last resort: use app documents directory
                  directory = await getApplicationDocumentsDirectory();
                }
              }
            } catch (e) {
              debugPrint('Error accessing Android download directory: $e');
              // Fallback to app's documents directory
              directory = await getApplicationDocumentsDirectory();
            }
          } else if (Platform.isIOS) {
            // For iOS, use the documents directory
            directory = await getApplicationDocumentsDirectory();
          } else {
            // For other platforms, use app documents directory
            directory = await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          debugPrint('Error determining directory: $e');
          // Fallback to app documents directory
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception('Could not access storage directory');
        }

        // Create a unique filename with timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'sumarg_ticket_${widget.ticketId}_$timestamp.pdf';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        // Save PDF to file
        await file.writeAsBytes(await pdf.save());

        // Show success message with file path
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Ticket saved successfully!'),
                      Text(
                        'Saved to: ${filePath.split('/').last}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _shareTicket(file);
                  },
                  child: const Text(
                    'SHARE',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Vibrate to indicate successful download
        HapticFeedback.mediumImpact();

        // Also offer to open the PDF file
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'Ticket Downloaded',
          desc:
              'Your ticket has been downloaded successfully. Would you like to open it now?',
          btnCancelOnPress: () {},
          btnOkOnPress: () async {
            try {
              await Printing.sharePdf(
                  bytes: await pdf.save(), filename: fileName);
            } catch (e) {
              debugPrint('Error opening PDF: $e');
            }
          },
          btnOkText: 'Open',
          btnCancelText: 'Later',
        ).show();
      } else {
        // Permission denied - show dialog explaining why we need permission
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.scale,
          title: 'Permission Required',
          desc:
              'Storage permission is required to save the ticket PDF to your device. '
              'Please grant permission to download your ticket.',
          btnOkOnPress: () {
            // Open app settings so user can enable permission
            openAppSettings();
          },
          btnCancelOnPress: () {},
          btnOkText: 'Open Settings',
          btnCancelText: 'Cancel',
        ).show();
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error saving PDF: $e');
    }
  }

  Future<void> _shareTicket(File file) async {
    try {
      await Share.shareFiles(
        [file.path],
        text: 'My Sumarg Bus Ticket',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share ticket: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to check if we have storage permissions
  Future<bool> _checkStoragePermission() async {
    // For Android 13+ (API 33+)
    if (Platform.isAndroid) {
      // Try the MANAGE_EXTERNAL_STORAGE permission first (for Android 11+)
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Then try the regular storage permission
      if (await Permission.storage.isGranted) {
        return true;
      }

      // If we're on Android 13+ (API 33+), we can also check for media permissions
      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted) {
        return true;
      }

      return false;
    }

    // iOS doesn't need explicit permission for app's documents directory
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onWillPop() async {
      final shouldLeave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Leave Ticket?'),
              content: const Text(
                  'Are you sure you want to leave this screen? You will be taken to the home screen.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes, Go to Home'),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldLeave) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
      return false;
    }

    // Create TicketData from widget properties
    final ticketData = TicketData(
      ticketId: widget.ticketId,
      passengerName: widget.name,
      operatorName: widget.role,
      from: widget.busData.routeDetail.from,
      to: widget.busData.routeDetail.to,
      date: widget.busData.tripDate,
      time: widget.busData.departureTime,
      busNumber: widget.busData.busDetail.busNumber,
      busName: widget.busData.busDetail.busName,
      seats: [widget.selectedSeats], // Convert single seat to list
      price: widget.busData.tripFare.toDouble(),
    );

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
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
                  onPressed: _generateAndDownloadTicket,
                ),
              ],
            ),
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Ticket Card
                      TicketCardWidget(
                        ticketData: ticketData,
                        qrCodeWidget: QRCodeWidget(
                          qrData: '${widget.ticketId}_${widget.busData.id}',
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
              ),
            )));
  }
}
