import 'package:flutter/material.dart';
import '../../utils/color_constants.dart';

class LiveBusData {
  final String busId;
  final String busName;
  final String registrationNumber;
  final String from;
  final String to;
  final String currentStatus;
  final String delayTime;
  final String currentLocation;
  final String estimatedArrival;
  final int availableSeats;
  final double price;
  final String operatorName;
  final String departureTime;
  final String arrivalTime;

  LiveBusData({
    required this.busId,
    required this.busName,
    required this.registrationNumber,
    required this.from,
    required this.to,
    required this.currentStatus,
    required this.delayTime,
    required this.currentLocation,
    required this.estimatedArrival,
    required this.availableSeats,
    required this.price,
    required this.operatorName,
    required this.departureTime,
    required this.arrivalTime,
  });
}

class LiveBusSearchScreen extends StatefulWidget {
  const LiveBusSearchScreen({super.key});

  @override
  State<LiveBusSearchScreen> createState() =>
      _LiveBusSearchScreenState();
}

class _LiveBusSearchScreenState extends State<LiveBusSearchScreen> {
  final TextEditingController _searchController =
      TextEditingController();
  List<LiveBusData> _allBuses = [];
  List<LiveBusData> _filteredBuses = [];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
    _filterBuses();
  }

  void _loadDummyData() {
    _allBuses = [
      LiveBusData(
        busId: '1',
        busName: 'Sumarg Express',
        registrationNumber: 'BA-1-PA-1234',
        from: 'Kathmandu',
        to: 'Pokhara',
        currentStatus: 'On Time',
        delayTime: '',
        currentLocation: 'Naubise',
        estimatedArrival: '01:45 PM',
        availableSeats: 12,
        price: 850.0,
        operatorName: 'Sumarg Bus Service',
        departureTime: '07:00 AM',
        arrivalTime: '02:00 PM',
      ),
      LiveBusData(
        busId: '2',
        busName: 'Green Line Deluxe',
        registrationNumber: 'BA-1-PA-5678',
        from: 'Kathmandu',
        to: 'Pokhara',
        currentStatus: 'Delayed',
        delayTime: '30 min',
        currentLocation: 'Kurintar',
        estimatedArrival: '03:45 PM',
        availableSeats: 5,
        price: 950.0,
        operatorName: 'Green Line Express',
        departureTime: '08:30 AM',
        arrivalTime: '03:30 PM',
      ),
      LiveBusData(
        busId: '3',
        busName: 'Sajha Yatayat',
        registrationNumber: 'BA-1-PA-9012',
        from: 'Kathmandu',
        to: 'Pokhara',
        currentStatus: 'Started',
        delayTime: '',
        currentLocation: 'Pokhara Bus Park',
        estimatedArrival: '12:45 PM',
        availableSeats: 0,
        price: 750.0,
        operatorName: 'Sajha Yatayat',
        departureTime: '06:00 AM',
        arrivalTime: '01:00 PM',
      ),
    ];
  }

  void _filterBuses() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredBuses = _allBuses;
      } else {
        _filteredBuses = _allBuses.where((bus) {
          return bus.busName
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              bus.registrationNumber
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              bus.from
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              bus.to
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
        }).toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'On Time':
        return Colors.green;
      case 'Delayed':
        return Colors.orange;
      case 'Started':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Live Bus Search'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterBuses(),
              decoration: InputDecoration(
                hintText:
                    'Search by bus name, registration number, or route...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.primary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.white,
              ),
            ),
          ),
          Expanded(
            child: _filteredBuses.isEmpty
                ? const Center(child: Text('No buses found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBuses.length,
                    itemBuilder: (context, index) =>
                        _buildBusCard(_filteredBuses[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(LiveBusData bus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.busName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Text(
                        bus.registrationNumber,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(bus.operatorName,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(bus.currentStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bus.currentStatus,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Route Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.location_on,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(bus.from,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.location_on,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text(bus.to,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${bus.departureTime} - ${bus.arrivalTime}'),
                    Text('ETA: ${bus.estimatedArrival}',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Mini Route Map
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryLightest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 40,
                  right: 20,
                  child: Container(
                      height: 2, color: AppColors.primaryLight),
                ),
                Positioned(
                  left: 20,
                  top: 30,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 30,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned(
                  left: 20 +
                      (MediaQuery.of(context).size.width - 80) * 0.6,
                  top: 30,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 8)
                      ],
                    ),
                    child: const Icon(Icons.gps_fixed,
                        color: AppColors.white, size: 12),
                  ),
                ),
                Positioned(
                  left: 20 +
                      (MediaQuery.of(context).size.width - 80) * 0.6 -
                      30,
                  top: 60,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bus.currentLocation,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Price and Seats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${bus.availableSeats} seats available'),
                Text('Rs. ${bus.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // View Details Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () =>
                    print("Viewing details for: ${bus.busName}"),
                icon: const Icon(Icons.visibility),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
