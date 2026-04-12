import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/auth_controller/login_provider.dart';
import 'package:sumarg/controllers/ticket_controller/ticket_controller.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/utils/navigation_service.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/booking/seats_screen.dart';
import 'package:sumarg/views/widgets/bus_list_common.dart';

class BusResultsScreen extends StatefulWidget {
  final Map<String, dynamic> searchData;

  const BusResultsScreen({super.key, required this.searchData});

  @override
  State<BusResultsScreen> createState() => _BusResultsScreenState();
}

class _BusResultsScreenState extends State<BusResultsScreen> {
  late Future<TripResponse> _searchFuture;
  String _selectedFilter = 'None';
  List<TripData>? _sortedBusResults;
  RangeValues _priceRange = const RangeValues(500, 2000);
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // Date selection variables
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _availableDates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateAvailableDates();
    _initializeSearch();
    _minPriceController.text = '500';
    _maxPriceController.text = '2000';
  }

  void _generateAvailableDates() {
    final today = DateTime.now();
    // Generate dates from today onwards (maximum 10 days)
    _availableDates = [];
    for (int i = 0; i < 10; i++) {
      final date = today.add(Duration(days: i));
      _availableDates.add(date);
    }
  }

  void _initializeSearch() {
    // Parse date from searchData if available
    if (widget.searchData['date'] != null &&
        widget.searchData['date'].isNotEmpty) {
      try {
        final dateString = widget.searchData['date'];
        final dateParts = dateString.split('-');
        if (dateParts.length == 3) {
          _selectedDate = DateTime(
            int.parse(dateParts[0]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[2]), // day
          );
        }
      } catch (e) {
        print('Error parsing date from searchData: $e');
        _selectedDate = DateTime.now();
      }
    }

    _performSearch();
  }

  void _performSearch() {
    setState(() {
      _isLoading = true;
    });

    final TicketController ticketController = TicketController();

    // Create updated search data with selected date
    final formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    final updatedSearchData = Map<String, dynamic>.from(widget.searchData);
    updatedSearchData['date'] = formattedDate;

    _searchFuture = ticketController.searchTicket(updatedSearchData);
    _searchFuture.then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
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
    final todayStart = DateTime(today.year, today.month, today.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: todayStart,
      lastDate: DateTime(today.year + 1, today.month, today.day),
      selectableDayPredicate: (DateTime date) {
        final dateStart = DateTime(date.year, date.month, date.day);
        return dateStart.isAtSameMomentAs(todayStart) ||
            dateStart.isAfter(todayStart);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              onSurfaceVariant: Colors.grey[400],
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _onDateSelected(picked);
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _handleBuyTicket(BuildContext context, TripData bus) async {
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
          'searchData': widget.searchData,
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
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
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
        backgroundColor: AppColors.primary,
        title: const Text(
          'Bus Search Results',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
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
                            height: 64,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : isToday
                                      ? AppColors.primary.withOpacity(0.1)
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
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        height: 1.0,
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
                                        height: 1.0,
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
            // Route info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.searchData['from'] ?? ''}  >  ${widget.searchData['to'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}${widget.searchData['shift'] != null ? ', ${(widget.searchData['shift'] as List).join(', ')}' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<TripResponse>(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (_isLoading ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Searching for buses...",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
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
                  } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
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
                            snapshot.data?.message.isNotEmpty == true
                                ? snapshot.data!.message
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

                  final busResults = _applyFilter(snapshot.data!.data);

                  return BusListCommon(
                    busList: busResults,
                    onBusTap: (bus) {
                      _handleBuyTicket(context, bus);
                    },
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
