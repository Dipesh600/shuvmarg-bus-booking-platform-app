import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/buss_search_result_screen.dart';
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
  DateTime? _selectedDate;
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
      final formattedDate = _selectedDate != null
          ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
          : null;

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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.08),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppColors.primaryLighter.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            Column(
                              children: [
                                _buildInputFieldWithSuggestions(
                                  controller: _fromController,
                                  hint: "Departing From",
                                  icon: Icons.trip_origin,
                                  showSuggestions:
                                      _showFromSuggestions,
                                  suggestions:
                                      _filteredFromSuggestions,
                                  isFromField: true,
                                  iconColor: AppColors.primary,
                                ),
                                const SizedBox(height: 16),
                                _buildInputFieldWithSuggestions(
                                  controller: _toController,
                                  hint: "Going to",
                                  icon: Icons.location_on_rounded,
                                  showSuggestions: _showToSuggestions,
                                  suggestions: _filteredToSuggestions,
                                  isFromField: false,
                                  iconColor: AppColors.secondary,
                                ),
                              ],
                            ),

                            // Floating Swap Button
                            Positioned(
                              right: 24,
                              top: 48,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _swapLocations,
                                  borderRadius:
                                      BorderRadius.circular(25),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius:
                                          BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.15),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(color: AppColors.primaryLightest, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.swap_vert_rounded,
                                      color: AppColors.secondary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDate,
                          child: _buildDatePickerField(),
                        ),
                        const SizedBox(height: 14),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Shift",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: Shift.values.map((shift) {
                            final isSelected =
                                _selectedShift == shift;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedShift = shift),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons
                                            .radio_button_unchecked,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    shift.name[0].toUpperCase() +
                                        shift.name.substring(1),
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _findBuses,
                            child: const Text(
                              "Search Buses",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
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
            color: AppColors.primaryLightest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black54),
              icon: Icon(icon, color: iconColor, size: 24),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                          ? AppColors.primary
                          : Colors.grey[600],
                    ),
                    title: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: isRecentSearch
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: isRecentSearch
                        ? Text(
                            'Recent search',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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

  Widget _buildDatePickerField() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primaryLightest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Text(
            _selectedDate != null
                ? "${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}"
                : "Select Travel Date",
            style: TextStyle(
              fontSize: 16,
              fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
              color: _selectedDate != null
                  ? AppColors.text
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
