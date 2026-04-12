import 'package:flutter/material.dart';
import 'package:sumarg/controllers/seatas_controller/seats_controller.dart';
import 'package:sumarg/models/seat_response.dart';

class SeatSelectionProvider extends ChangeNotifier {
  final Set<String> _selectedSeats = {};
  int pricePerSeat;
  final SeatsController _seatsController;
  bool _isLoading = false;
  String _error = '';
  int _maxSeats = 6; // Default max seats per booking
  SeatResponse? _seatResponse;

  SeatSelectionProvider({this.pricePerSeat = 0, SeatsController? seatsController})
      : _seatsController = seatsController ?? SeatsController();

  // Set price per seat
  void setPricePerSeat(int price) {
    pricePerSeat = price;
    notifyListeners();
  }

  // Getters
  Set<String> get selectedSeats => _selectedSeats;
  int get totalPrice => _selectedSeats.length * pricePerSeat;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get maxSeats => _maxSeats;
  int get selectedSeatsCount => _selectedSeats.length;
  bool get canSelectMore => _selectedSeats.length < _maxSeats;
  bool get hasSelectedSeats => _selectedSeats.isNotEmpty;
  SeatResponse? get seatResponse => _seatResponse;

  // Set maximum seats allowed
  void setMaxSeats(int maxSeats) {
    _maxSeats = maxSeats;
    notifyListeners();
  }

  // Toggle seat selection with validation
  void toggleSeat(String seatLabel) {
    if (_selectedSeats.contains(seatLabel)) {
      _selectedSeats.remove(seatLabel);
      _error = '';
    } else {
      if (_selectedSeats.length < _maxSeats) {
        _selectedSeats.add(seatLabel);
        _error = '';
      } else {
        _error = 'Maximum ${_maxSeats} seats allowed per booking';
      }
    }
    notifyListeners();
  }

  // Select multiple seats
  void selectSeats(List<String> seatLabels) {
    if (_selectedSeats.length + seatLabels.length <= _maxSeats) {
      _selectedSeats.addAll(seatLabels);
      _error = '';
    } else {
      _error = 'Cannot select more than $_maxSeats seats';
    }
    notifyListeners();
  }

  // Clear all selected seats
  void clearSeats() {
    _selectedSeats.clear();
    _error = '';
    notifyListeners();
  }

  // Remove specific seat
  void removeSeat(String seatLabel) {
    _selectedSeats.remove(seatLabel);
    _error = '';
    notifyListeners();
  }

  // Check if seat is selected
  bool isSelected(String seatLabel) =>
      _selectedSeats.contains(seatLabel);

  // Get seat selection summary
  String get selectionSummary {
    if (_selectedSeats.isEmpty) {
      return 'No seats selected';
    }
    return '${_selectedSeats.length} seat${_selectedSeats.length > 1 ? 's' : ''} selected';
  }

  // Get formatted price
  String get formattedPrice {
    return 'Rs. ${totalPrice.toStringAsFixed(2)}';
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get selected seats as list
  List<String> get selectedSeatsList => _selectedSeats.toList();

  // Check if seat selection is valid for booking
  bool get isValidForBooking =>
      _selectedSeats.isNotEmpty && _selectedSeats.length <= _maxSeats;

  // Get remaining seats count
  int get remainingSeats => _maxSeats - _selectedSeats.length;

  Future<void> fetchSeats(String tripId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _seatResponse = await _seatsController.getSeatsById(tripId: tripId);
      if (_seatResponse != null && !_seatResponse!.status) {
        _error = _seatResponse!.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
