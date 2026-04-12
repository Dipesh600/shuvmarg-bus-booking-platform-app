import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/widgets/bus_list_common.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/providers/ticket_provider.dart';
import 'package:sumarg/controllers/auth_controller/login_provider.dart';
import 'package:sumarg/views/booking/seats_screen.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/utils/navigation_service.dart';

class AvailableBussesScreen extends StatefulWidget {
  const AvailableBussesScreen({super.key});

  @override
  State<AvailableBussesScreen> createState() => _AvailableBussesScreenState();
}

class _AvailableBussesScreenState extends State<AvailableBussesScreen> {
  late Future<TripResponse> _searchFuture;
  bool _isLoading = false;

  // Filter variables
  String _selectedFilter = 'None';
  List<TripData>? _sortedBusResults;
  RangeValues _priceRange = const RangeValues(500, 2000);
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // Date selection variables
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _availableDates = [];

  @override
  void initState() {
    super.initState();
    _generateAvailableDates();
    _performSearch();
    _minPriceController.text = '500';
    _maxPriceController.text = '2000';
  }

  void _generateAvailableDates() {
    final today = DateTime.now();

    // Generate dates from today onwards (7 days)
    _availableDates = [];
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      _availableDates.add(date);
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _isLoading = true;
    });

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    // Use selected date
    final formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    // Search data with selected date
    final searchData = {
      "date": formattedDate,
      "shift": ["day", "night"]
    };
    debugPrint('Search POST data: $searchData');

    _searchFuture = ticketProvider.searchTicket(searchData);
    _searchFuture.then((_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      print("Search error: $error");
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _performSearch(); // Search for buses on selected date
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Future<void> _showDatePicker() async {
    final today = DateTime.now();
    final todayStart =
        DateTime(today.year, today.month, today.day); // Start of today
    final lastDate = todayStart.add(const Duration(days: 6));
    final initialPickerDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialPickerDate,
      firstDate: todayStart, // Disable all dates before today
      lastDate: lastDate, // Allow only up to 7 days including today
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              onSurfaceVariant: Colors.grey[400], // Disabled dates color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _onDateSelected(picked);
      // Scroll to selected date in horizontal list if it's within the 10-day range
      final today = DateTime.now();
      final daysDifference = picked.difference(today).inDays;
      if (daysDifference >= 0 && daysDifference < 10) {
        // The date is within our 10-day range, so it will be visible in the horizontal list
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Optional: Add scroll animation to the selected date
        });
      }
    }
  }

  void _handleBusTap(TripData bus) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (loginProvider.isLoggedIn) {
      // User is logged in, go directly to seat selection
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatSelectionScreen(busData: bus),
        ),
      );
    } else {
      // Store redirect information for seat booking
      await NavigationService.storeRedirectData(
        redirectType: NavigationService.redirectTypeSeatBooking,
        data: {
          'busId': bus.id,
          'searchData': {
            "date":
                "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
            "shift": ["day", "night"]
          },
          'screen': 'seat_booking',
          'busName': bus.busDetail.busName,
          'busNo': bus.busDetail.busNumber,
          'from': bus.routeDetail.from,
          'to': bus.routeDetail.to,
          'departureTime': bus.departureTime,
          'arrivalTime': bus.arrivalTime,
          'date': bus.tripDate,
          'price': bus.tripFare,
        },
      );

      // Navigate to login screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                // Price Range Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RangeSlider(
                        values: _priceRange,
                        min: 500,
                        max: 2000,
                        divisions: 15,
                        labels: RangeLabels(
                          'Rs. ${_priceRange.start.round()}',
                          'Rs. ${_priceRange.end.round()}',
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _priceRange = values;
                            _minPriceController.text =
                                values.start.round().toString();
                            _maxPriceController.text =
                                values.end.round().toString();
                          });
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Min Price',
                                prefixText: 'Rs. ',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final minPrice = int.tryParse(value) ?? 500;
                                setState(() {
                                  _priceRange = RangeValues(
                                    minPrice.toDouble(),
                                    _priceRange.end,
                                  );
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Price',
                                prefixText: 'Rs. ',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final maxPrice = int.tryParse(value) ?? 2000;
                                setState(() {
                                  _priceRange = RangeValues(
                                    _priceRange.start,
                                    maxPrice.toDouble(),
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Sort Options Section
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: const Text('Price: Low to High'),
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Price: Low to High';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: const Text('Price: High to Low'),
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Price: High to Low';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Departure Time'),
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Departure Time';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Duration'),
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Duration';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  List<TripData> _applyFilter(List<TripData> busResults) {
    List<TripData> sorted = List.from(busResults);

    // Apply price range filter
    sorted = sorted
        .where((bus) =>
            bus.tripFare >= _priceRange.start.round() &&
            bus.tripFare <= _priceRange.end.round())
        .toList();

    switch (_selectedFilter) {
      case 'Price: Low to High':
        sorted.sort((a, b) => a.tripFare.compareTo(b.tripFare));
        break;
      case 'Price: High to Low':
        sorted.sort((a, b) => b.tripFare.compareTo(a.tripFare));
        break;
      case 'Departure Time':
        sorted.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case 'Duration':
        sorted.sort(
            (a, b) => a.routeDetail.duration.compareTo(b.routeDetail.duration));
        break;
      default:
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Available Buses",
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _performSearch,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Date picker section
            Container(
              height: 98,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _showDatePicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Pick Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              'Today & Future Only',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _availableDates.length,
                      itemBuilder: (context, index) {
                        final date = _availableDates[index];
                        final isSelected = date.day == _selectedDate.day &&
                            date.month == _selectedDate.month &&
                            date.year == _selectedDate.year;
                        final isToday = date.day == DateTime.now().day &&
                            date.month == DateTime.now().month &&
                            date.year == DateTime.now().year;

                        return GestureDetector(
                          onTap: () => _onDateSelected(date),
                          child: Container(
                            width: 55,
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : isToday
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : isToday
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                width: isSelected || isToday ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : isToday
                                            ? AppColors.primary
                                            : Colors.black87,
                                  ),
                                ),
                                Text(
                                  _getDayName(date.weekday),
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: isSelected
                                        ? Colors.white70
                                        : isToday
                                            ? AppColors.primary
                                            : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Filter section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showFilterOptions,
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A3C5A),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_selectedFilter != 'None' ||
                      _priceRange != const RangeValues(500, 2000))
                    Expanded(
                      child: Text(
                        'Filtered: ${_selectedFilter != 'None' ? _selectedFilter : ''}${_selectedFilter != 'None' && _priceRange != const RangeValues(500, 2000) ? ', ' : ''}${_priceRange != const RangeValues(500, 2000) ? 'Rs. ${_priceRange.start.round()} - Rs. ${_priceRange.end.round()}' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Bus list
            Expanded(
              child: FutureBuilder<TripResponse>(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Searching for buses...",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Error loading buses: ${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _performSearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    final response = snapshot.data!;
                    if (response.success && response.data.isNotEmpty) {
                      final filteredBuses = _applyFilter(response.data);
                      return BusListCommon(
                        busList: filteredBuses,
                        onBusTap: _handleBusTap,
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              response.message.isNotEmpty
                                  ? response.message
                                  : "No buses available for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _performSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text(
                                "Search Again",
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }

                  // Default state when no data
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No buses found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
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
