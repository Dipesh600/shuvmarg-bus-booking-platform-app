import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/ticket_provider.dart';
import '../../utils/provider_helper.dart';
import 'package:sumarg/views/widgets/ticket_history_widget.dart';
import 'package:sumarg/views/widgets/status_state_widget.dart';
import 'package:sumarg/views/widgets/ticket_skeleton_widget.dart';

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
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Clean Header matching Available Buses
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context)) ...[
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: AppTheme.textPrimary,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                          children: [
                            TextSpan(
                              text: 'My ',
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                            TextSpan(
                              text: 'Trips',
                              style: TextStyle(color: AppTheme.accentLime),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Consumer<TicketProvider>(
                    builder: (context, ticketProvider, child) {
                      return GestureDetector(
                        onTap: () => ticketProvider.refreshTickets(),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: AppTheme.accentLime,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Consumer<TicketProvider>(
                builder: (context, ticketProvider, child) {
                  Widget content;
                  if (ticketProvider.isLoading) {
                    content = _buildLoadingState();
                  } else if (ticketProvider.error.isNotEmpty) {
                    content = _buildErrorState(ticketProvider);
                  } else if (!ticketProvider.hasTickets) {
                    content = _buildEmptyState();
                  } else {
                    content = RefreshIndicator(
                      key: const ValueKey('tickets'),
                      onRefresh: () async {
                        await ticketProvider.refreshTickets();
                      },
                      color: AppTheme.accentLime,
                      backgroundColor: AppTheme.primaryDarker,
                      child: TicketHistoryWidget(
                        ticketHistoryData: ticketProvider.tickets,
                      ),
                    );
                  }
                  
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: content,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const TicketSkeletonWidget(
      key: ValueKey('loading'),
    );
  }

  Widget _buildErrorState(TicketProvider provider) {
    return StatusStateWidget.error(
      rawError: provider.error,
      onRetry: () => provider.refreshTickets(),
    );
  }

  Widget _buildEmptyState() {
    return StatusStateWidget.empty(
      title: 'No trips found',
      subtitle: 'Your booked trips will appear here',
      icon: FontAwesomeIcons.bus,
    );
  }
}
