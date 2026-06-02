import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/utils/toast_service.dart';
import 'package:sumarg/widgets/custom_toast.dart';
import 'package:sumarg/providers/notification_provider.dart';
import 'package:sumarg/widgets/glass_card.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends State<NotificationHistoryScreen> {
  final List<String> _categories = ['All', 'Bookings', 'Offers', 'System'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'trip':
        return Icons.confirmation_num_outlined;
      case 'offer':
      case 'discount':
        return Icons.local_offer_outlined;
      case 'system':
      case 'update':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'trip':
        return AppTheme.accentLime;
      case 'offer':
      case 'discount':
        return const Color(0xFFFFB347); // amber
      case 'system':
      case 'update':
        return const Color(0xFF60CFFF); // cyan
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  // ── Mark / Delete helpers ────────────────────────────────────────────────────

  Future<void> _markRead(BuildContext ctx, String id) async {
    final success =
        await ctx.read<NotificationProvider>().markNotificationAsRead(id);
    if (!ctx.mounted) return;
    ToastService.showToast(
      context: ctx,
      type: success ? ToastType.success : ToastType.error,
      msg: success ? 'Marked as read' : ctx.read<NotificationProvider>().error,
    );
  }

  Future<void> _delete(BuildContext ctx, String id) async {
    final success =
        await ctx.read<NotificationProvider>().deleteNotification(id);
    if (!ctx.mounted) return;
    ToastService.showToast(
      context: ctx,
      type: success ? ToastType.success : ToastType.error,
      msg: success
          ? 'Notification deleted'
          : ctx.read<NotificationProvider>().error,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildCategoryFilter(),
              const SizedBox(height: 4),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.stroke),
                color: Colors.white.withOpacity(0.04),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppTheme.textPrimary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          // Mark all read
          Consumer<NotificationProvider>(
            builder: (context, np, _) {
              final hasUnread =
                  np.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () async {
                  for (final n in np.notifications.where((n) => !n.isRead)) {
                    await np.markNotificationAsRead(n.id);
                  }
                  if (context.mounted) {
                    ToastService.showToast(
                      context: context,
                      type: ToastType.success,
                      msg: 'All marked as read',
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLime.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.accentLime.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentLime,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Category filter pills ────────────────────────────────────────────────────

  Widget _buildCategoryFilter() {
    return Consumer<NotificationProvider>(
      builder: (context, np, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _categories.map((cat) {
              final selected = np.selectedCategory == cat;
              return GestureDetector(
                onTap: () => np.setSelectedCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.accentLime.withOpacity(0.15)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppTheme.accentLime.withOpacity(0.5)
                          : AppTheme.stroke,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppTheme.accentLime
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Consumer<NotificationProvider>(
      builder: (context, np, _) {
        if (np.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentLime),
          );
        }

        if (np.error.isNotEmpty) {
          return _buildErrorState(context, np);
        }

        if (np.notifications.isEmpty) {
          return _buildEmptyState();
        }

        final filtered = np.filteredNotifications;
        if (filtered.isEmpty) {
          return _buildEmptyCategoryState();
        }

        return RefreshIndicator(
          color: AppTheme.accentLime,
          backgroundColor: AppTheme.cardBg,
          onRefresh: np.refreshNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final n = filtered[index];
              return _buildNotificationCard(context, n);
            },
          ),
        );
      },
    );
  }

  // ── Notification card ─────────────────────────────────────────────────────────

  Widget _buildNotificationCard(BuildContext ctx, dynamic n) {
    final typeColor = _getTypeColor(n.type);
    final isUnread = !n.isRead;

    return Dismissible(
      key: ValueKey(n.id),
      direction: n.isRead
          ? DismissDirection.endToStart
          : DismissDirection.horizontal,
      background: _buildSwipeBg(
        icon: Icons.check_circle_outline,
        color: AppTheme.accentLime,
        alignment: Alignment.centerLeft,
        label: 'Mark Read',
      ),
      secondaryBackground: _buildSwipeBg(
        icon: Icons.delete_outline,
        color: const Color(0xFFFF4444),
        alignment: Alignment.centerRight,
        label: 'Delete',
      ),
      onDismissed: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          await _markRead(ctx, n.id);
        } else {
          await _delete(ctx, n.id);
        }
      },
      child: GestureDetector(
        onTap: () async {
          if (isUnread) await _markRead(ctx, n.id);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isUnread
                ? typeColor.withOpacity(0.06)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnread
                  ? typeColor.withOpacity(0.25)
                  : AppTheme.stroke,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: icon + title + badge ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: typeColor.withOpacity(0.3)),
                      ),
                      child: Icon(
                        _getTypeIcon(n.type),
                        color: typeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title + timestamp
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _formatDate(n.createdAt),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Read / Unread badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUnread
                            ? typeColor.withOpacity(0.12)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isUnread
                              ? typeColor.withOpacity(0.4)
                              : AppTheme.stroke,
                        ),
                      ),
                      child: Text(
                        isUnread ? 'New' : 'Read',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isUnread ? typeColor : AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Row 2: message body ──
                Text(
                  n.message,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),

                // ── Row 3: Meta chip row (seats / amount) ──
                if (n.meta.seats.isNotEmpty || n.meta.totalAmount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.stroke),
                    ),
                    child: Row(
                      children: [
                        if (n.meta.seats.isNotEmpty) ...[
                          Icon(Icons.event_seat_outlined,
                              size: 14, color: AppTheme.accentLime),
                          const SizedBox(width: 6),
                          Text(
                            'Seats: ${n.meta.seats.join(", ")}',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentLime,
                            ),
                          ),
                        ],
                        if (n.meta.seats.isNotEmpty &&
                            n.meta.totalAmount > 0)
                          Container(
                            width: 1,
                            height: 14,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10),
                            color: AppTheme.stroke,
                          ),
                        if (n.meta.totalAmount > 0) ...[
                          Icon(Icons.payments_outlined,
                              size: 14, color: AppTheme.accentLime),
                          const SizedBox(width: 6),
                          Text(
                            'रु ${n.meta.totalAmount}',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentLime,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // ── Row 4: "Mark as read" button (unread only) ──
                if (isUnread) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _markRead(ctx, n.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentLime.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  AppTheme.accentLime.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 14, color: AppTheme.accentLime),
                            SizedBox(width: 5),
                            Text(
                              'Mark as read',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentLime,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Swipe background ─────────────────────────────────────────────────────────

  Widget _buildSwipeBg({
    required IconData icon,
    required Color color,
    required AlignmentGeometry alignment,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty / Error states ─────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentLime.withOpacity(0.08),
                  border: Border.all(
                      color: AppTheme.accentLime.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 36,
                  color: AppTheme.accentLime,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No notifications yet',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You're all caught up!\nWe'll notify you when something new arrives.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCategoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off_rounded,
              size: 52, color: AppTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'Nothing in this category',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try selecting a different category',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext ctx, NotificationProvider np) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF4444).withOpacity(0.1),
                  border: Border.all(
                      color: const Color(0xFFFF4444).withOpacity(0.3)),
                ),
                child: const Icon(Icons.error_outline_rounded,
                    size: 34, color: Color(0xFFFF6B6B)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                np.error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: np.loadNotifications,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLime.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.accentLime.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentLime,
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
}
