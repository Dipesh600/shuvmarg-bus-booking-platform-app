import 'package:flutter/material.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/color_constants.dart';

class BusListCommon extends StatelessWidget {
  final List<TripData> busList;
  final void Function(TripData)? onBusTap;

  const BusListCommon({super.key, required this.busList, this.onBusTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: busList.isEmpty
              ? const Center(
                  child: Text(
                    'No buses available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: busList.length,
                  itemBuilder: (context, index) {
                    final bus = busList[index];
                    return _buildPremiumBusCard(context: context, bus: bus, isLast: index == busList.length - 1);
                  },
                ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  // The premium dark teal bus card
  Widget _buildPremiumBusCard({required BuildContext context, required TripData bus, required bool isLast}) {
    return GestureDetector(
      onTap: () {
        if (onBusTap != null) {
          onBusTap!(bus);
        } else {
          _showBusDetails(context, bus);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
        decoration: BoxDecoration(
          color: AppColors.primaryDarkest, // Pure dark background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryDark.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDarkest.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // TOP SECTION: Images & Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bus Image Thumbnail
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primaryDark,
                      image: bus.busDetail.fleetImages.isNotEmpty ? DecorationImage(
                        image: NetworkImage(bus.busDetail.fleetImages.first),
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                    child: bus.busDetail.fleetImages.isEmpty 
                        ? const Icon(Icons.directions_bus, color: AppColors.primaryLight, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  
                  // Title & Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                bus.busDetail.busName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Price Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Rs. ${bus.tripFare}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${bus.busDetail.vehicleType.toUpperCase()} • ${bus.busDetail.busType}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Rating & Reviews
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              bus.busDetail.averageRating > 0 ? bus.busDetail.averageRating.toStringAsFixed(1) : 'New',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${bus.busDetail.totalReviews} Reviews)',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            // TIMELINE SECTION
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: AppColors.primaryDark.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Departure
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.departureTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bus.routeDetail.from,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  
                  // Duration Arrow
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          bus.routeDetail.duration,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight)),
                            Expanded(child: Container(height: 1, color: AppColors.primaryLight.withOpacity(0.5))),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.primaryLight, size: 16),
                            const SizedBox(width: 6),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Arrival
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        bus.arrivalTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bus.routeDetail.to,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // BOTTOM RIBBON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amenities Quick View
                  Row(
                    children: bus.busDetail.amenities.take(3).map((a) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(_getAmenityIcon(a), color: Colors.white.withOpacity(0.7), size: 18),
                      );
                    }).toList(),
                  ),
                  
                  // Seats Left Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: bus.availableSeats > 10 ? AppColors.primary.withOpacity(0.2) : AppColors.secondary.withOpacity(0.15),
                      border: Border.all(color: bus.availableSeats > 10 ? AppColors.primary : AppColors.secondary, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_seat_rounded, size: 14, color: bus.availableSeats > 10 ? AppColors.primaryLight : AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          '${bus.availableSeats} Seats Left',
                          style: TextStyle(
                            color: bus.availableSeats > 10 ? Colors.white : AppColors.secondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'ac':
        return Icons.ac_unit_outlined;
      case 'wifi':
        return Icons.wifi;
      case 'charging port':
        return Icons.power_outlined;
      case 'blanket':
        return Icons.blinds_closed_outlined;
      case 'water bottle':
        return Icons.water_drop_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  void _showBusDetails(BuildContext context, TripData bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.primaryDarkest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: bus.busDetail.fleetImages.isNotEmpty ? DecorationImage(
                        image: NetworkImage(bus.busDetail.fleetImages.first),
                        fit: BoxFit.cover,
                      ) : null,
                      color: AppColors.primaryDark,
                    ),
                    child: bus.busDetail.fleetImages.isEmpty ? const Icon(Icons.directions_bus, color: Colors.white, size: 28) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.busDetail.busName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bus.busDetail.busNumber,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.primaryDark, height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Route', '${bus.routeDetail.from} → ${bus.routeDetail.to}'),
                    _buildDetailRow('Date', bus.tripDate),
                    _buildDetailRow('Departure', bus.departureTime),
                    _buildDetailRow('Arrival', bus.arrivalTime),
                    _buildDetailRow('Duration', bus.routeDetail.duration),
                    _buildDetailRow('Price', 'Rs. ${bus.tripFare}'),
                    _buildDetailRow('Available Seats', '${bus.availableSeats}/${bus.busDetail.totalSeats}'),
                    _buildDetailRow('Shift', bus.shift.toUpperCase()),
                    const SizedBox(height: 24),
                    const Text('Amenities', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: bus.busDetail.amenities.map((amenity) => _buildAmenityChip(amenity)).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getAmenityIcon(amenity), size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            amenity,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
