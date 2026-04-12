import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../utils/color_constants.dart';
import 'package:sumarg/widgets/coupon_offer_card.dart';
import 'package:sumarg/views/all_offers_page.dart';
import 'package:provider/provider.dart';
import '../providers/coupon_provider.dart';

class OffersForYou extends StatefulWidget {
  const OffersForYou({super.key});

  @override
  State<OffersForYou> createState() => _OffersForYouState();
}

class _OffersForYouState extends State<OffersForYou> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().fetchCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        final loading = couponProvider.isLoadingCoupons;
        final error = couponProvider.couponError;
        final coupons = couponProvider.coupons;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Offers For You",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  loading
                      ? "Loading..."
                      : error.isNotEmpty
                          ? "0 offers available"
                          : "${coupons.length} offers available",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Offers section (loading/error/first 5 coupons)
            if (loading)
              const Center(child: CircularProgressIndicator()),
            if (!loading && error.isNotEmpty)
              Center(
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (!loading && error.isEmpty && coupons.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 320,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayInterval: const Duration(seconds: 4),
                  viewportFraction: 0.85,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration:
                      const Duration(milliseconds: 800),
                ),
                items: coupons.take(5).map((coupon) {
                  final colorPalette = <Color>[
                    AppColors.primary,
                    AppColors.secondary,
                    Colors.green,
                    Colors.purple,
                    Colors.orange,
                  ];
                  final idx = coupons.indexOf(coupon) % colorPalette.length;
                  final bg = colorPalette[idx];
                  return CouponOfferCard(
                    coupon: coupon,
                    backgroundColor: bg,
                  );
                }).toList(),
              ),

            const SizedBox(height: 10),

            // View All Offers Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AllOffersPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.local_offer),
                label: const Text(
                  "View All Offers",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        );
      },
    );
  }
}
