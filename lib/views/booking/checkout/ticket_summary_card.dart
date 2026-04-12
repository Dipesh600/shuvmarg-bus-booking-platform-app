import 'package:flutter/material.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/color_constants.dart';

/// Displays the ticket summary card with route, time, seats, date, passenger, and bus info.
class TicketSummaryCard extends StatelessWidget {
  final TripData busData;
  final String selectedSeats;
  final String passengerName;

  const TicketSummaryCard({
    super.key,
    required this.busData,
    required this.selectedSeats,
    required this.passengerName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Route and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      busData.departureTime,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      busData.routeDetail.from,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(
                      color: AppColors.secondary,
                      thickness: 2,
                      height: 20,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      busData.arrivalTime,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      busData.routeDetail.to,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Selected Seats",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(selectedSeats,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date and Booking Time
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Date",
                          style: TextStyle(color: Colors.grey)),
                      Text(busData.tripDate),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Booking Time",
                          style: TextStyle(color: Colors.grey)),
                      Text("11:25 AM"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Passenger Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Passenger",
                        style: TextStyle(color: Colors.grey)),
                    Text(passengerName),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bus Name",
                        style: TextStyle(color: Colors.grey)),
                    Text(busData.busDetail.busName),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Bus No",
                        style: TextStyle(color: Colors.grey)),
                    Text(busData.busDetail.busNumber),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
