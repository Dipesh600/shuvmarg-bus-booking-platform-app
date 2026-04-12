import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/live_bus_search_screen.dart';

class ByBusNumberTab extends StatefulWidget {
  const ByBusNumberTab({super.key});

  @override
  State<ByBusNumberTab> createState() => _ByBusNumberTabState();
}

class _ByBusNumberTabState extends State<ByBusNumberTab> {
  final TextEditingController _busNumberController =
      TextEditingController();

  // Popular bus numbers
  final List<String> _popularBusNumbers = [
    'BA-1-PA-1234',
    'BA-1-PA-5678',
    'BA-1-PA-9012',
    'BA-1-PA-3456',
    'BA-1-PA-7890',
    'BA-1-PA-2345',
    'BA-1-PA-6789',
    'BA-1-PA-0123',
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

      if (_recentSearches.length > 20) {
        // Keep only last 20 searches
        _recentSearches = _recentSearches.take(20).toList();
      }
    });
    _saveRecentSearches();
  }

  List<String> _getSuggestions(String query) {
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

  void _handleSuggestionSelected(
      String suggestion, TextEditingController controller) {
    controller.text = suggestion;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      hintText: "Enter bus number or name",
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
                  suggestionsCallback: (pattern) async {
                    return _getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    final isRecent =
                        _recentSearches.contains(suggestion);
                    return ListTile(
                      leading: Icon(
                        isRecent
                            ? Icons.history
                            : Icons.directions_bus,
                        color: isRecent
                            ? AppColors.primary
                            : Colors.grey,
                        size: 20,
                      ),
                      title: Text(
                        suggestion,
                        style: TextStyle(
                          fontWeight: isRecent
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: isRecent
                          ? const Text('Recent search',
                              style: TextStyle(fontSize: 12))
                          : const Text('Popular bus',
                              style: TextStyle(fontSize: 12)),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    _handleSuggestionSelected(
                        suggestion, _busNumberController);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bus number';
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
                      }
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         const LiveBusSearchScreen(),
                      //   ),
                      // );
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const LiveBusSearchScreen()));
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

          // Recent searches section
          if (_recentSearches.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              "Recent Searches",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.take(6).map((busNumber) {
                return GestureDetector(
                  onTap: () {
                    _busNumberController.text = busNumber;
                    _addToRecentSearches(busNumber);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightest,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.primaryLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          busNumber,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Popular bus numbers section
          const SizedBox(height: 24),
          const Text(
            "Popular Bus Numbers",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularBusNumbers.map((busNumber) {
              return GestureDetector(
                onTap: () {
                  _busNumberController.text = busNumber;
                  _addToRecentSearches(busNumber);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_bus,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        busNumber,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    super.dispose();
  }
}
