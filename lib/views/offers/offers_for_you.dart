import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/views/widgets/coupon_offer_card.dart';
import 'package:sumarg/views/offers/all_offers_page.dart';
import 'package:sumarg/views/widgets/status_state_widget.dart';
import 'package:provider/provider.dart';
import '../../providers/coupon_provider.dart';

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Exclusive Offers",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppTheme.textPrimary,
                        fontFamily: AppTheme.fontFamily,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AllOffersPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "SEE ALL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.accentLime,
                        letterSpacing: 1.0,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Offers section (loading/error/first 5 coupons)
            if (loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: AppTheme.accentLime),
              )),
            if (!loading && error.isNotEmpty && !error.toLowerCase().contains("no coupons"))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: StatusStateWidget.error(
                  rawError: error,
                  onRetry: () => Provider.of<CouponProvider>(context, listen: false).fetchCoupons(),
                ),
              ),
            if (!loading && (coupons.isEmpty || error.toLowerCase().contains("no coupons")))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: StatusStateWidget.empty(
                  title: "No deals right now",
                  subtitle: "Check back later for exclusive Shuvmarg discounts.",
                  icon: Icons.local_activity_outlined,
                ),
              ),

            if (!loading && error.isEmpty && coupons.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 240,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  viewportFraction: 0.85,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                ),
                items: coupons.take(5).map((coupon) {
                  return CouponOfferCard(
                    coupon: coupon,
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),
          ],
        );
      },
    );
  }
}
