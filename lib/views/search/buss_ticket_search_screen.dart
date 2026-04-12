import 'package:flutter/material.dart';
import 'package:sumarg/views/offers/offers_for_you.dart';
import 'package:sumarg/views/widgets/buss_search_widget.dart';
import 'package:sumarg/views/widgets/running_status_widget.dart';

class BusTicketSearchScreen extends StatefulWidget {
  const BusTicketSearchScreen({super.key});

  @override
  State<BusTicketSearchScreen> createState() =>
      _BusTicketSearchScreenState();
}

class _BusTicketSearchScreenState
    extends State<BusTicketSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BussSearchWidget(),
          const SizedBox(height: 26),
          // We will update RunningStatus and Offers separately
          // const RunningStatusWidget(),
          // const SizedBox(height: 26),
          const OffersForYou(),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}
