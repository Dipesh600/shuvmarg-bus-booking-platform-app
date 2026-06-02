import 'package:flutter/foundation.dart';
import 'package:sumarg/controllers/feedback_controller/feedback_controller.dart';
import 'package:sumarg/models/for_all_response.dart';
import 'package:sumarg/models/get_review_response.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackController _feedbackController;

  FeedbackProvider({FeedbackController? feedbackController})
      : _feedbackController = feedbackController ?? FeedbackController();

  bool _isSubmitting = false;
  bool _isLoadingFeedback = false;
  String _error = '';
  GetReviewResponse? _currentFeedback;

  bool get isSubmitting => _isSubmitting;
  bool get isLoadingFeedback => _isLoadingFeedback;
  String get error => _error;
  GetReviewResponse? get currentFeedback => _currentFeedback;

  Future<ForAllResponse> submitReview({
    required String bookingId,
    required String fleetId,
    required int rating,
    required String comment,
  }) async {
    _isSubmitting = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _feedbackController.submitReview(
        bookingId: bookingId,
        fleetId: fleetId,
        rating: rating,
        comment: comment,
      );
      return response;
    } catch (e) {
      _error = e.toString();
      return ForAllResponse(status: false, message: _error);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> fetchFeedback({required String fleetId, bool forceRefresh = false}) async {
    if (_currentFeedback != null && !forceRefresh) return;

    _isLoadingFeedback = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _feedbackController.getFeedback(fleetId: fleetId);
      _currentFeedback = response;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingFeedback = false;
      notifyListeners();
    }
  }

  void clearFeedback() {
    _currentFeedback = null;
    _error = '';
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
