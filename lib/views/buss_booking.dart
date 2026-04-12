import 'package:flutter/material.dart';
import 'package:sumarg/views/buss_ticket_search_screen.dart';

class BussScreen extends StatefulWidget {
  const BussScreen({super.key});

  @override
  State<BussScreen> createState() => _BussScreenState();
}

class _BussScreenState extends State<BussScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: const [
            SizedBox(
              height: 600,
              child: BusTicketSearchScreen(),
            )
          ],
        ),
      ),
    );
  }
}
