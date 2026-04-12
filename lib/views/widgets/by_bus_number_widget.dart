import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/views/live_bus_search_list_screen.dart';

class ByBusNumberTab extends StatefulWidget {
  const ByBusNumberTab({super.key});

  @override
  State<ByBusNumberTab> createState() => _ByBusNumberTabState();
}

class _ByBusNumberTabState extends State<ByBusNumberTab> {
  final _busNumberController = TextEditingController();

  // Popular bus numbers (example format)
  final List<String> _popularBusNumbers = [
    'BA-1-PA-1234',
    'BA-1-PA-5678',
    'BA-1-PA-9012',
    'BA-1-PA-3456',
    'BA-1-PA-7890',
    'BA-1-PA-2345',
    'BA-1-PA-6789',
    'BA-1-PA-0123',
    'BA-1-PA-4567',
    'BA-1-PA-8901',
  ];

  // Recent searches storage key
  static const String _recentSearchesKey =
      'bus_number_recent_searches';
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
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

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, _recentSearches);
    } catch (e) {
      // Handle error silently
    }
  }

  void _addToRecentSearches(String busNumber) {
    setState(() {
      _recentSearches.remove(busNumber); // Remove if exists
      _recentSearches.insert(0, busNumber); // Add to beginning
      if (_recentSearches.length > 10) {
        // Keep only last 10 searches
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
    _saveRecentSearches();
  }

  List<String> _getSuggestions(String query) {
    if (query.isEmpty) return [];

    final suggestions = <String>[];

    // Add recent searches that match the query
    for (String recent in _recentSearches) {
      if (recent.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(recent);
      }
    }

    // Add popular bus numbers that match the query
    for (String busNumber in _popularBusNumbers) {
      if (busNumber.toLowerCase().contains(query.toLowerCase()) &&
          !suggestions.contains(busNumber)) {
        suggestions.add(busNumber);
      }
    }

    return suggestions;
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Check bus status by number",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter bus number to track its current location",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Bus number form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Bus number field with auto-complete
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _busNumberController,
                    decoration: InputDecoration(
                      labelText: "Bus Number",
                      hintText:
                          "Enter bus number (e.g., BA-1-PA-1234)",
                      prefixIcon: const Icon(Icons.directions_bus,
                          color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  suggestionsCallback: (pattern) =>
                      _getSuggestions(pattern),
                  itemBuilder: (context, suggestion) {
                    final isRecentSearch =
                        _recentSearches.contains(suggestion);
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isRecentSearch
                            ? Icons.history
                            : Icons.directions_bus,
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
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    _busNumberController.text = suggestion;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter bus number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Check Status button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (_busNumberController.text.isNotEmpty) {
                        _addToRecentSearches(
                            _busNumberController.text);
                        print(
                            "Checking status for bus: ${_busNumberController.text}");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LiveBusSearchScreen()));
                      }
                    },
                    child: const Text(
                      "Check Status",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
}
