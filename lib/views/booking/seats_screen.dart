import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/seatas_controller/seats_provider.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/booking/proceeding_to_checkout.dart';
import 'package:sumarg/views/booking/seats_policy_info.dart';
import 'package:sumarg/views/booking/bus_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final TripData busData;

  const SeatSelectionScreen({super.key, required this.busData});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Defer initialization to after the first frame to avoid
    // notifyListeners() during build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProviderAndFetchSeats();
    });
  }

  Future<void> _initProviderAndFetchSeats() async {
    final provider = Provider.of<SeatSelectionProvider>(context, listen: false);

    // Reset state and set trip-specific price
    provider.clearSeats();
    provider.setPricePerSeat(widget.busData.tripFare);

    // Fetch seats
    await provider.fetchSeats(widget.busData.id);

    // Error handling is now done directly in the UI body using provider.error
  }

  void _onCheckoutPressed(BuildContext context, int totalPrice) {
    final selectedSeats =
        context.read<SeatSelectionProvider>().selectedSeats.join(", ");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proceeding to checkout with: $selectedSeats')),
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProceedingToCheckout(
                  totalPrice: totalPrice,
                  selectedSeats: selectedSeats,
                  busData: widget.busData,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SeatSelectionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title:
                const Text("Book Seats", style: TextStyle(color: Colors.white)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SeatsPolicyInfo()),
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(
                  width: 2, color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: ${provider.totalPrice}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                ElevatedButton(
                  onPressed: provider.selectedSeats.isEmpty
                      ? null
                      : () => _onCheckoutPressed(context, provider.totalPrice),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.selectedSeats.isEmpty
                        ? Colors.grey
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    children: [
                      Text("Checkout",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.seatResponse == null ||
                      provider.seatResponse!.data == null
                  ? Center(
                      child: Text(
                        provider.error.isNotEmpty
                            ? provider.error
                            : 'No seats available',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: [
                        // Simple Bus Details Section
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BusDetailsScreen(
                                  busData: widget.busData,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(8),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Bus Name
                                    Text(
                                      widget.busData.busDetail.busName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Route
                                    Text(
                                      "${widget.busData.routeDetail.from} - ${widget.busData.routeDetail.to}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Date
                                    Text(
                                      widget.busData.tripDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Amenities
                                    if (widget.busData.busDetail.amenities
                                        .isNotEmpty) ...[
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_offer,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              widget.busData.busDetail.amenities
                                                  .join(", "),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Seat Selection Content
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem(Icons.event_seat,
                                        Colors.grey, "Booked"),
                                    const SizedBox(width: 16),
                                    _buildLegendItem(Icons.event_seat,
                                        Colors.green, "Available"),
                                    const SizedBox(width: 16),
                                    _buildLegendItem(Icons.event_seat,
                                        Colors.red, "Selected"),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                _buildSeat("Sp. M1", true),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Expanded(
                                              child: GridView.count(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 8,
                                                mainAxisSpacing: 8,
                                                childAspectRatio: 1.2,
                                                children: provider
                                                    .seatResponse!.data!.seata
                                                    .map((seat) {
                                                  return _buildSeat(
                                                      seat.seatNo.toUpperCase(),
                                                      seat.booked);
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.drive_eta,
                                                    size: 40,
                                                    color: Colors.black54),
                                                SizedBox(width: 8),
                                                Text("Driver",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Expanded(
                                              child: GridView.count(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 8,
                                                mainAxisSpacing: 8,
                                                childAspectRatio: 1.2,
                                                children: provider
                                                    .seatResponse!.data!.seatb
                                                    .map((seat) {
                                                  return _buildSeat(
                                                      seat.seatNo.toUpperCase(),
                                                      seat.booked);
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Seat C row (last row)
                                if (provider
                                    .seatResponse!.data!.seatc.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Column(
                                      children: [
                                        const Text("Back Row",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 70,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: provider.seatResponse!
                                                .data!.seatc.length,
                                            itemBuilder: (context, index) {
                                              final seat = provider
                                                  .seatResponse!
                                                  .data!
                                                  .seatc[index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                child: SizedBox(
                                                  width: 60,
                                                  child: _buildSeat(
                                                      seat.seatNo.toUpperCase(),
                                                      seat.booked),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildSeat(String seatLabel, bool isBooked) {
    return Consumer<SeatSelectionProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.isSelected(seatLabel);
        return GestureDetector(
          onTap: isBooked ? null : () => provider.toggleSeat(seatLabel),
          child: Container(
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.grey[300]
                  : isSelected
                      ? Colors.red[400]
                      : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isBooked ? Colors.grey : Colors.green,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_seat,
                    color: isBooked
                        ? Colors.grey[600]
                        : isSelected
                            ? Colors.white
                            : Colors.green,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seatLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isBooked
                          ? Colors.grey[600]
                          : isSelected
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
