import 'package:flutter/material.dart';
import '../../utils/color_constants.dart';

// Live Bus Data Model
class LiveBusData {
  final String busId;
  final String busNumber;
  final String operatorName;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String currentLocation;
  final String nextStop;
  final String estimatedArrival;
  final LiveStatus status;
  final int availableSeats;
  final double price;
  final String vehicleType;
  final String thumbnail;

  LiveBusData({
    required this.busId,
    required this.busNumber,
    required this.operatorName,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.currentLocation,
    required this.nextStop,
    required this.estimatedArrival,
    required this.status,
    required this.availableSeats,
    required this.price,
    required this.vehicleType,
    required this.thumbnail,
  });
}

enum LiveStatus {
  onTime,
  delayed,
  departed,
  arrived,
  cancelled,
  boarding,
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
  String _selectedFilter = 'All';
  List<LiveBusData> _allBuses = [];
  List<LiveBusData> _filteredBuses = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _filterBuses();
  }

  void _loadMockData() {
    _allBuses = [
      LiveBusData(
        busId: '1',
        busNumber: 'BA-1-1234',
        operatorName: 'Sumarg Bus Service',
        from: 'Kathmandu',
        to: 'Pokhara',
        departureTime: '07:00 AM',
        arrivalTime: '02:00 PM',
        currentLocation: 'Naubise',
        nextStop: 'Damauli',
        estimatedArrival: '01:45 PM',
        status: LiveStatus.onTime,
        availableSeats: 12,
        price: 850.0,
        vehicleType: 'AC Bus',
        thumbnail: 'assets/busses/buss-1.jpg',
      ),
      LiveBusData(
        busId: '2',
        busNumber: 'BA-1-5678',
        operatorName: 'Green Line Express',
        from: 'Kathmandu',
        to: 'Pokhara',
        departureTime: '08:30 AM',
        arrivalTime: '03:30 PM',
        currentLocation: 'Kurintar',
        nextStop: 'Muglin',
        estimatedArrival: '03:15 PM',
        status: LiveStatus.delayed,
        availableSeats: 5,
        price: 950.0,
        vehicleType: 'Luxury Bus',
        thumbnail: 'assets/busses/buss-2.png',
      ),
      LiveBusData(
        busId: '3',
        busNumber: 'BA-1-9012',
        operatorName: 'Sajha Yatayat',
        from: 'Kathmandu',
        to: 'Pokhara',
        departureTime: '06:00 AM',
        arrivalTime: '01:00 PM',
        currentLocation: 'Pokhara Bus Park',
        nextStop: 'Final Destination',
        estimatedArrival: '12:45 PM',
        status: LiveStatus.arrived,
        availableSeats: 0,
        price: 750.0,
        vehicleType: 'Regular Bus',
        thumbnail: 'assets/busses/buss-3.jpeg',
      ),
      LiveBusData(
        busId: '4',
        busNumber: 'BA-1-3456',
        operatorName: 'Nepal Yatayat',
        from: 'Kathmandu',
        to: 'Pokhara',
        departureTime: '09:00 AM',
        arrivalTime: '04:00 PM',
        currentLocation: 'Departure Terminal',
        nextStop: 'Naubise',
        estimatedArrival: '04:00 PM',
        status: LiveStatus.boarding,
        availableSeats: 18,
        price: 800.0,
        vehicleType: 'AC Bus',
        thumbnail: 'assets/busses/buss-4.jpeg',
      ),
      LiveBusData(
        busId: '5',
        busNumber: 'BA-1-7890',
        operatorName: 'Express Bus Service',
        from: 'Kathmandu',
        to: 'Pokhara',
        departureTime: '07:30 AM',
        arrivalTime: '02:30 PM',
        currentLocation: 'Muglin',
        nextStop: 'Pokhara Bus Park',
        estimatedArrival: '02:15 PM',
        status: LiveStatus.onTime,
        availableSeats: 8,
        price: 900.0,
        vehicleType: 'Luxury Bus',
        thumbnail: 'assets/busses/buss-5.jpg',
      ),
    ];
  }

  void _filterBuses() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredBuses = _allBuses;
      } else {
        _filteredBuses = _allBuses.where((bus) {
          switch (_selectedFilter) {
            case 'On Time':
              return bus.status == LiveStatus.onTime;
            case 'Delayed':
              return bus.status == LiveStatus.delayed;
            case 'Boarding':
              return bus.status == LiveStatus.boarding;
            case 'Arrived':
              return bus.status == LiveStatus.arrived;
            default:
              return true;
          }
        }).toList();
      }

      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        _filteredBuses = _filteredBuses.where((bus) {
          return bus.busNumber
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              bus.operatorName
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

  Color _getStatusColor(LiveStatus status) {
    switch (status) {
      case LiveStatus.onTime:
        return Colors.green;
      case LiveStatus.delayed:
        return Colors.orange;
      case LiveStatus.departed:
        return Colors.blue;
      case LiveStatus.arrived:
        return Colors.green;
      case LiveStatus.cancelled:
        return Colors.red;
      case LiveStatus.boarding:
        return Colors.purple;
    }
  }

  String _getStatusText(LiveStatus status) {
    switch (status) {
      case LiveStatus.onTime:
        return 'On Time';
      case LiveStatus.delayed:
        return 'Delayed';
      case LiveStatus.departed:
        return 'Departed';
      case LiveStatus.arrived:
        return 'Arrived';
      case LiveStatus.cancelled:
        return 'Cancelled';
      case LiveStatus.boarding:
        return 'Boarding';
    }
  }

  IconData _getStatusIcon(LiveStatus status) {
    switch (status) {
      case LiveStatus.onTime:
        return Icons.check_circle;
      case LiveStatus.delayed:
        return Icons.schedule;
      case LiveStatus.departed:
        return Icons.departure_board;
      case LiveStatus.arrived:
        return Icons.location_on;
      case LiveStatus.cancelled:
        return Icons.cancel;
      case LiveStatus.boarding:
        return Icons.people;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text(
          'Live Bus Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _filterBuses();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterBuses(),
                  decoration: InputDecoration(
                    hintText:
                        'Search by bus number, operator, or route...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('On Time'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Delayed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Boarding'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Arrived'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Results Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            color: AppColors.primaryLightest,
            child: Text(
              '${_filteredBuses.length} buses found',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          // Bus List
          Expanded(
            child: _filteredBuses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBuses.length,
                    itemBuilder: (context, index) {
                      return _buildBusCard(_filteredBuses[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.white : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
          _filterBuses();
        });
      },
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.white,
      side: BorderSide(
        color:
            isSelected ? AppColors.primary : AppColors.primaryLight,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Status Badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(bus.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Bus Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(bus.thumbnail),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bus Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.busNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bus.operatorName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bus.vehicleType,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(bus.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(bus.status),
                        color: AppColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(bus.status),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Route and Time Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Route Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                bus.from,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                bus.to,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Time Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${bus.departureTime} - ${bus.arrivalTime}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Duration: ${bus.estimatedArrival}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Live Location Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gps_fixed,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current: ${bus.currentLocation}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Next: ${bus.nextStop}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'ETA: ${bus.estimatedArrival}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Price and Seats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.airline_seat_recline_normal,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${bus.availableSeats} seats available',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${bus.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement track bus functionality
                    },
                    icon: const Icon(Icons.location_on, size: 16),
                    label: const Text('Track Bus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side:
                          const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement book seat functionality
                    },
                    icon: const Icon(Icons.event_seat, size: 16),
                    label: const Text('Book Seat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No buses found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.5),
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
