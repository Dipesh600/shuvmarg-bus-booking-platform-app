import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/feedback_provider.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/color_constants.dart';

class BusDetailsScreen extends StatefulWidget {
  final TripData busData;

  const BusDetailsScreen({super.key, required this.busData});

  @override
  State<BusDetailsScreen> createState() => _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch feedback via provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedbackProvider>(context, listen: false).fetchFeedback(
        bussNo: widget.busData.busDetail.busNumber,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final busData = widget.busData;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Bus Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Text(busData.busDetail.busName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${busData.routeDetail.from} → ${busData.routeDetail.to}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Bus Type: ${busData.busDetail.busType}'),
            const SizedBox(height: 8),
            Text('Date: ${busData.tripDate}'),
            const SizedBox(height: 8),
            Text(
                'Departure: ${busData.departureTime}  •  Arrival: ${busData.arrivalTime}'),
            const SizedBox(height: 8),
            Text('Price: Rs. ${busData.tripFare}'),
            const SizedBox(height: 10),
            const Text("Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Reviews list
            Expanded(
              child: Consumer<FeedbackProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoadingFeedback) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error.isNotEmpty) {
                    return Center(
                      child: Text(
                        'Failed to load reviews: ${provider.error}',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    );
                  }
                  final reviews = provider.currentFeedback?.data ?? [];
                  if (reviews.isEmpty) {
                    return const Center(
                      child: Text(
                        'No reviews yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = reviews[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  (r.user?.profilePicture != null &&
                                          r.user!.profilePicture!.isNotEmpty)
                                      ? NetworkImage(r.user!.profilePicture!)
                                      : null,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              child: (r.user?.profilePicture == null ||
                                      r.user!.profilePicture!.isEmpty)
                                  ? Text(
                                      (r.user?.name != null &&
                                              r.user!.name!.isNotEmpty)
                                          ? r.user!.name![0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r.user?.name ?? 'Anonymous',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      RatingBarIndicator(
                                        rating: (r.rating ?? 0).toDouble(),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if ((r.comment ?? '').isNotEmpty)
                                    Text(
                                      r.comment!,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black87),
                                    ),
                                  const SizedBox(height: 6),
                                  Text(
                                    r.createdAt ?? '',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
