import 'package:flutter/material.dart';
import 'package:sumarg/models/trip_response.dart';

class BookSeatsScreen extends StatefulWidget {
  const BookSeatsScreen({super.key, required TripData busData});

  @override
  State<BookSeatsScreen> createState() => _BookSeatsScreenState();
}

class _BookSeatsScreenState extends State<BookSeatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("sets"),
      ),
      body: Center(
        child: Text("book seat"),
      ),
    );
  }
}
