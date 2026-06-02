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
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/widgets/glass_card.dart';
import 'package:sumarg/widgets/loading_neon_bus.dart';

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
    final todayStart = DateTime(today.year, today.month, today.day);
    final selectedStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    DateTime startDate = todayStart;
    final diff = selectedStart.difference(todayStart).inDays;
    
    if (diff < 0) {
      startDate = todayStart;
    } else if (diff >= 7) {
      startDate = selectedStart.subtract(const Duration(days: 2));
      if (startDate.isBefore(todayStart)) startDate = todayStart;
    }

    _availableDates = [];
    for (int i = 0; i < 7; i++) {
      _availableDates.add(startDate.add(Duration(days: i)));
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

    _searchFuture = Future.wait([
      ticketProvider.searchTicket(searchData),
      Future.delayed(const Duration(milliseconds: 600)),
    ]).then((results) => results.first as TripResponse);
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
      _generateAvailableDates();
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

  String _getShortMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<void> _showDatePicker() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day); // Start of today
    final initialPickerDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialPickerDate,
      firstDate: todayStart,
      lastDate: DateTime(today.year + 1, today.month, today.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentLime,
              onPrimary: AppTheme.primaryDarkest,
              surface: AppTheme.primaryDarker,
              onSurface: AppTheme.textPrimary,
              onSurfaceVariant: AppTheme.textSecondary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppTheme.primaryDarker,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppTheme.stroke, width: 1),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentLime,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _onDateSelected(picked);
      final today = DateTime.now();
      final daysDifference = picked.difference(today).inDays;
      if (daysDifference >= 0 && daysDifference < 10) {
        WidgetsBinding.instance.addPostFrameCallback((_) {});
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00231E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(
                24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter & Sort',
                        style: TextStyle(
                            color: Color(0xFFF5F7F6),
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'None';
                          _priceRange = const RangeValues(500, 2000);
                          _minPriceController.text = '500';
                          _maxPriceController.text = '2000';
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3D925).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD3D925).withOpacity(0.4)),
                        ),
                        child: const Text('Reset',
                            style: TextStyle(color: Color(0xFFD3D925), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Price Range ──────────────────────────────────────────
                const Text('Price Range',
                    style: TextStyle(
                        color: Color(0xFFB7C7C3),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFD3D925),
                    inactiveTrackColor: const Color(0xFF00564E),
                    thumbColor: const Color(0xFFD3D925),
                    overlayColor: const Color(0xFFD3D925).withOpacity(0.15),
                    valueIndicatorColor: const Color(0xFF003D38),
                    valueIndicatorTextStyle: const TextStyle(color: Color(0xFFD3D925)),
                    trackHeight: 3,
                  ),
                  child: RangeSlider(
                    values: _priceRange,
                    min: 500,
                    max: 2000,
                    divisions: 15,
                    labels: RangeLabels(
                      'Rs. ${_priceRange.start.round()}',
                      'Rs. ${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setSheetState(() => _priceRange = values);
                      setState(() {
                        _priceRange = values;
                        _minPriceController.text = values.start.round().toString();
                        _maxPriceController.text = values.end.round().toString();
                      });
                    },
                  ),
                ),
                // Min/Max inputs
                Row(
                  children: [
                    Expanded(child: _darkTextField(
                      controller: _minPriceController,
                      label: 'Min',
                      onChanged: (v) {
                        final n = int.tryParse(v) ?? 500;
                        setSheetState(() => _priceRange = RangeValues(n.toDouble(), _priceRange.end));
                        setState(() => _priceRange = RangeValues(n.toDouble(), _priceRange.end));
                      },
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _darkTextField(
                      controller: _maxPriceController,
                      label: 'Max',
                      onChanged: (v) {
                        final n = int.tryParse(v) ?? 2000;
                        setSheetState(() => _priceRange = RangeValues(_priceRange.start, n.toDouble()));
                        setState(() => _priceRange = RangeValues(_priceRange.start, n.toDouble()));
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Sort By ──────────────────────────────────────────────
                const Text('Sort By',
                    style: TextStyle(
                        color: Color(0xFFB7C7C3),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _sortChip('Price: Low to High', Icons.arrow_upward_rounded, setSheetState),
                    _sortChip('Price: High to Low', Icons.arrow_downward_rounded, setSheetState),
                    _sortChip('Departure Time', Icons.schedule_rounded, setSheetState),
                    _sortChip('Duration', Icons.timer_outlined, setSheetState),
                  ],
                ),
                const SizedBox(height: 20),

                // Apply button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3D925),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFFD3D925).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Text('Apply Filters',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF003D38), fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _darkTextField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Color(0xFFF5F7F6), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'Rs. ',
        prefixStyle: const TextStyle(color: Color(0xFFB7C7C3), fontSize: 13),
        labelStyle: const TextStyle(color: Color(0xFFB7C7C3), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF00564E).withOpacity(0.15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF00564E).withOpacity(0.4))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF00564E).withOpacity(0.4))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD3D925), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: onChanged,
    );
  }

  Widget _sortChip(String label, IconData icon, StateSetter setSheetState) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setSheetState(() {});
        setState(() => _selectedFilter = isActive ? 'None' : label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD3D925).withOpacity(0.15) : const Color(0xFF00564E).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? const Color(0xFFD3D925).withOpacity(0.6) : const Color(0x0DFFFFFF), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isActive ? const Color(0xFFD3D925) : const Color(0xFFB7C7C3)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isActive ? const Color(0xFFD3D925) : const Color(0xFFF5F7F6), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ultra-Compact Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      children: [
                        TextSpan(text: 'Available '),
                        TextSpan(
                          text: 'Buses',
                          style: TextStyle(color: AppTheme.accentLime),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.accentLime),
                    onPressed: _performSearch,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Compact Date Picker Row
            _buildCompactDatePicker(),
            const SizedBox(height: 16),

            // Compact Filter Row
            _buildFilterRow(),
            const SizedBox(height: 12),

            // Main Content Area
            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    return FutureBuilder<TripResponse>(
      future: _searchFuture,
      builder: (context, snapshot) {
        Widget child;
        if (_isLoading) {
          child = const LoadingNeonBus(key: ValueKey('loading'), isLoading: true);
        } else if (snapshot.hasError) {
          child = _buildErrorState(snapshot.error.toString());
        } else if (snapshot.hasData) {
          final response = snapshot.data!;
          if (response.success && response.data.isNotEmpty) {
            final filteredBuses = _applyFilter(response.data);
            if (filteredBuses.isEmpty) {
              child = _buildEmptyState("No buses match your filter criteria.");
            } else {
              child = BusListCommon(
                key: const ValueKey('content'),
                busList: filteredBuses,
                onBusTap: _handleBusTap,
              );
            }
          } else {
            child = _buildEmptyState(
              response.message.isNotEmpty
                  ? response.message
                  : "No buses available for ${_selectedDate.day}/${_selectedDate.month}",
            );
          }
        } else {
          child = _buildEmptyState("No buses found");
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: child,
        );
      },
    );
  }

  Widget _buildCompactDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Pick Date Button
          GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              height: 85,
              width: 58,
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.stroke, width: 1),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 24,
                    color: AppTheme.accentLime,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'More',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Scrollable Dates
          Expanded(
            child: SizedBox(
              height: 85,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent
                    ],
                    stops: [0.0, 0.08, 0.92, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                itemCount: _availableDates.length,
                itemBuilder: (context, index) {
                  final date = _availableDates[index];
                  final isSelected = date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;

                  return GestureDetector(
                    onTap: () => _onDateSelected(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppTheme.accentLime : AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppTheme.stroke,
                          width: isSelected ? 0 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentLime.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayName(date.weekday),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.primaryDarkest
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? AppTheme.primaryDarkest
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            _getShortMonth(date.month),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.primaryDarkest.withOpacity(0.8)
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _showFilterOptions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.stroke, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune_rounded,
                      size: 16, color: AppTheme.accentLime),
                  SizedBox(width: 8),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Sort by',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.stroke, width: 1),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedFilter == 'None'
                            ? 'Departure'
                            : _selectedFilter.split(':').first,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 14, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingNeonBus(
                  isLoading: false,
                  title: "No Buses Found",
                  subtitle: message,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.stroke),
                          ),
                          child: const Icon(Icons.notifications_active_rounded,
                              color: AppTheme.accentLime),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Get notified for new buses",
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "We'll notify you when new buses are available",
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentLime,
                            foregroundColor: AppTheme.primaryDark,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Enable Alerts",
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildErrorState(String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppTheme.error),
              const SizedBox(height: 16),
              const Text(
                "Connection Error",
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Try Again"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
