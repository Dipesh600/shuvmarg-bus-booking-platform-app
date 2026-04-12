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


    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Exclusive Offers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
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
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_activity_outlined,
                                    size: 64,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "Oops! No deals hiding here.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Check back later for exclusive Shuvmarg discounts.",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: coupons.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final coupon = coupons[index];
                              return CouponOfferCard(
                                coupon: coupon,
                              );
                            },
                          ),
          );
        },
      ),
    );
  }
}
