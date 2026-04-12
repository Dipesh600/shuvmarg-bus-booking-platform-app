import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/coupon_provider.dart';
import 'package:sumarg/models/reward_history_model.dart';
import 'package:sumarg/utils/color_constants.dart';

class RewardHistoryScreen extends StatefulWidget {
  const RewardHistoryScreen({super.key});

  @override
  State<RewardHistoryScreen> createState() => _RewardHistoryScreenState();
}

class _RewardHistoryScreenState extends State<RewardHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().fetchRewardHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Reward History',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<CouponProvider>().fetchRewardHistory(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          if (couponProvider.isLoadingRewards) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (couponProvider.rewardError.isNotEmpty) {
            return _ErrorView(
              message: couponProvider.rewardError,
              onRetry: () => couponProvider.fetchRewardHistory(),
            );
          }
          final items = couponProvider.rewardHistory;
          if (items.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => couponProvider.fetchRewardHistory(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _RewardCard(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final RewardHistory item;
  const _RewardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isEarn = item.type.toLowerCase() == 'earn';
    final color = isEarn ? Colors.green : Colors.red;
    final sign = isEarn ? '+' : '-';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            isEarn ? Icons.trending_up : Icons.trending_down,
            color: color,
          ),
        ),
        title: Text(
          item.type.isEmpty ? 'Reward' : item.type[0].toUpperCase() + item.type.substring(1),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDate(item.createdAt),
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          '$sign${item.points.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    // yyyy-mm-dd hh:mm
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inbox_outlined, size: 36, color: Colors.grey),
          SizedBox(height: 8),
          Text('No reward history found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
