import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/auth_controller/login_provider.dart';
import 'package:sumarg/controllers/ticket_controller/ticket_controller.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/utils/app_theme.dart';
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
    final todayStart = DateTime(today.year, today.month, today.day);
    final selectedStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    DateTime startDate = todayStart;
    final diff = selectedStart.difference(todayStart).inDays;
    
    if (diff < 0) {
      startDate = todayStart;
    } else if (diff >= 10) {
      startDate = selectedStart.subtract(const Duration(days: 3));
      if (startDate.isBefore(todayStart)) startDate = todayStart;
    }

    _availableDates = [];
    for (int i = 0; i < 10; i++) {
      _availableDates.add(startDate.add(Duration(days: i)));
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
          data: ThemeData.dark().copyWith(
            primaryColor: AppTheme.accentLime,
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
                foregroundColor: AppTheme.accentLime, // button text color
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3D925).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFD3D925).withOpacity(0.4)),
                        ),
                        child: const Text('Reset',
                            style: TextStyle(
                                color: Color(0xFFD3D925),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
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
                    valueIndicatorTextStyle:
                        const TextStyle(color: Color(0xFFD3D925)),
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
                        _minPriceController.text =
                            values.start.round().toString();
                        _maxPriceController.text =
                            values.end.round().toString();
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
                        setSheetState(() => _priceRange =
                            RangeValues(n.toDouble(), _priceRange.end));
                        setState(() => _priceRange =
                            RangeValues(n.toDouble(), _priceRange.end));
                      },
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _darkTextField(
                      controller: _maxPriceController,
                      label: 'Max',
                      onChanged: (v) {
                        final n = int.tryParse(v) ?? 2000;
                        setSheetState(() => _priceRange =
                            RangeValues(_priceRange.start, n.toDouble()));
                        setState(() => _priceRange =
                            RangeValues(_priceRange.start, n.toDouble()));
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
                    _sortChip('Price: Low to High', Icons.arrow_upward_rounded,
                        setSheetState),
                    _sortChip('Price: High to Low', Icons.arrow_downward_rounded,
                        setSheetState),
                    _sortChip('Departure Time', Icons.schedule_rounded,
                        setSheetState),
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
                      boxShadow: [BoxShadow(
                          color: const Color(0xFFD3D925).withOpacity(0.3),
                          blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Text('Apply Filters',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF003D38),
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
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
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: const Color(0xFF00564E).withOpacity(0.4))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: const Color(0xFF00564E).withOpacity(0.4))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD3D925), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          color: isActive
              ? const Color(0xFFD3D925).withOpacity(0.15)
              : const Color(0xFF00564E).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFFD3D925).withOpacity(0.6)
                : const Color(0x0DFFFFFF),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: isActive
                    ? const Color(0xFFD3D925)
                    : const Color(0xFFB7C7C3)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isActive
                        ? const Color(0xFFD3D925)
                        : const Color(0xFFB7C7C3),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
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

  // ── Design tokens (aliased from AppTheme for brevity) ─────────────────────
  static const Color _bg          = AppTheme.primaryDark;
  static const Color _primary     = AppTheme.primary;
  static const Color _primaryDark = AppTheme.primaryDark;
  static const Color _accentLime  = AppTheme.accentLime;
  static const Color _textPrimary = AppTheme.textPrimary;
  static const Color _textSec     = AppTheme.textSecondary;
  static const Color _stroke      = AppTheme.stroke;

  @override
  Widget build(BuildContext context) {
    final from = widget.searchData['from'] ?? '';
    final to   = widget.searchData['to']   ?? '';

    return Scaffold(
      backgroundColor: _bg,
      // ── Custom header (no AppBar) ────────────────────────────────────────
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Glass Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                      child: Icon(Icons.chevron_left_rounded, color: _textPrimary, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Route title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$from  →  $to',
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'
                          '${widget.searchData['shift'] != null ? "  •  ${(widget.searchData['shift'] as List).join(', ')}" : ""}',
                          style: const TextStyle(
                            color: _textSec,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter icon button
                  GestureDetector(
                    onTap: _showFilterOptions,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _selectedFilter != 'None' || _priceRange != const RangeValues(500, 2000)
                            ? _accentLime.withOpacity(0.15)
                            : _primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFilter != 'None' || _priceRange != const RangeValues(500, 2000)
                              ? _accentLime.withOpacity(0.5)
                              : _stroke,
                          width: 1,
                        ),
                      ),
                      child: Icon(Icons.tune_rounded,
                          color: _selectedFilter != 'None' || _priceRange != const RangeValues(500, 2000)
                              ? _accentLime
                              : _textSec,
                          size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Date Strip ────────────────────────────────────────────────
            _buildDateStrip(),

            // ── Active filter pill (if any) ───────────────────────────────
            if (_selectedFilter != 'None' || _priceRange != const RangeValues(500, 2000))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _accentLime.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _accentLime.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tune_rounded, size: 12, color: _accentLime),
                          const SizedBox(width: 6),
                          Text(
                            _selectedFilter != 'None' ? _selectedFilter
                                : 'Rs. ${_priceRange.start.round()} – ${_priceRange.end.round()}',
                            style: const TextStyle(
                              color: _accentLime,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedFilter = 'None';
                              _priceRange = const RangeValues(500, 2000);
                            }),
                            child: const Icon(Icons.close_rounded,
                                size: 13, color: _accentLime),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // ── Bus list / states ─────────────────────────────────────────
            Expanded(
              child: FutureBuilder<TripResponse>(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (_isLoading || snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                    return _buildEmptyState(snapshot.data?.message ?? '');
                  }
                  final busResults = _applyFilter(snapshot.data!.data);
                  return BusListCommon(
                    busList: busResults,
                    onBusTap: (bus) => _handleBuyTicket(context, bus),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Date Strip ─────────────────────────────────────────────────────────────
  Widget _buildDateStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Fixed calendar picker button
          GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              width: 58,
              height: 85,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _stroke, width: 1),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded, color: _accentLime, size: 24),
                  SizedBox(height: 4),
                  Text('More',
                      style: TextStyle(
                          color: _textSec,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          // Scrollable date list
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
                physics: const BouncingScrollPhysics(),
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _accentLime
                            : isToday
                                ? _primary.withOpacity(0.3)
                                : _primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _accentLime
                              : isToday
                                  ? _primary
                                  : _stroke,
                          width: isSelected ? 0 : 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(
                                color: _accentLime.withOpacity(0.25),
                                blurRadius: 8, offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayName(date.weekday),
                            style: TextStyle(
                              color: isSelected
                                  ? _primaryDark
                                  : _textSec,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected ? _primaryDark : _textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            _getShortMonth(date.month),
                            style: TextStyle(
                              color: isSelected
                                  ? _primaryDark.withOpacity(0.8)
                                  : _textSec,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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

  // ── Loading State ──────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(_accentLime),
              strokeWidth: 2.5,
              backgroundColor: _primary.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Searching for buses…',
              style: TextStyle(color: _textSec, fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 34),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(color: _textPrimary, fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSec, fontSize: 13)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _performSearch,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  color: _accentLime,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: _accentLime.withOpacity(0.3),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Text('Retry',
                    style: TextStyle(color: _primaryDark,
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: _stroke),
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: _textSec, size: 34),
            ),
            const SizedBox(height: 16),
            const Text('No buses found',
                style: TextStyle(color: _textPrimary, fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              message.isNotEmpty
                  ? message
                  : 'No buses available for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSec, fontSize: 13),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _performSearch,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  color: _accentLime,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: _accentLime.withOpacity(0.3),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Text('Search Again',
                    style: TextStyle(color: _primaryDark,
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
