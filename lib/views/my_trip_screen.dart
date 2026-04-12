import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../utils/color_constants.dart';
import '../providers/ticket_provider.dart';
import '../utils/provider_helper.dart';
import 'widgets/ticket_history_widget.dart';

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen> {
  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final ticketProvider = AppProviders.ticketProvider(context);
    await ticketProvider.loadTickets();
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text(
          'My Trips',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        actions: [
          Consumer<TicketProvider>(
            builder: (context, ticketProvider, child) {
              return IconButton(
                onPressed: () {
                  ticketProvider.refreshTickets();
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh trips',
              );
            },
          ),
        ],
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          if (ticketProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (ticketProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading trips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticketProvider.error,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ticketProvider.refreshTickets();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!ticketProvider.hasTickets) {
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
                  const Text(
                    'No trips found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your trips will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Online/Offline indicator
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.symmetric(
              //       vertical: 8, horizontal: 16),
              //   color: ticketProvider.isOffline
              //       ? Colors.orange.withOpacity(0.1)
              //       : Colors.green.withOpacity(0.1),
              //   child: Row(
              //     children: [
              //       Icon(
              //         ticketProvider.isOffline
              //             ? Icons.wifi_off
              //             : Icons.wifi,
              //         size: 16,
              //         color: ticketProvider.isOffline
              //             ? Colors.orange[700]
              //             : Colors.green[700],
              //       ),
              //       const SizedBox(width: 8),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               ticketProvider.isOffline
              //                   ? 'Showing offline data'
              //                   : 'Live data',
              //               style: TextStyle(
              //                 fontSize: 12,
              //                 color: ticketProvider.isOffline
              //                     ? Colors.orange[700]
              //                     : Colors.green[700],
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //             if (ticketProvider.lastUpdated != null)
              //               Text(
              //                 'Last synced: ${_formatLastUpdated(ticketProvider.lastUpdated!)}',
              //                 style: TextStyle(
              //                   fontSize: 10,
              //                   color: ticketProvider.isOffline
              //                       ? Colors.orange[600]
              //                       : Colors.green[600],
              //                 ),
              //               ),
              //           ],
              //         ),
              //       ),
              //       Icon(
              //         ticketProvider.isOffline
              //             ? Icons.info_outline
              //             : Icons.check_circle,
              //         size: 16,
              //         color: ticketProvider.isOffline
              //             ? Colors.orange[600]
              //             : Colors.green[600],
              //       ),
              //     ],
              //   ),
              // ),

              // Ticket history data
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ticketProvider.refreshTickets();
                  },
                  color: AppColors.primary,
                  child: TicketHistoryWidget(
                    ticketHistoryData: ticketProvider.tickets,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
