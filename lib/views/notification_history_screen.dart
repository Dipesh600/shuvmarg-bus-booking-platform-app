import 'package:sumarg/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/providers/notification_provider.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends State<NotificationHistoryScreen> {
  List<String> categories = ['All', 'Bookings', 'Offers', 'System'];

  @override
  void initState() {
    super.initState();
    // Load notifications when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'trip':
        return Icons.confirmation_num;
      case 'offer':
      case 'discount':
        return Icons.local_offer;
      case 'system':
      case 'update':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} minutes ago';
        }
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return true to indicate that notifications were viewed
        // This will help the dashboard refresh the notification count
        Navigator.pop(context, true);
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Category filter
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Row(
                    children: categories.map((cat) {
                      final bool selected =
                          notificationProvider.selectedCategory ==
                              cat;
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) {
                            notificationProvider
                                .setSelectedCategory(cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  if (notificationProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (notificationProvider.error.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64,
                              color: Colors.red.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notificationProvider.error,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              notificationProvider
                                  .loadNotifications();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (notificationProvider.notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Filter notifications based on selected category
                  List<dynamic> filtered =
                      notificationProvider.filteredNotifications;

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_list_off,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications in this category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try selecting a different category',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                      onRefresh: () async {
                        await notificationProvider
                            .refreshNotifications();
                      },
                      child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final notification = filtered[index];
                            return Dismissible(
                              key: ValueKey(notification.id),
                              direction: notification.isRead
                                  ? DismissDirection.endToStart
                                  : DismissDirection.horizontal,
                              background: _buildSwipeBackground(
                                icon: Icons.check_circle,
                                color: Colors.orange,
                                alignment: Alignment.centerLeft,
                                text: 'Mark as Read',
                              ),
                              secondaryBackground:
                                  _buildSwipeBackground(
                                icon: Icons.delete,
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                text: 'Delete',
                              ),
                              onDismissed: (direction) async {
                                // Handle swipe actions
                                if (direction ==
                                    DismissDirection.startToEnd) {
                                  // Mark as read - call API
                                  try {
                                    final success = await context
                                        .read<NotificationProvider>()
                                        .markNotificationAsRead(
                                            notification.id);
                                    if (success) {
                                      // Show success message
                                      ToastService.showToast(
                                        msg: 'Marked as read successfully',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                      );
                                      // No need to refresh - provider handles state
                                    } else {
                                      // Show error message
                                      ToastService.showToast(
                                        msg: context
                                            .read<NotificationProvider>()
                                            .error,
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                    }
                                  } catch (e) {
                                    // Show error message
                                    ToastService.showToast(
                                      msg: 'Error: ${e.toString()}',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                  }
                                } else {
                                  // Delete notification - call API
                                  try {
                                    final success = await context
                                        .read<NotificationProvider>()
                                        .deleteNotification(
                                            notification.id);
                                    if (success) {
                                      // Show success message
                                      ToastService.showToast(
                                        msg: 'Notification deleted successfully',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                      );
                                    } else {
                                      // Show error message
                                      ToastService.showToast(
                                        msg: context
                                            .read<NotificationProvider>()
                                            .error,
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                    }
                                  } catch (e) {
                                    // Show error message
                                    ToastService.showToast(
                                      msg: 'Error: ${e.toString()}',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                  }
                                }
                              },
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                // Add subtle pulse animation for unread notifications
                                transform: notification.isRead
                                    ? null
                                    : Matrix4.identity(),
                                decoration: BoxDecoration(
                                  color: notification.isRead
                                      ? Colors.grey[50]
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: notification.isRead
                                          ? Colors.black
                                              .withOpacity(0.04)
                                          : Colors.orange
                                              .withOpacity(0.15),
                                      blurRadius:
                                          notification.isRead ? 4 : 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  // Add borders for both read and unread notifications
                                  border: Border.all(
                                    color: notification.isRead
                                        ? Colors.grey[400]!
                                        : Colors.orange
                                            .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    // Mark as read on tap
                                    if (!notification.isRead) {
                                      try {
                                        final success = await context
                                            .read<
                                                NotificationProvider>()
                                            .markNotificationAsRead(
                                                notification.id);
                                        if (success) {
                                          // Show success message
                                          ToastService.showToast(
                                            msg: 'Marked as read successfully',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                          );
                                          // Refresh the list
                                          setState(() {});
                                        } else {
                                          // Show error message
                                          ToastService.showToast(
                                            msg: context
                                                .read<NotificationProvider>()
                                                .error,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                          );
                                        }
                                      } catch (e) {
                                        // Show error message
                                        ToastService.showToast(
                                          msg: 'Error: ${e.toString()}',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                        );
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header row with icon and status
                                        Row(
                                          children: [
                                            // Icon container
                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                      .all(10),
                                              decoration:
                                                  BoxDecoration(
                                                color: notification
                                                        .isRead
                                                    ? Colors.grey[200]
                                                    : Colors.orange
                                                        .withOpacity(
                                                            0.2),
                                                shape:
                                                    BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _getCategoryIcon(
                                                    notification
                                                        .type),
                                                color: notification
                                                        .isRead
                                                    ? Colors.grey[600]
                                                    : Colors
                                                        .orange[700],
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Title and status
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    notification
                                                        .title,
                                                    style: TextStyle(
                                                      fontWeight: notification.isRead
                                                          ? FontWeight
                                                              .normal
                                                          : FontWeight
                                                              .bold,
                                                      color: notification
                                                              .isRead
                                                          ? Colors.grey[
                                                              600]
                                                          : Colors
                                                              .black,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height: 4),
                                                  Text(
                                                    _formatDate(
                                                        notification
                                                            .createdAt),
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Status badge
                                            Container(
                                              padding:
                                                  const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration:
                                                  BoxDecoration(
                                                color: notification
                                                        .isRead
                                                    ? Colors.green
                                                        .withOpacity(
                                                            0.15)
                                                    : Colors.orange
                                                        .withOpacity(
                                                            0.15),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(12),
                                                border: Border.all(
                                                  color: notification
                                                          .isRead
                                                      ? Colors.green
                                                          .withOpacity(
                                                              0.4)
                                                      : Colors.orange
                                                          .withOpacity(
                                                              0.4),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    notification
                                                            .isRead
                                                        ? Icons
                                                            .check_circle
                                                        : Icons
                                                            .mark_email_unread,
                                                    color: notification
                                                            .isRead
                                                        ? Colors.green
                                                        : Colors
                                                            .orange,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(
                                                      width: 4),
                                                  Text(
                                                    notification
                                                            .isRead
                                                        ? 'Read'
                                                        : 'New',
                                                    style: TextStyle(
                                                      color: notification
                                                              .isRead
                                                          ? Colors
                                                              .green
                                                          : Colors
                                                              .orange,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight
                                                              .w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // Message
                                        Text(
                                          notification.message,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Meta information
                                        if (notification
                                                .meta
                                                .scheduleId
                                                .isNotEmpty ||
                                            notification.meta.seats
                                                .isNotEmpty ||
                                            notification.meta
                                                    .totalAmount >
                                                0)
                                          Container(
                                            padding:
                                                const EdgeInsets.all(
                                                    12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(8),
                                              border: Border.all(
                                                color:
                                                    Colors.grey[200]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                if (notification
                                                    .meta
                                                    .scheduleId
                                                    .isNotEmpty)
                                                  // Padding(
                                                  //   padding:
                                                  //       const EdgeInsets
                                                  //               .only(
                                                  //           bottom:
                                                  //               6),
                                                  //   child: Row(
                                                  //     children: [
                                                  //       Icon(
                                                  //           Icons
                                                  //               .schedule,
                                                  //           color: Colors
                                                  //               .blue,
                                                  //           size: 16),
                                                  //       const SizedBox(
                                                  //           width: 6),
                                                  //       Text(
                                                  //         'Schedule ID: ${notification.meta.scheduleId}',
                                                  //         style:
                                                  //             const TextStyle(
                                                  //           fontSize:
                                                  //               12,
                                                  //           color: Colors
                                                  //               .blue,
                                                  //           fontWeight:
                                                  //               FontWeight
                                                  //                   .w500,
                                                  //         ),
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  if (notification
                                                      .meta
                                                      .seats
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                                  .only(
                                                              bottom:
                                                                  6),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .event_seat,
                                                              color: Colors
                                                                  .green,
                                                              size:
                                                                  16),
                                                          const SizedBox(
                                                              width:
                                                                  6),
                                                          Text(
                                                            'Seats: ${notification.meta.seats.join(", ")}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize:
                                                                  12,
                                                              color: Colors
                                                                  .green,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                if (notification.meta
                                                        .totalAmount >
                                                    0)
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .payment,
                                                          color: AppColors
                                                              .primary,
                                                          size: 16),
                                                      const SizedBox(
                                                          width: 6),
                                                      Text(
                                                        'Amount: रु ${notification.meta.totalAmount}',
                                                        style:
                                                            const TextStyle(
                                                          fontSize:
                                                              12,
                                                          color: AppColors
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        // Mark as read button for unread notifications
                                        if (!notification.isRead)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                    top: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .end,
                                              children: [
                                                Container(
                                                  decoration:
                                                      BoxDecoration(
                                                    color: Colors
                                                        .orange
                                                        .withOpacity(
                                                            0.15),
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                8),
                                                    border:
                                                        Border.all(
                                                      color: Colors
                                                          .orange
                                                          .withOpacity(
                                                              0.4),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Material(
                                                    color: Colors
                                                        .transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  8),
                                                      onTap:
                                                          () async {
                                                        try {
                                                          // Show loading state
                                                          ToastService.showToast(
                                                            msg: 'Marking as read...',
                                                            toastLength: Toast.LENGTH_SHORT,
                                                            gravity: ToastGravity.BOTTOM,
                                                            backgroundColor: Colors.grey[600],
                                                            textColor: Colors.white,
                                                          );

                                                          // Call API to mark notification as read
                                                          final success = await context
                                                              .read<
                                                                  NotificationProvider>()
                                                              .markNotificationAsRead(
                                                                  notification.id);

                                                          if (success) {
                                                            // Show success message
                                                            ToastService.showToast(
                                                              msg: 'Marked as read successfully',
                                                              toastLength: Toast.LENGTH_SHORT,
                                                              gravity: ToastGravity.BOTTOM,
                                                              backgroundColor: Colors.green,
                                                              textColor: Colors.white,
                                                            );
                                                            // No need to refresh - provider handles state
                                                          } else {
                                                            // Show error message
                                                            ToastService.showToast(
                                                              msg: context
                                                                  .read<NotificationProvider>()
                                                                  .error,
                                                              toastLength: Toast.LENGTH_SHORT,
                                                              gravity: ToastGravity.BOTTOM,
                                                              backgroundColor: Colors.red,
                                                              textColor: Colors.white,
                                                            );
                                                          }
                                                        } catch (e) {
                                                          // Show error message
                                                          ToastService.showToast(
                                                            msg: 'Error: ${e.toString()}',
                                                            toastLength: Toast.LENGTH_SHORT,
                                                            gravity: ToastGravity.BOTTOM,
                                                            backgroundColor: Colors.red,
                                                            textColor: Colors.white,
                                                          );
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal:
                                                              12,
                                                          vertical: 6,
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize
                                                                  .min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .check_circle_outline,
                                                              color: Colors
                                                                  .orange[700],
                                                              size:
                                                                  16,
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    6),
                                                            Text(
                                                              'Mark as Read',
                                                              style:
                                                                  TextStyle(
                                                                color:
                                                                    Colors.orange[700],
                                                                fontSize:
                                                                    12,
                                                                fontWeight:
                                                                    FontWeight.w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off,
              size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground({
    required IconData icon,
    required Color color,
    required Alignment alignment,
    required String text,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: color.withOpacity(0.15),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
