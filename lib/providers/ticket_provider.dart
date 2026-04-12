import 'package:flutter/foundation.dart';
import '../controllers/ticket_controller/ticket_controller.dart';
import '../models/ticket_history_response.dart';
import '../models/trip_response.dart';
import '../models/ticket_booking_response.dart';
import '../models/yatra_points_response.dart';
import '../models/for_all_response.dart';
import '../utils/local_storage_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketController _ticketController = TicketController();

  // State variables
  List<TicketHistoryData> _tickets = [];
  TicketHistoryData? _selectedTicket;
  bool _isLoading = false;
  String _error = '';
  DateTime? _lastUpdated;
  bool _isOffline = false;
  bool _hasCachedData = false;

  // Getters
  List<TicketHistoryData> get tickets => _tickets;
  TicketHistoryData? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isOffline => _isOffline;
  bool get hasCachedData => _hasCachedData;
  bool get hasTickets => _tickets.isNotEmpty;

  void setSelectedTicket(TicketHistoryData? ticket) {
    _selectedTicket = ticket;
    notifyListeners();
  }

  // API Methods proxying Controller
  Future<TripResponse> searchTicket(dynamic data) async {
    return await _ticketController.searchTicket(data);
  }

  Future<TicketBookingResponse> bookTicket(dynamic data) async {
    return await _ticketController.bookTicket(data);
  }

  Future<YatraPointsResponse> validateYatraPoints(dynamic data) async {
    return await _ticketController.validateYatraPoints(data);
  }

  Future<ForAllResponse> cancelTicket(dynamic data) async {
    final res = await _ticketController.cancelTicket(data);
    if (res.status) {
      // Refresh history after cancellation
      await refreshTickets();
    }
    return res;
  }

  // Get tickets by status
  List<TicketHistoryData> getTicketsByStatus(String status) {
    return _tickets.where((ticket) => ticket.booking.status == status).toList();
  }

  // Get upcoming tickets
  List<TicketHistoryData> get upcomingTickets {
    final now = DateTime.now();
    return _tickets.where((ticket) {
      // You might need to adjust this based on your actual data structure
      return ticket.booking.status.toLowerCase() == 'confirmed' ||
          ticket.booking.status.toLowerCase() == 'upcoming';
    }).toList();
  }

  // Get completed tickets
  List<TicketHistoryData> get completedTickets {
    return _tickets.where((ticket) {
      return ticket.booking.status.toLowerCase() == 'completed';
    }).toList();
  }

  // Get tickets for today
  List<TicketHistoryData> get todayTickets {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _tickets.where((ticket) {
      // You might need to adjust this based on your actual data structure
      // This is a placeholder - you'll need to extract date from ticket data
      return true; // Placeholder
    }).toList();
  }

  // Load tickets with caching
  Future<void> loadTickets({bool forceRefresh = false}) async {
    // If not a force refresh and we already have tickets, skip.
    if (_tickets.isNotEmpty && !forceRefresh) return;

    // 1) Show cached data immediately if available (stale-while-revalidate)
    if (_tickets.isEmpty) {
      final hasLocalData = await LocalStorageService.hasLocalData();
      if (hasLocalData) {
        final cachedData = await LocalStorageService.getTicketHistory();
        if (cachedData != null) {
          _tickets = cachedData.data;
          _lastUpdated = await LocalStorageService.getLastUpdated();
          _hasCachedData = true;
          _isOffline = true;
          _error = '';
          notifyListeners();
        }
      }
    }

    // 2) Always attempt to fetch from API; controller handles offline and local fallback
    await _fetchTicketsFromAPI(forceRefresh: forceRefresh);
  }

  // Fetch tickets from API
  Future<void> _fetchTicketsFromAPI({bool forceRefresh = false}) async {
    // Only show loading if we still have no data
    bool showLoading = _tickets.isEmpty;

    if (showLoading) {
      _isLoading = true;
      _error = '';
      notifyListeners();
    }

    try {
      final result = await _ticketController.ticketHistoryWithStatus({});

      if (result != null) {
        final ticketHistory = result['data'] as TicketHistoryResponse;
        _tickets = ticketHistory.data;
        _isOffline = result['isOffline'] as bool;
        _lastUpdated = result['lastUpdated'] as DateTime?;
        _hasCachedData = false;

        // Cache the data locally
        await LocalStorageService.saveTicketHistory(ticketHistory);

        _error = '';
      } else {
        if (_tickets.isEmpty) _error = 'Failed to load tickets';
      }
    } catch (e) {
      if (_tickets.isEmpty) _error = 'Error loading tickets: $e';
    } finally {
      if (showLoading) {
        _isLoading = false;
        notifyListeners();
      } else if (forceRefresh) {
        notifyListeners();
      }
    }
  }

  // Refresh tickets
  Future<void> refreshTickets() async {
    await _fetchTicketsFromAPI(forceRefresh: true);
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Get ticket by ID
  TicketHistoryData? getTicketById(String ticketId) {
    try {
      return _tickets.firstWhere(
          (ticket) => (ticket.trip?.id ?? ticket.booking.ticketId) == ticketId);
    } catch (e) {
      return null;
    }
  }

  // Search tickets
  // List<TicketHistoryData> searchTickets(String query) {
  //   if (query.isEmpty) return _tickets;

  //   final lowercaseQuery = query.toLowerCase();
  //   return _tickets.where((ticket) {
  //     return ticket.ticket.busNumber
  //             .toLowerCase()
  //             .contains(lowercaseQuery) ||
  //         ticket.ticket.from.toLowerCase().contains(lowercaseQuery) ||
  //         ticket.ticket.to.toLowerCase().contains(lowercaseQuery) ||
  //         ticket.ticket.passengerName
  //             .toLowerCase()
  //             .contains(lowercaseQuery);
  //   }).toList();
  // }

  // Get ticket statistics
  Map<String, int> get ticketStatistics {
    final stats = <String, int>{};
    for (final ticket in _tickets) {
      stats[ticket.booking.status] = (stats[ticket.booking.status] ?? 0) + 1;
    }
    return stats;
  }

  // Get total spent
  double get totalSpent {
    return _tickets.fold(
        0.0, (sum, ticket) => sum + ticket.booking.totalAmount);
  }

  // Check if data is stale (older than 24 hours)
  bool get isDataStale {
    if (_lastUpdated == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);
    return difference.inHours > 24;
  }

  // Clear all data
  void clearData() {
    _tickets = [];
    _lastUpdated = null;
    _isOffline = false;
    _hasCachedData = false;
    _error = '';
    notifyListeners();
  }
}
