import 'package:flutter/foundation.dart';
import 'package:sumarg/controllers/coupon_controller/coupon_controller.dart';
import 'package:sumarg/models/get_coupn_respnse_model.dart' as list_model;
import 'package:sumarg/models/reward_history_model.dart';
import 'package:sumarg/models/coupon_response_model.dart';

class CouponProvider extends ChangeNotifier {
  final CouponController _couponController;

  CouponProvider({CouponController? couponController})
      : _couponController = couponController ?? CouponController();

  List<list_model.Coupon> _coupons = [];
  List<RewardHistory> _rewardHistory = [];
  bool _isLoadingCoupons = false;
  bool _isLoadingRewards = false;
  String _couponError = '';
  String _rewardError = '';

  List<list_model.Coupon> get coupons => _coupons;
  List<RewardHistory> get rewardHistory => _rewardHistory;
  bool get isLoadingCoupons => _isLoadingCoupons;
  bool get isLoadingRewards => _isLoadingRewards;
  String get couponError => _couponError;
  String get rewardError => _rewardError;

  Future<void> fetchCoupons({bool forceRefresh = false}) async {
    // If not a force refresh and we already have data, skip fetching.
    if (_coupons.isNotEmpty && !forceRefresh) return;

    // Only show the loading state if we have no data yet.
    if (_coupons.isEmpty) {
      _isLoadingCoupons = true;
      _couponError = '';
      notifyListeners();
    }

    try {
      final res = await _couponController.getAllCoupons();
      if (res.success) {
        _coupons = res.data;
        _couponError = '';
      } else {
        _couponError = res.message;
      }
    } catch (e) {
      _couponError = e.toString();
    } finally {
      if (_isLoadingCoupons) {
        _isLoadingCoupons = false;
        notifyListeners();
      } else if (forceRefresh) {
        // If it was a force refresh but we didn't show the initial loader,
        // we still need to notify listeners that the data has been updated.
        notifyListeners();
      }
    }
  }

  Future<void> fetchRewardHistory({bool forceRefresh = false}) async {
    // If not a force refresh and we already have data, skip fetching.
    if (_rewardHistory.isNotEmpty && !forceRefresh) return;

    // Only show the loading state if we have no data yet.
    if (_rewardHistory.isEmpty) {
      _isLoadingRewards = true;
      _rewardError = '';
      notifyListeners();
    }

    try {
      final res = await _couponController.getRewardHistory();
      if (res.status) {
        _rewardHistory = res.data;
        _rewardError = '';
      } else {
        _rewardError = res.message.isNotEmpty
            ? res.message
            : 'Failed to load reward history';
      }
    } catch (e) {
      _rewardError = e.toString();
    } finally {
      if (_isLoadingRewards) {
        _isLoadingRewards = false;
        notifyListeners();
      } else if (forceRefresh) {
        notifyListeners();
      }
    }
  }

  Future<CouponResponse> validateCoupon(Map<String, dynamic> data) async {
    return await _couponController.validateCoupon(data);
  }

  void clearErrors() {
    _couponError = '';
    _rewardError = '';
    notifyListeners();
  }
}
