import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sumarg/models/stop_suggestion.dart';
import 'package:sumarg/utils/api_endpoints.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/widgets/glass_card.dart';
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
  final _toController   = TextEditingController();

  DateTime _selectedDate  = DateTime.now();
  Shift    _selectedShift = Shift.both;

  // ── Autocomplete state ────────────────────────────────────────────────────
  bool _showFromSuggestions = false;
  bool _showToSuggestions   = false;
  List<StopSuggestion> _fromSuggestions = [];
  List<StopSuggestion> _toSuggestions   = [];
  bool _fromLoading = false;
  bool _toLoading   = false;

  // Selected stop objects (carry the ID to the search payload)
  StopSuggestion? _selectedFrom;
  StopSuggestion? _selectedTo;

  // Guard flag — prevents the text listener from firing when we
  // programmatically set controller.text after a user taps a suggestion.
  bool _isProgrammaticChange = false;

  // Debounce timer — prevents firing an API call on every keystroke
  Timer? _debounce;

  // Recent searches (persisted locally)
  static const String _recentKey = 'recent_stops_v2';
  List<StopSuggestion> _recentStops = [];

  List<DateTime> _availableDates = [];

  final Dio _dio = Dio()
    ..options.connectTimeout = const Duration(seconds: 10)
    ..options.receiveTimeout  = const Duration(seconds: 10);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _generateAvailableDates();
    _loadRecentStops();
    _fromController.addListener(() {
      if (_isProgrammaticChange) return; // skip — we set this text ourselves
      _onQueryChanged(_fromController.text, true);
    });
    _toController.addListener(() {
      if (_isProgrammaticChange) return;
      _onQueryChanged(_toController.text, false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // ── Date helpers ──────────────────────────────────────────────────────────
  void _generateAvailableDates() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final sel   = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    DateTime start = today;
    final diff = sel.difference(today).inDays;
    if (diff >= 7) {
      start = sel.subtract(const Duration(days: 2));
      if (start.isBefore(today)) start = today;
    }
    _availableDates = List.generate(7, (i) => start.add(Duration(days: i)));
  }

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> _loadRecentStops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getStringList(_recentKey) ?? [];
      // Stored as "id|name|code|type|state"
      setState(() {
        _recentStops = raw.map((s) {
          final p = s.split('|');
          return StopSuggestion(
            id: p[0], name: p[1], code: p[2], type: p[3],
            state: p.length > 4 ? p[4] : null,
          );
        }).toList();
      });
    } catch (_) {}
  }

  Future<void> _saveRecentStop(StopSuggestion stop) async {
    try {
      _recentStops.removeWhere((s) => s.id == stop.id);
      _recentStops.insert(0, stop);
      if (_recentStops.length > 8) _recentStops = _recentStops.take(8).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _recentKey,
        _recentStops.map((s) => '${s.id}|${s.name}|${s.code}|${s.type}|${s.state ?? ''}').toList(),
      );
    } catch (_) {}
  }

  // ── Autocomplete ──────────────────────────────────────────────────────────
  void _onQueryChanged(String query, bool isFrom) {
    // Clear the selected stop object when user edits manually
    if (isFrom) { _selectedFrom = null; } else { _selectedTo = null; }

    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        if (isFrom) { _fromSuggestions = List.from(_recentStops); _showFromSuggestions = _recentStops.isNotEmpty; }
        else         { _toSuggestions   = List.from(_recentStops); _showToSuggestions   = _recentStops.isNotEmpty; }
      });
      return;
    }
    // 300 ms debounce — industry standard for autocomplete
    _debounce = Timer(const Duration(milliseconds: 300), () => _fetchStops(query, isFrom));
  }

  Future<void> _fetchStops(String query, bool isFrom) async {
    if (!mounted) return;
    setState(() { if (isFrom) _fromLoading = true; else _toLoading = true; });
    try {
      final response = await _dio.get(
        ApiEndpoints.stopSearch,
        queryParameters: {'q': query, 'limit': 8},
      );
      if (!mounted) return;
      final List<StopSuggestion> stops = (response.data['data'] as List)
          .map((e) => StopSuggestion.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        if (isFrom) { _fromSuggestions = stops; _showFromSuggestions = true; }
        else         { _toSuggestions   = stops; _showToSuggestions   = true; }
      });
    } catch (_) {
      // Silently fail — user can still type manually
    } finally {
      if (mounted) setState(() { if (isFrom) _fromLoading = false; else _toLoading = false; });
    }
  }

  void _selectStop(StopSuggestion stop, bool isFrom) {
    HapticFeedback.selectionClick();
    // Dismiss keyboard — feels native after picking from a list
    FocusScope.of(context).unfocus();
    // Cancel any pending debounced API calls for this field
    _debounce?.cancel();
    // Guard the listener so setting controller.text doesn't re-open the dropdown
    _isProgrammaticChange = true;
    setState(() {
      if (isFrom) {
        _selectedFrom = stop;
        _fromController.text = stop.name;
        _showFromSuggestions = false;
        _fromSuggestions = [];
      } else {
        _selectedTo = stop;
        _toController.text = stop.name;
        _showToSuggestions = false;
        _toSuggestions = [];
      }
    });
    // Re-enable listener after the current frame is done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isProgrammaticChange = false;
    });
    _saveRecentStop(stop);
  }

  void _swapLocations() {
    if (_fromController.text.isEmpty && _toController.text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      final tempText = _fromController.text;
      final tempStop = _selectedFrom;
      _fromController.text = _toController.text;
      _selectedFrom = _selectedTo;
      _toController.text = tempText;
      _selectedTo = tempStop;
      _showFromSuggestions = false;
      _showToSuggestions   = false;
    });
  }

  void _hideSuggestions() {
    if (_showFromSuggestions || _showToSuggestions) {
      setState(() { _showFromSuggestions = false; _showToSuggestions = false; });
    }
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: today,
      lastDate: DateTime(today.year + 1, today.month, today.day),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accentLime,
            onPrimary: AppTheme.primaryDarkest,
            surface: AppTheme.primaryDarker,
            onSurface: AppTheme.textPrimary,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: AppTheme.primaryDarker,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppTheme.stroke)),
          ),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppTheme.accentLime)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() { _selectedDate = picked; _generateAvailableDates(); });
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void _findBuses() {
    final from = _fromController.text.trim();
    final to   = _toController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      _showError(from.isEmpty ? 'Please enter a departure city' : 'Please enter an arrival city');
      return;
    }
    if (from == to) { _showError('Departure and arrival cannot be the same'); return; }

    final date = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}";
    final shift = _selectedShift == Shift.both ? ["day","night"] : [_selectedShift.name];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusResultsScreen(searchData: {
          "from": from,
          "to":   to,
          "date": date,
          "shift": shift,
          // Pass stop IDs for phase-2 precise search (ignored by current API, ready for upgrade)
          if (_selectedFrom != null) "fromStopId": _selectedFrom!.id,
          if (_selectedTo   != null) "toStopId":   _selectedTo!.id,
        }),
      ),
    );
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.stroke),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Missing Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontFamily: AppTheme.fontFamily)),
            const SizedBox(height: 12),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontFamily: AppTheme.fontFamily, height: 1.4)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentLime, foregroundColor: AppTheme.primaryDarkest, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: AppTheme.fontFamily)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideSuggestions,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // ── From / To inputs with swap ──────────────────────────────────
            Stack(alignment: Alignment.centerRight, children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  border: Border.all(color: AppTheme.stroke),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  _StopInputField(
                    controller:     _fromController,
                    hint:           'From',
                    isLoading:      _fromLoading,
                    showSuggestions: _showFromSuggestions,
                    suggestions:    _fromSuggestions,
                    recentStops:    _recentStops,
                    onSelect:       (s) => _selectStop(s, true),
                    onTap:          () => setState(() {
                      _showFromSuggestions = true;
                      if (_fromController.text.isEmpty) _fromSuggestions = List.from(_recentStops);
                    }),
                  ),
                  Divider(height: 1, color: AppTheme.stroke),
                  _StopInputField(
                    controller:      _toController,
                    hint:            'To',
                    isLoading:       _toLoading,
                    showSuggestions: _showToSuggestions,
                    suggestions:     _toSuggestions,
                    recentStops:     _recentStops,
                    onSelect:        (s) => _selectStop(s, false),
                    onTap:           () => setState(() {
                      _showToSuggestions = true;
                      if (_toController.text.isEmpty) _toSuggestions = List.from(_recentStops);
                    }),
                  ),
                ]),
              ),
              // Swap button
              Positioned(
                right: 0,
                child: FractionalTranslation(
                  translation: const Offset(0.5, 0),
                  child: GestureDetector(
                    onTap: _swapLocations,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.primaryDarker, shape: BoxShape.circle, border: Border.all(color: AppTheme.stroke)),
                      child: const Icon(Icons.swap_vert_rounded, color: AppTheme.textSecondary, size: 20),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Date selector ───────────────────────────────────────────────
            _buildHorizontalDateSelector(),
            const SizedBox(height: 20),

            // ── Shift picker ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Shift.values.map((shift) {
                final sel = _selectedShift == shift;
                return GestureDetector(
                  onTap: () => setState(() => _selectedShift = shift),
                  child: Row(children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: sel ? AppTheme.accentLime : AppTheme.textSecondary, width: 2)),
                      child: sel ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.accentLime, shape: BoxShape.circle))) : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      shift.name[0].toUpperCase() + shift.name.substring(1),
                      style: TextStyle(color: sel ? AppTheme.accentLime : AppTheme.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.w500, fontFamily: AppTheme.fontFamily, fontSize: 14),
                    ),
                  ]),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── CTA ─────────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentLime,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _findBuses,
                child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryDark, fontFamily: AppTheme.fontFamily)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Date selector widget ──────────────────────────────────────────────────
  Widget _buildHorizontalDateSelector() {
    return SizedBox(
      height: 85,
      child: Row(children: [
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: 58, height: 85,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.stroke)),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.calendar_month_rounded, color: AppTheme.accentLime, size: 24),
              SizedBox(height: 4),
              Text('More', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.08, 0.92, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _availableDates.length,
            itemBuilder: (_, i) {
              final d   = _availableDates[i];
              final sel = _selectedDate.year == d.year && _selectedDate.month == d.month && _selectedDate.day == d.day;
              const weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
              const months   = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
              return GestureDetector(
                onTap: () => setState(() { _selectedDate = d; _generateAvailableDates(); }),
                child: Container(
                  width: 58,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.accentLime : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? Colors.transparent : AppTheme.stroke),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: AppTheme.accentLime.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(weekdays[d.weekday - 1], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily, color: sel ? AppTheme.primaryDarkest : AppTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text('${d.day}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: AppTheme.fontFamily, color: sel ? AppTheme.primaryDarkest : AppTheme.textPrimary)),
                    Text(months[d.month - 1], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily, color: sel ? AppTheme.primaryDarkest.withOpacity(0.8) : AppTheme.textSecondary)),
                  ]),
                ),
              );
            },
          ),
          ),
        ),
      ]),
    );
  }
}

// ── Reusable Stop Input Field ──────────────────────────────────────────────────
class _StopInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isLoading;
  final bool showSuggestions;
  final List<StopSuggestion> suggestions;
  final List<StopSuggestion> recentStops;
  final void Function(StopSuggestion) onSelect;
  final VoidCallback onTap;

  const _StopInputField({
    required this.controller,
    required this.hint,
    required this.isLoading,
    required this.showSuggestions,
    required this.suggestions,
    required this.recentStops,
    required this.onSelect,
    required this.onTap,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'JUNCTION': return Icons.alt_route_rounded;
      case 'TOWN':     return Icons.location_city_rounded;
      case 'BORDER':   return Icons.flag_rounded;
      default:         return Icons.location_on_rounded; // CITY
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(children: [
          const Icon(Icons.directions_bus_filled_outlined, color: AppTheme.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              onTap: onTap,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 15, fontFamily: AppTheme.fontFamily),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textSecondary, fontFamily: AppTheme.fontFamily),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (isLoading)
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentLime)),
        ]),
      ),
      if (showSuggestions && suggestions.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryDarker,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.stroke),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.stroke.withOpacity(0.5), indent: 48),
              itemBuilder: (_, i) {
                final stop     = suggestions[i];
                final isRecent = recentStops.any((r) => r.id == stop.id);
                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isRecent ? AppTheme.accentLime.withOpacity(0.12) : AppTheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRecent ? Icons.history_rounded : _iconForType(stop.type),
                      size: 16,
                      color: isRecent ? AppTheme.accentLime : AppTheme.textSecondary,
                    ),
                  ),
                  title: Text(stop.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontFamily: AppTheme.fontFamily)),
                  subtitle: Text(stop.subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: AppTheme.fontFamily)),
                  trailing: Text(stop.code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentLime, fontFamily: AppTheme.fontFamily, letterSpacing: 0.5)),
                  onTap: () => onSelect(stop),
                );
              },
            ),
          ),
        ),
    ]);
  }
}
