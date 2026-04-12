import 'package:flutter/material.dart';
import 'package:sumarg/views/offers_for_you.dart';
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
    return  Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BussSearchWidget(),
            SizedBox(height: 26),
            RunningStatusWidget(),
            SizedBox(height: 26),
            OffersForYou(),
            SizedBox(height: 26),
            // MoreOptions(),
            // OffersForYou(),
            // Running Status Section
          ],
        ),
      ),
    );
  }
}
