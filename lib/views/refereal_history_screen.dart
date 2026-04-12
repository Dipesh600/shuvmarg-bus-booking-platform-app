import 'package:flutter/material.dart';
import 'package:sumarg/controllers/referal_controller/referal_controller.dart';
import 'package:sumarg/models/referal_history_response.dart';
import 'package:sumarg/utils/color_constants.dart';

class ReferalHistoryScreen extends StatefulWidget {
  const ReferalHistoryScreen({super.key});

  @override
  State<ReferalHistoryScreen> createState() => _ReferalHistoryScreenState();
}

class _ReferalHistoryScreenState extends State<ReferalHistoryScreen> {
  final ReferalController _controller = ReferalController();
  bool _loading = true;
  String? _error;
  List<ReferalData> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _controller.getReferalHistory();
      if (!mounted) return;
      if (res.status) {
        setState(() {
          _items = res.data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = res.message.isNotEmpty ? res.message : 'Failed to load data';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load data';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral History',style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetch,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 40),
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _fetch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Retry'),
                )
              ],
            ),
          )
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No referral history found.')),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildCard(_items[i]),
    );
  }

  Widget _buildCard(ReferalData item) {
    final date = item.date.toLocal();
    final dateStr = _formatDate(date);
    final statusColor = _statusColor(item.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.referredUser.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.event, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _capitalize(item.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _metricTile(Icons.trending_up, 'Referrer', '+${item.referrerPointsEarned}', Colors.green[600]!)),
                const SizedBox(width: 10),
                Expanded(child: _metricTile(Icons.trending_flat, 'Referred', '+${item.referredUserPoints}', AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$y-$m-$day  ${hh.toString().padLeft(2, '0')}:$mm $ampm';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green[700]!;
      case 'pending':
        return Colors.orange[700]!;
      case 'cancelled':
        return Colors.red[700]!;
      default:
        return AppColors.primary;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}