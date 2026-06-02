import 'package:flutter/material.dart';
import 'package:sumarg/controllers/coupon_controller/coupon_controller.dart';
import 'package:sumarg/models/get_coupn_respnse_model.dart' as list_model;
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/views/widgets/coupon_offer_card.dart';
import 'package:sumarg/views/widgets/status_state_widget.dart';
import 'dart:async';

class AllOffersPage extends StatefulWidget {
  const AllOffersPage({super.key});

  @override
  State<AllOffersPage> createState() => _AllOffersPageState();
}

class _AllOffersPageState extends State<AllOffersPage> {
  final CouponController _controller = CouponController();
  List<list_model.Coupon> _coupons = [];
  bool _loading = true;
  String _error = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetch();
    // Auto-refresh every 5 minutes silently
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => _fetch(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetch({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loading = _coupons.isEmpty;
        _error = '';
      });
    }
    try {
      final res = await _controller.getAllCouponsWithExpired();
      if (!mounted) return;
      setState(() {
        if (res.success) {
          _coupons = res.data;
          _error = '';
        } else {
          _error = res.message;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Split into active and expired for section headers
    final now = DateTime.now();
    final active = _coupons.where((c) => now.isBefore(c.validTo)).toList();
    final expired = _coupons.where((c) => now.isAfter(c.validTo)).toList();

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: const Text(
          'All Offers',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.accentLime,
        backgroundColor: AppTheme.primaryDarker,
        onRefresh: () => _fetch(),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accentLime))
            : _error.isNotEmpty && !_error.toLowerCase().contains("no coupons")
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
                        child: StatusStateWidget.error(
                          rawError: _error,
                          onRetry: () => _fetch(),
                        ),
                      ),
                    ],
                  )
                : (_coupons.isEmpty || _error.toLowerCase().contains("no coupons"))
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 60),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: StatusStateWidget.empty(
                              title: "No offers yet",
                              subtitle: "Check back later for exclusive Shuvmarg discounts.",
                              icon: Icons.local_activity_outlined,
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          // ── ACTIVE OFFERS ──────────────────────────────
                          if (active.isNotEmpty) ...[
                            _SectionHeader(
                              label: 'Active Offers',
                              count: active.length,
                              color: AppTheme.accentLime,
                            ),
                            ...active.map((c) => CouponOfferCard(coupon: c)),
                            const SizedBox(height: 8),
                          ],

                          // ── EXPIRED OFFERS ─────────────────────────────
                          if (expired.isNotEmpty) ...[
                            _SectionHeader(
                              label: 'Expired Offers',
                              count: expired.length,
                              color: AppTheme.textSecondary,
                            ),
                            ...expired.map((c) => CouponOfferCard(coupon: c)),
                          ],

                          const SizedBox(height: 32),
                        ],
                      ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SectionHeader(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
