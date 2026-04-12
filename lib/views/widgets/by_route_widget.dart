import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/views/live_bus_search_list_screen.dart';

class ByRouteTab extends StatefulWidget {
  const ByRouteTab({super.key});

  @override
  State<ByRouteTab> createState() => _ByRouteTabState();
}

class _ByRouteTabState extends State<ByRouteTab> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  final List<String> _popularLocations = [
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
    'Itahari',
    'Hetauda',
    'Birgunj',
    'Janakpur',
    'Inaruwa',
    'Dhankuta',
    'Sunsari',
    'Morang',
    'Jhapa',
    'Illam',
  ];

  static const String _recentSearchesKey = 'route_recent_searches';
  List<String> _recentRoutes = [];

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
        _recentRoutes = recentSearchesJson;
      });
    } catch (e) {}
  }

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, _recentRoutes);
    } catch (e) {}
  }

  void _addToRecentSearches(String from, String to) {
    setState(() {
      final route = "$from|$to";
      _recentRoutes.remove(route);
      _recentRoutes.insert(0, route);

      if (_recentRoutes.length > 20) {
        _recentRoutes = _recentRoutes.take(20).toList();
      }
    });
    _saveRecentSearches();
  }

  void _swapLocations() {
    final fromText = _fromController.text;
    final toText = _toController.text;

    setState(() {
      _fromController.text = toText;
      _toController.text = fromText;
    });
  }

  List<String> _getSuggestions(String query) {
    if (query.isEmpty) return [];

    final suggestions = <String>[];

    // Add recent routes that match the query (show as "from to to")
    for (String recentRoute in _recentRoutes) {
      final parts = recentRoute.split('|');
      if (parts.length == 2) {
        final from = parts[0];
        final to = parts[1];
        final displayText = "$from to $to";

        if (from.toLowerCase().contains(query.toLowerCase()) ||
            to.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(displayText);
        }
      }
    }

    // Add popular locations that match the query
    for (String location in _popularLocations) {
      if (location.toLowerCase().contains(query.toLowerCase()) &&
          !suggestions.any((s) => s.contains(location))) {
        suggestions.add(location);
      }
    }

    return suggestions;
  }

  void _handleSuggestionSelected(
      String suggestion, TextEditingController controller) {
    // Check if it's a route suggestion (contains "to")
    if (suggestion.contains(' to ')) {
      final parts = suggestion.split(' to ');
      if (parts.length == 2) {
        // If selecting for "from" field, use the first part
        // If selecting for "to" field, use the second part
        if (controller == _fromController) {
          controller.text = parts[0];
        } else {
          controller.text = parts[1];
        }
      }
    } else {
      // It's a single location
      controller.text = suggestion;
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Check bus status by route",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your route details to track buses",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Route selection form
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
                  // Stack for both fields and swap button
                  Stack(
                    children: [
                      Column(
                        children: [
                          // From field with auto-complete
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: TypeAheadFormField<String>(
                              textFieldConfiguration:
                                  TextFieldConfiguration(
                                controller: _fromController,
                                decoration: InputDecoration(
                                  labelText: "From",
                                  hintText:
                                      "Enter departure location",
                                  prefixIcon: const Icon(
                                      Icons.location_on_outlined,
                                      color: AppColors.primary),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2),
                                  ),
                                ),
                              ),
                              suggestionsCallback: (pattern) =>
                                  _getSuggestions(pattern),
                              itemBuilder: (context, suggestion) {
                                final isRecentRoute =
                                    suggestion.contains(' to ');
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    isRecentRoute
                                        ? Icons.history
                                        : Icons.location_on,
                                    size: 20,
                                    color: isRecentRoute
                                        ? AppColors.primary
                                        : Colors.grey[600],
                                  ),
                                  title: Text(
                                    suggestion,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: isRecentRoute
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: isRecentRoute
                                      ? Text(
                                          'Recent route',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        )
                                      : null,
                                );
                              },
                              onSuggestionSelected: (suggestion) {
                                _handleSuggestionSelected(
                                    suggestion, _fromController);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter departure location';
                                }
                                return null;
                              },
                            ),
                          ),
                          // const SizedBox(height: 16),

                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: TypeAheadFormField<String>(
                              textFieldConfiguration:
                                  TextFieldConfiguration(
                                controller: _toController,
                                decoration: InputDecoration(
                                  labelText: "To",
                                  hintText:
                                      "Enter destination location",
                                  prefixIcon: const Icon(
                                      Icons.place_outlined,
                                      color: Colors.red),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2),
                                  ),
                                ),
                              ),
                              suggestionsCallback: (pattern) =>
                                  _getSuggestions(pattern),
                              itemBuilder: (context, suggestion) {
                                final isRecentRoute =
                                    suggestion.contains(' to ');
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    isRecentRoute
                                        ? Icons.history
                                        : Icons.location_on,
                                    size: 20,
                                    color: isRecentRoute
                                        ? AppColors.primary
                                        : Colors.grey[600],
                                  ),
                                  title: Text(
                                    suggestion,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: isRecentRoute
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: isRecentRoute
                                      ? Text(
                                          'Recent route',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        )
                                      : null,
                                );
                              },
                              onSuggestionSelected: (suggestion) {
                                _handleSuggestionSelected(
                                    suggestion, _toController);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter destination location';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // Floating Swap Button positioned at top right
                      Positioned(
                        right: 12,
                        top: 50,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _swapLocations,
                            icon: const Icon(
                              Icons.swap_vert,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
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
                        if (_fromController.text.isNotEmpty &&
                            _toController.text.isNotEmpty) {
                          _addToRecentSearches(_fromController.text,
                              _toController.text);
                          print(
                              "Checking status for: ${_fromController.text} to ${_toController.text}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LiveBusSearchScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Search Buses",
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
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
