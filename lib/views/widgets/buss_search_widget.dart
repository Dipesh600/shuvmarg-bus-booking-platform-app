import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/search/buss_search_result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Shift { both, day, night }

class BussSearchWidget extends StatefulWidget {
  const BussSearchWidget({super.key});

  @override
  State<BussSearchWidget> createState() => _BussSearchWidgetState();
}

class _BussSearchWidgetState extends State<BussSearchWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Shift _selectedShift = Shift.both;

  // Auto-suggestions related variables
  bool _showFromSuggestions = false;
  bool _showToSuggestions = false;
  List<String> _filteredFromSuggestions = [];
  List<String> _filteredToSuggestions = [];

  // Popular locations
  List<String> _popularLocations = [
    'Kathmandu',
    'Pokhara',
    'Chitwan',
    'Lumbini',
    'Biratnagar',
    'Dharan',
    'Butwal',
    'Bhairahawa',
    'Nepalgunj',
    'Dhangadhi',
    'Biratnagar',
    'Itahari',
    'Hetauda',
    'Birgunj',
    'Janakpur',
  ];

  // Recent searches storage key
  static const String _recentSearchesKey = 'recent_searches';
  static const String _popularLocationsKey = 'popular_locations';
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadPopularLocations();
    _setupControllers();
  }

  void _setupControllers() {
    _fromController.addListener(() {
      _filterSuggestions(_fromController.text, true);
    });

    _toController.addListener(() {
      _filterSuggestions(_toController.text, false);
    });
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearchesJson =
          prefs.getStringList(_recentSearchesKey) ?? [];
      setState(() {
        _recentSearches = recentSearchesJson;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadPopularLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocations =
          prefs.getStringList(_popularLocationsKey);
      if (savedLocations != null && savedLocations.isNotEmpty) {
        setState(() {
          _popularLocations = savedLocations;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _savePopularLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _popularLocationsKey, _popularLocations);
    } catch (e) {
      // Handle error silently
    }
  }

  void _addToPopularLocations(String location) {
    if (!_popularLocations.contains(location)) {
      setState(() {
        _popularLocations.add(location);
        // Keep maximum 20 popular locations
        if (_popularLocations.length > 20) {
          _popularLocations = _popularLocations.take(20).toList();
        }
      });
      _savePopularLocations();
    }
  }

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, _recentSearches);
    } catch (e) {
      // Handle error silently
    }
  }

  void _addToRecentSearches(String from, String to) {
    setState(() {
      // Add individual locations to recent searches instead of combined search term
      if (from.isNotEmpty) {
        _recentSearches.remove(from); // Remove if exists
        _recentSearches.insert(0, from); // Add to beginning
      }
      if (to.isNotEmpty && to != from) {
        _recentSearches.remove(to); // Remove if exists
        _recentSearches.insert(0, to); // Add to beginning
      }

      // Keep only last 10 searches
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
    _saveRecentSearches();

    // Add individual locations to popular locations
    _addToPopularLocations(from);
    _addToPopularLocations(to);
  }

  void _filterSuggestions(String query, bool isFromField) {
    if (query.isEmpty) {
      setState(() {
        if (isFromField) {
          _showFromSuggestions = false;
        } else {
          _showToSuggestions = false;
        }
      });
      return;
    }

    final suggestions = <String>[];

    // Add recent searches that match the query (now individual locations)
    for (String recent in _recentSearches) {
      if (recent.toLowerCase().contains(query.toLowerCase()) &&
          !suggestions.contains(recent)) {
        suggestions.add(recent);
      }
    }

    // Add popular locations that match the query
    for (String location in _popularLocations) {
      if (location.toLowerCase().contains(query.toLowerCase()) &&
          !suggestions.contains(location)) {
        suggestions.add(location);
      }
    }

    setState(() {
      if (isFromField) {
        _filteredFromSuggestions = suggestions;
        _showFromSuggestions = suggestions.isNotEmpty;
      } else {
        _filteredToSuggestions = suggestions;
        _showToSuggestions = suggestions.isNotEmpty;
      }
    });
  }

  void _selectSuggestion(String suggestion, bool isFromField) {
    if (isFromField) {
      _fromController.text = suggestion;
      _showFromSuggestions = false;
    } else {
      _toController.text = suggestion;
      _showToSuggestions = false;
    }
  }

  void _swapLocations() {
    // Store current text values
    final fromText = _fromController.text.trim();
    final toText = _toController.text.trim();

    // Only swap if at least one field has content
    if (fromText.isNotEmpty || toText.isNotEmpty) {
      setState(() {
        _fromController.text = toText;
        _toController.text = fromText;

        // Hide suggestions when swapping
        _showFromSuggestions = false;
        _showToSuggestions = false;
      });

      // Provide haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _findBuses() {
    String? fromError;
    String? toError;

    if (_fromController.text.trim().isEmpty) {
      fromError = 'Please enter departure destination';
    }
    if (_toController.text.trim().isEmpty) {
      toError = 'Please enter arrival destination';
    }

    if (fromError != null || toError != null) {
      String errorMessage;
      if (fromError != null && toError != null) {
        errorMessage =
            'Please enter both departure and arrival destinations';
      } else if (fromError != null) {
        errorMessage = fromError;
      } else {
        errorMessage = toError!;
      }

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Error',
        desc: errorMessage,
        btnOkOnPress: () {},
        btnOkText: 'OK',
      ).show();
      return;
    }

    if (_formKey.currentState!.validate()) {
      final formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final shiftValues = _selectedShift == Shift.both
          ? ["day", "night"]
          : [_selectedShift.name];

      final data = {
        "from": _fromController.text.trim(),
        "to": _toController.text.trim(),
        "date": formattedDate ?? "",
        "shift": shiftValues,
      };

      // Add to recent searches
      _addToRecentSearches(
          _fromController.text.trim(), _toController.text.trim());

      print(data);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BusResultsScreen(searchData: data)));
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // Method to hide suggestions when clicking outside the text fields
  void _hideSuggestions() {
    if (_showFromSuggestions || _showToSuggestions) {
      setState(() {
        _showFromSuggestions = false;
        _showToSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideSuggestions,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [


              // STACKED INPUTS WITH SWAP
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInputFieldWithSuggestions(
                          controller: _fromController,
                          hint: "From",
                          icon: Icons.directions_bus,
                          showSuggestions: _showFromSuggestions,
                          suggestions: _filteredFromSuggestions,
                          isFromField: true,
                          iconColor: Colors.white70,
                        ),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                        _buildInputFieldWithSuggestions(
                          controller: _toController,
                          hint: "To",
                          icon: Icons.directions_bus,
                          showSuggestions: _showToSuggestions,
                          suggestions: _filteredToSuggestions,
                          isFromField: false,
                          iconColor: Colors.white70,
                        ),
                      ],
                    ),
                  ),

                  // FLOATING SWAP BUTTON
                  Positioned(
                    right: 20,
                    child: GestureDetector(
                      onTap: _swapLocations,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.swap_vert,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 7-DAY HORIZONTAL SELECTOR
              _buildHorizontalDateSelector(),
              const SizedBox(height: 16),

              // SHIFT / DEPARTURE TIME RADIO (We keep this since it's core Shuvmarg functionality)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: Shift.values.map((shift) {
                  final isSelected = _selectedShift == shift;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedShift = shift),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? AppColors.secondary : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          shift.name[0].toUpperCase() + shift.name.substring(1),
                          style: TextStyle(
                            color: isSelected ? AppColors.secondary : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // MASSIVE BOOK NOW BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _findBuses,
                  child: const Text(
                    "Book Now",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900, // Thick font matches image
                      color: AppColors.primaryDarkest,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldWithSuggestions({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool showSuggestions,
    required List<String> suggestions,
    required bool isFromField,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.transparent, // Removed the white clash
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white54),
              icon: Icon(icon, color: iconColor, size: 22),
              border: InputBorder.none,
            ),
            onTap: () {
              // Show recent searches immediately when field is tapped
              setState(() {
                if (isFromField) {
                  _showFromSuggestions = true;
                  _filteredFromSuggestions =
                      _recentSearches.isNotEmpty
                          ? _recentSearches
                          : _popularLocations.take(5).toList();
                } else {
                  _showToSuggestions = true;
                  _filteredToSuggestions = _recentSearches.isNotEmpty
                      ? _recentSearches
                      : _popularLocations.take(5).toList();
                }
              });
            },
          ),
        ),
        if (showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryDarker,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  final isRecentSearch =
                      _recentSearches.contains(suggestion);

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isRecentSearch
                          ? Icons.history
                          : Icons.location_on,
                      size: 20,
                      color: isRecentSearch
                          ? AppColors.secondary
                          : Colors.white54,
                    ),
                    title: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: isRecentSearch
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: isRecentSearch
                        ? Text(
                            'Recent search',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          )
                        : null,
                    onTap: () =>
                        _selectSuggestion(suggestion, isFromField),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalDateSelector() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        itemBuilder: (context, index) {
          final currentDate = DateTime.now().add(Duration(days: index));
          final isSelected = _selectedDate.year == currentDate.year &&
                             _selectedDate.month == currentDate.month &&
                             _selectedDate.day == currentDate.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = currentDate;
              });
            },
            child: Container(
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                      _getShortWeekDay(currentDate.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primaryDarkest : Colors.white54,
                      ),
                   ),
                   const SizedBox(height: 4),
                   Text(
                      "${currentDate.day}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? AppColors.primaryDarkest : Colors.white,
                      ),
                   ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getShortWeekDay(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

}
