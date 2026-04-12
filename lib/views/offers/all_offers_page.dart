import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/coupon_provider.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/widgets/coupon_offer_card.dart';

class AllOffersPage extends StatefulWidget {
  const AllOffersPage({super.key});

  @override
  State<AllOffersPage> createState() => _AllOffersPageState();
}

class _AllOffersPageState extends State<AllOffersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().fetchCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      AppColors.primary,
      AppColors.secondary,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Offers'),
      ),
      body: Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          final loading = couponProvider.isLoadingCoupons;
          final error = couponProvider.couponError;
          final coupons = couponProvider.coupons;

          return RefreshIndicator(
            onRefresh: couponProvider.fetchCoupons,
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      )
                    : coupons.isEmpty
                        ? const Center(child: Text('No coupons available'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: coupons.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final coupon = coupons[index];
                              final bg = colors[index % colors.length];
                              return CouponOfferCard(
                                coupon: coupon,
                                backgroundColor: bg,
                              );
                            },
                          ),
          );
        },
      ),
    );
  }
}
