import 'package:sumarg/utils/toast_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sumarg/controllers/auth_controller/login_provider.dart';
import 'package:sumarg/utils/api_endpoints.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:sumarg/widgets/disputed_payment_dialog.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/coupon_provider.dart';
import 'package:sumarg/providers/ticket_provider.dart';
import 'package:sumarg/providers/profile_provider.dart';
import 'package:sumarg/models/trip_response.dart';
import 'package:sumarg/models/coupon_response_model.dart';
// SM Money state is computed server-side — no model needed
import 'package:sumarg/models/prepare_booking_response.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/utils/esewa_config.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/tickets/ticket_screen.dart';
import 'package:sumarg/views/widgets/button_widget.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/widgets/custom_toast.dart';
import 'package:sumarg/views/booking/checkout/ticket_summary_card.dart';
import 'package:sumarg/views/booking/checkout/boarding_point_section.dart';
import 'package:sumarg/views/booking/checkout/coupon_section.dart';
import 'package:sumarg/views/booking/checkout/sm_money_section.dart';
import 'package:sumarg/views/booking/checkout/price_breakdown_section.dart';
import 'package:sumarg/views/wallet/wallet_pin_sheet.dart';

class ProceedingToCheckout extends StatefulWidget {
  final int totalPrice;
  final String selectedSeats;
  final TripData busData;

  const ProceedingToCheckout({
    Key? key,
    required this.totalPrice,
    required this.selectedSeats,
    required this.busData,
  }) : super(key: key);

  @override
  State<ProceedingToCheckout> createState() => _ProceedingToCheckoutState();
}

class _ProceedingToCheckoutState extends State<ProceedingToCheckout> {
  String? name;
  String? phone;
  String? email;
  String? profilePic;
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndGetProfile();
  }

  Future<void> _checkAuthAndGetProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        return;
      }

      final storedName = prefs.getString('name');
      final storedPhone = prefs.getString('phone');
      final storedEmail = prefs.getString('email');
      final storeprofilePic = prefs.getString('profilePicture');
      final storerole = prefs.getString('role');

      if (storedName == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        return;
      }

      setState(() {
        name = storedName;
        phone = storedPhone;
        email = storedEmail;
        profilePic = storeprofilePic;
        role = storerole;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading profile data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error loading profile. Please log in again."),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary, size: 28),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentLime))
          : (name == null)
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accentLime))
              : TicketSummaryWidget(
                  totalPrice: widget.totalPrice,
                  selectedSeats: widget.selectedSeats,
                  busData: widget.busData,
                  name: name!,
                  phone: phone ?? '',
                  email: email ?? '',
                  profilePic: profilePic!,
                  role: role!),
    );
  }
}

class TicketSummaryWidget extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String profilePic;
  final String role;
  final int totalPrice;
  final String selectedSeats;
  final TripData busData;
  const TicketSummaryWidget({
    super.key,
    required this.totalPrice,
    required this.selectedSeats,
    required this.busData,
    required this.name,
    required this.phone,
    required this.email,
    required this.profilePic,
    required this.role,
  });

  @override
  State<TicketSummaryWidget> createState() => _TicketSummaryWidgetState();
}

class _TicketSummaryWidgetState extends State<TicketSummaryWidget> {
  final TextEditingController _couponController = TextEditingController();
  bool _isApplyingCoupon = false;
  bool _isCouponApplied = false;
  String? _couponMessage;
  double _discountAmount = 0;
  int _finalPrice = 0;
  bool _isCouponDropdownExpanded = false;
  // SM Money state — replaces YatraPoints
  bool _isSmMoneyEnabled = false;
  bool _isLoadingSmMoney = true;
  int _smMoneyBalance = 0;     // Available spendable balance
  int _smMoneyApplied = 0;     // Server-computed amount after 80% cap
  int _smMoneyMaxAllowed = 0;  // Max SM Money the server allows
  int _gatewayPayable = 0;     // Amount to charge at gateway
  double _walletBalance = 0.0;
  bool _isLoadingWallet = true;
  bool _isWalletEnabled = false;
  String _selectedPaymentMethod = 'esewa'; // 'esewa' or 'wallet'
  bool _isBooking = false;
  String? _selectedBoardingPoint;
  String? _selectedDroppingPoint;

  // Two-phase atomic booking state
  String? _tempBookingId;         // server-generated temp booking ID from prepareBooking
  int?    _serverPaymentAmount;   // server-validated amount from prepareBooking

  // Countdown timer
  Timer? _timer;
  int _remainingSeconds = 600; // 10 minutes

  // Primary Contact Details
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _finalPrice = widget.totalPrice;
    _selectedBoardingPoint = null;
    _selectedDroppingPoint = null;
    _fetchUserDetails();
    
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _emailController = TextEditingController(text: widget.email);
    
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        // Handle timeout
        if (mounted) {
          ToastService.showToast(msg: "Booking session expired.", backgroundColor: Colors.red, context: context, type: ToastType.error);
          Navigator.pop(context);
        }
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _couponController.dispose();
    // SM Money has no controller to dispose
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Build passengerDetails list for the API using the primary contact
  List<Map<String, dynamic>> _buildPassengerDetails() {
    final seats = widget.selectedSeats;
    return [{
      'name':   _nameController.text.trim().isEmpty ? widget.name : _nameController.text.trim(),
      'phone':  _phoneController.text.trim(),
      'email':  _emailController.text.trim(),
      'seatNo': seats,
    }];
  }

  /// Resolve selected StopPoint object by name
  StopPoint? _resolvePoint(List<StopPoint> points, String? name) {
    if (name == null) return null;
    try {
      return points.firstWhere((p) => p.pointName == name);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _buildBoardingPointMap() {
    final point = _resolvePoint(
        widget.busData.busDetail.boardingPoints, _selectedBoardingPoint);
    if (point == null) return null;
    return {
      'name': point.pointName,
      'time': point.time,
      if (point.lat != null) 'lat': point.lat,
      if (point.lng != null) 'lng': point.lng,
    };
  }

  Map<String, dynamic>? _buildDroppingPointMap() {
    final point = _resolvePoint(
        widget.busData.busDetail.droppingPoints, _selectedDroppingPoint);
    if (point == null) return null;
    return {
      'name': point.pointName,
      'time': point.time,
      if (point.lat != null) 'lat': point.lat,
      if (point.lng != null) 'lng': point.lng,
    };
  }

  Future<void> _directBookTicket() async {
    setState(() { _isBooking = true; });

    final seats = widget.selectedSeats.split(',').map((s) => s.trim()).toList();
    final tempId = 'TEMP_${DateTime.now().millisecondsSinceEpoch}';

    Map<String, dynamic> data = {
      'scheduleId':       widget.busData.id,
      'tempBookingId':    tempId,
      'paymentId':        'TEST_TXN_${DateTime.now().millisecondsSinceEpoch}',
      'transactionId':    'TEST_TXN_${DateTime.now().millisecondsSinceEpoch}',
      'paymentMethod':    'ESEWA',
      'bookedVia':        'APP',
      'paymentAmount':    _finalPrice,
      'originalAmount':   widget.totalPrice,
      'seatNumbers':      seats,
      'gateway':          'esewa',
      'passengerDetails': _buildPassengerDetails(),
      if (_buildBoardingPointMap() != null) 'boardingPoint': _buildBoardingPointMap(),
      if (_buildDroppingPointMap() != null) 'droppingPoint': _buildDroppingPointMap(),
      if (_isCouponApplied) 'couponCode': _couponController.text.trim(),
      if (_isSmMoneyEnabled && _smMoneyApplied > 0) 'smMoneyToUse': _smMoneyApplied,
    };

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final response = await ticketProvider.bookTicket(data);

    setState(() { _isBooking = false; });

    if (response.status) {
      final ticketId = response.ticketId;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Success',
        desc: response.message,
        btnOkOnPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TicketScreen(
                        ticketId: ticketId ?? '',
                        selectedSeats: widget.selectedSeats,
                        busData: widget.busData,
                        name: widget.name,
                        profilePic: widget.profilePic,
                        role: widget.role,
                      )));
        },
        btnOkText: 'Ticket',
      ).show();
    } else {
      if (response.caseId != null && response.caseId!.isNotEmpty) {
        DisputedPaymentDialog.show(
          context,
          message: response.message,
          caseId: response.caseId!,
        );
      } else {
        ToastService.showToast(
          msg: response.message,
          context: context,
          type: ToastType.error,
          title: 'Booking Failed',
          timeInSecForIosWeb: 4,
        );
      }
    }
  }

  Future<void> _fetchUserDetails() async {
    debugPrint("[Checkout] Fetching wallet balance & SM Money balance...");
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

      // Force-refresh so we always get a live balance, not a stale cached value.
      await profileProvider.loadProfile(forceRefresh: true);

      if (!mounted) return;

      setState(() {
        // Wallet balance for wallet payment method
        _walletBalance = profileProvider.walletBalance ?? 0.0;
        _isWalletEnabled = profileProvider.isWalletEnabled;
        _isLoadingWallet = false;
        // SM Money balance is fetched from prepareBooking response
        // (server-computed). But we also pre-load from smMoneyBalance
        // if the profile provider exposes it.
        _isLoadingSmMoney = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingSmMoney = false;
        _isLoadingWallet = false;
      });
      debugPrint("[Checkout] Error fetching user details: $e");
    }
  }

  Future<void> _applyCoupon() async {
    final couponCode = _couponController.text.trim();
    if (couponCode.isEmpty) {
      setState(() {
        _couponMessage = 'Please enter a coupon code';
      });
      return;
    }

    setState(() {
      _isApplyingCoupon = true;
      _couponMessage = null;
    });

    try {
      final couponProvider = Provider.of<CouponProvider>(context, listen: false);

      // Prepare request data
      Map<String, dynamic> data = {
        "couponCode": couponCode,
        "orderAmount": widget.totalPrice.toString(),
        "scheduleId": widget.busData.id
      };

      // Call the API via provider
      final CouponResponse response =
          await couponProvider.validateCoupon(data);

      if (!mounted) return;
      setState(() {
        _isApplyingCoupon = false;

        if (response.success) {
          // Extract discount information from response
          // Assuming the response has discountAmount field
          // Adjust according to your actual response structure

          // Use the discount information from the response
          if (response.data != null) {
            final couponData = response.data!;

            // The API already calculated the discount amount for us
            _discountAmount = couponData.discountAmount;
            _finalPrice = couponData.finalAmount.round();

            _isCouponApplied = true;
            _couponMessage =
                'Coupon applied successfully! You saved Rs. ${couponData.discountAmount.round()}';
          } else {
            // Handle case where response is successful but no data
            _isCouponApplied = true;
            // If no data, we'll calculate a simple discount (this is a fallback)
            _discountAmount = 0; // Default if we can't determine
            _finalPrice = widget.totalPrice;
            _couponMessage = 'Coupon applied';
          }
        } else {
          // Handle unsuccessful response
          _isCouponApplied = false;
          _discountAmount = 0;
          _finalPrice = widget.totalPrice;
          _couponMessage = response.message.isNotEmpty
              ? response.message
              : 'Invalid coupon code';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isApplyingCoupon = false;
        _isCouponApplied = false;
        _discountAmount = 0;
        _finalPrice = widget.totalPrice;
        _couponMessage = 'Error validating coupon. Please try again.';
      });
      debugPrint("Coupon validation error: $e");
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponController.clear();
      _isCouponApplied = false;
      _discountAmount = 0;
      _finalPrice = widget.totalPrice;
      _couponMessage = null;
    });
  }

  // SM Money toggle state is handled directly in the widget callback.
  // The _applyYatraPoints and _removeYatraPoints methods have been removed.
  // SM Money is applied/removed via the SmMoneySection toggle which updates
  // _isSmMoneyEnabled, _smMoneyApplied, and _gatewayPayable directly.

// eSewa — two-phase atomic payment
  _payThroughEsewa() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ToastService.showToast(msg: "Please provide a primary contact name.", backgroundColor: Colors.red, context: context, type: ToastType.error);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      ToastService.showToast(msg: "Please provide a primary phone number.", backgroundColor: Colors.red, context: context, type: ToastType.error);
      return;
    }
    if (widget.busData.busDetail.boardingPoints.isNotEmpty && _selectedBoardingPoint == null) {
      ToastService.showToast(msg: "Please select a boarding point before proceeding.", backgroundColor: Colors.red, context: context, type: ToastType.error);
      return;
    }

    // Phase 1: prepareBooking — lock seats + get server-validated amount
    setState(() { _isBooking = true; });

    final seats = widget.selectedSeats.split(',').map((s) => s.trim()).toList();
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    final PrepareBookingResponse prepareResp = await ticketProvider.prepareBooking({
      'scheduleId':       widget.busData.id,
      'seatNumbers':      seats,
      'paymentAmount':    _finalPrice,
      'originalAmount':   widget.totalPrice,
      'passengerDetails': _buildPassengerDetails(),
      if (_buildBoardingPointMap() != null) 'boardingPoint': _buildBoardingPointMap(),
      if (_buildDroppingPointMap() != null) 'droppingPoint': _buildDroppingPointMap(),
      if (_isCouponApplied) 'couponCode': _couponController.text.trim(),
      if (_isSmMoneyEnabled && _smMoneyApplied > 0) 'smMoneyToUse': _smMoneyApplied,
    });

    setState(() { _isBooking = false; });

    if (!prepareResp.status) {
      ToastService.showToast(
        msg: prepareResp.message.isNotEmpty
            ? prepareResp.message
            : 'Seats unavailable. Please select different seats.',
        context: context,
        type: ToastType.error,
        title: 'Booking Failed',
        timeInSecForIosWeb: 4,
      );
      return;
    }

    // Store server-validated values for Phase 2 (confirmBooking)
    _tempBookingId       = prepareResp.tempBookingId;
    _serverPaymentAmount = prepareResp.paymentAmount ?? _finalPrice;

    // Update SM Money state from server-computed breakdown
    setState(() {
      _smMoneyBalance    = prepareResp.smMoneyBalance;
      _smMoneyApplied    = prepareResp.smMoneyApplied;
      _smMoneyMaxAllowed = prepareResp.maxSmMoneyAllowed;
      _gatewayPayable    = prepareResp.gatewayAmount;
      _isLoadingSmMoney  = false;
    });

    // Phase 2: Launch eSewa SDK with server-validated amount
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: EsewaKeys.clientId,
          secretId: EsewaKeys.secretId,
        ),
        esewaPayment: EsewaPayment(
          productId: _tempBookingId ?? 'ESEWA_${DateTime.now().millisecondsSinceEpoch}',
          productName: widget.busData.busDetail.busName,
          // Use server-validated amount — NOT locally calculated price
          productPrice: _serverPaymentAmount.toString(),
          callbackUrl: 'https://developer.esewa.com.np',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          debugPrint(":::ESEWA SUCCESS::: => ${data.refId}");
          verifyTransactionStatus(data.refId);
        },
        onPaymentFailure: (data) {
          debugPrint(":::ESEWA FAILURE::: => $data");
          ToastService.showToast(
            msg: 'Payment was not completed. Please try again.',
            context: context,
            type: ToastType.error,
            title: 'Payment Failed',
            timeInSecForIosWeb: 3,
          );
        },
        onPaymentCancellation: (data) {
          debugPrint(":::ESEWA CANCELLATION::: => $data");
          // Clear temp booking state
          setState(() {
            _tempBookingId = null;
            _serverPaymentAmount = null;
          });
        },
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('MissingPluginException')) {
        debugPrint("eSewa SDK not available on this platform. Run on Android/iOS device.");
        ToastService.showToast(
          msg: "eSewa payment is only supported on Android & iOS devices.",
          context: context,
          type: ToastType.info,
          title: "Mobile Only",
          timeInSecForIosWeb: 4,
        );
      } else {
        debugPrint("ESEWA EXCEPTION: $e");
        ToastService.showToast(
          msg: "Could not launch eSewa. Please try again.",
          context: context,
          type: ToastType.error,
          title: "Payment Error",
          timeInSecForIosWeb: 3,
        );
      }
    }
  }

  Future<void> _payThroughWallet() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ToastService.showToast(msg: "Please provide a primary contact name.", backgroundColor: Colors.red, context: context, type: ToastType.error);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      ToastService.showToast(msg: "Please provide a primary phone number.", backgroundColor: Colors.red, context: context, type: ToastType.error);
      return;
    }
    if (widget.busData.busDetail.boardingPoints.isNotEmpty && _selectedBoardingPoint == null) {
      ToastService.showToast(msg: "Please select a boarding point before proceeding.", backgroundColor: Colors.red, context: context, type: ToastType.error);
      return;
    }

    if (_walletBalance < _finalPrice) {
      ToastService.showToast(
        msg: "Insufficient Shuvmarg Money. Please choose another payment method.",
        context: context,
        type: ToastType.error,
        title: "Insufficient Balance",
        timeInSecForIosWeb: 4,
      );
      return;
    }

    // Phase 1: prepareBooking — lock seats + get server-validated amount
    setState(() { _isBooking = true; });

    final seats = widget.selectedSeats.split(',').map((s) => s.trim()).toList();
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    try {
      final PrepareBookingResponse prepareResp = await ticketProvider.prepareBooking({
        'scheduleId':       widget.busData.id,
        'seatNumbers':      seats,
        'paymentAmount':    _finalPrice,
        'originalAmount':   widget.totalPrice,
        'passengerDetails': _buildPassengerDetails(),
        if (_buildBoardingPointMap() != null) 'boardingPoint': _buildBoardingPointMap(),
        if (_buildDroppingPointMap() != null) 'droppingPoint': _buildDroppingPointMap(),
        if (_isCouponApplied) 'couponCode': _couponController.text.trim(),
        if (_isSmMoneyEnabled && _smMoneyApplied > 0) 'smMoneyToUse': _smMoneyApplied,
      });

      if (!prepareResp.status) {
        setState(() { _isBooking = false; });
        ToastService.showToast(
          msg: prepareResp.message.isNotEmpty
              ? prepareResp.message
              : 'Seats unavailable. Please select different seats.',
          context: context,
          type: ToastType.error,
          title: 'Booking Failed',
          timeInSecForIosWeb: 4,
        );
        return;
      }

      // Store server-validated values
      _tempBookingId       = prepareResp.tempBookingId;
      _serverPaymentAmount = prepareResp.paymentAmount ?? _finalPrice;

      // Update SM Money state from server-computed breakdown
      _smMoneyBalance    = prepareResp.smMoneyBalance;
      _smMoneyApplied    = prepareResp.smMoneyApplied;
      _smMoneyMaxAllowed = prepareResp.maxSmMoneyAllowed;
      _gatewayPayable    = prepareResp.gatewayAmount;

      // Phase 1.5: Collect Wallet PIN for server-side verification
      setState(() { _isBooking = false; });
      
      final walletPin = await WalletPinSheet.show(context, mode: WalletPinMode.verify);
      
      if (walletPin == null || walletPin is! String || walletPin.isEmpty) {
        ToastService.showToast(
          msg: "Payment cancelled.",
          context: context,
          type: ToastType.info,
        );
        return;
      }

      setState(() { _isBooking = true; });

      // Phase 2: Call confirmBooking instantly with wallet gateway
      final int confirmedAmount = _serverPaymentAmount ?? _finalPrice;
      final String confirmedTempId = _tempBookingId ?? 'WALLET_${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> confirmData = {
        'scheduleId':       widget.busData.id,
        'tempBookingId':    confirmedTempId,
        'paymentId':        'wallet_payment',
        'transactionId':    'wallet_payment',
        'paymentMethod':    'YATRA_BALANCE',
        'bookedVia':        'APP',
        'paymentAmount':    confirmedAmount,
        'originalAmount':   widget.totalPrice,
        'seatNumbers':      seats,
        'gateway':          'wallet',
        'walletPin':        walletPin, // Server-side PIN verification
        'passengerDetails': _buildPassengerDetails(),
        if (_buildBoardingPointMap() != null) 'boardingPoint': _buildBoardingPointMap(),
        if (_buildDroppingPointMap() != null) 'droppingPoint': _buildDroppingPointMap(),
        if (_isCouponApplied) 'couponCode': _couponController.text.trim(),
        if (_isSmMoneyEnabled && _smMoneyApplied > 0) 'smMoneyToUse': _smMoneyApplied,
      };

      final response = await ticketProvider.confirmBooking(confirmData);

      setState(() {
        _isBooking = false;
        _tempBookingId = null;
        _serverPaymentAmount = null;
      });

      if (response.status) {
        final ticketId = response.ticketId;
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TicketScreen(
                ticketId: ticketId ?? '',
                selectedSeats: widget.selectedSeats,
                busData: widget.busData,
                name: widget.name,
                profilePic: widget.profilePic,
                role: widget.role,
                scratchCardId: response.scratchCardId,
              ),
            ),
          );
        }
      } else {
        if (response.caseId != null && response.caseId!.isNotEmpty) {
          DisputedPaymentDialog.show(
            context,
            message: response.message,
            caseId: response.caseId!,
          );
        } else {
          ToastService.showToast(
            msg: response.message,
            context: context,
            type: ToastType.error,
            title: 'Booking Failed',
            timeInSecForIosWeb: 4,
          );
        }
      }
    } catch (e) {
      setState(() { _isBooking = false; });
      ToastService.showToast(
        msg: "An unexpected error occurred: $e",
        context: context,
        type: ToastType.error,
        title: "Booking Error",
        timeInSecForIosWeb: 4,
      );
    }
  }

  void verifyTransactionStatus(String refId) async {
    setState(() { _isBooking = true; });

    final seats = widget.selectedSeats.split(',').map((s) => s.trim()).toList();

    // Use server-validated amount from prepareBooking (not locally calculated)
    // This ensures eSewa verify on backend matches the amount we sent to eSewa SDK
    final int confirmedAmount = _serverPaymentAmount ?? _finalPrice;
    final String confirmedTempId = _tempBookingId ?? 'ESEWA_${DateTime.now().millisecondsSinceEpoch}';

    Map<String, dynamic> data = {
      'scheduleId':       widget.busData.id,
      'tempBookingId':    confirmedTempId,
      'paymentId':        refId,          // eSewa refId — verified server-side
      'transactionId':    refId,
      'paymentMethod':    'ESEWA',
      'bookedVia':        'APP',
      'paymentAmount':    confirmedAmount,
      'originalAmount':   widget.totalPrice,
      'seatNumbers':      seats,
      'gateway':          'esewa',
      'passengerDetails': _buildPassengerDetails(),
      if (_buildBoardingPointMap() != null) 'boardingPoint': _buildBoardingPointMap(),
      if (_buildDroppingPointMap() != null) 'droppingPoint': _buildDroppingPointMap(),
      if (_isCouponApplied) 'couponCode': _couponController.text.trim(),
      if (_isSmMoneyEnabled && _smMoneyApplied > 0) 'smMoneyToUse': _smMoneyApplied,
    };

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final response = await ticketProvider.confirmBooking(data);

    setState(() {
      _isBooking = false;
      _tempBookingId = null;        // clear temp booking state
      _serverPaymentAmount = null;
    });

    if (response.status) {
      final ticketId = response.ticketId;
      // Navigate directly to the ticket screen — no intermediate dialog needed.
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketScreen(
              ticketId: ticketId ?? '',
              selectedSeats: widget.selectedSeats,
              busData: widget.busData,
              name: widget.name,
              profilePic: widget.profilePic,
              role: widget.role,
              scratchCardId: response.scratchCardId,
            ),
          ),
        );
      }
    } else {
      if (response.caseId != null && response.caseId!.isNotEmpty) {
        DisputedPaymentDialog.show(
          context,
          message: response.message,
          caseId: response.caseId!,
        );
      } else {
        ToastService.showToast(
          msg: response.message,
          context: context,
          type: ToastType.error,
          title: 'Booking Failed',
          timeInSecForIosWeb: 4,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main scrollable content
        ListView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 140), // Padding for floating bar + trust signal
          children: [
            // Countdown Timer Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentLime.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, color: AppTheme.accentLime, size: 20),
                  const SizedBox(width: 8),
                  const Text("Hold Expires In: ", style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(color: AppTheme.accentLime, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            
            // Ticket Summary Card
            TicketSummaryCard(
              busData: widget.busData,
              selectedSeats: widget.selectedSeats,
              nameController: _nameController,
              phoneController: _phoneController,
              emailController: _emailController,
            ),
            const SizedBox(height: 24),
            
            // Boarding Points Section
            BoardingPointSection(
              boardingPoints: widget.busData.busDetail.boardingPoints,
              selectedPoint: _selectedBoardingPoint,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBoardingPoint = newValue;
                });
              },
            ),
            const SizedBox(height: 24),

            // Coupon Section
            CouponSection(
              controller: _couponController,
              isExpanded: _isCouponDropdownExpanded,
              isApplying: _isApplyingCoupon,
              isApplied: _isCouponApplied,
              message: _couponMessage,
              onToggleExpanded: () {
                setState(() {
                  _isCouponDropdownExpanded = !_isCouponDropdownExpanded;
                });
              },
              onApply: _applyCoupon,
              onRemove: _removeCoupon,
            ),
            const SizedBox(height: 24),

            // SM Money Section
            SmMoneySection(
              isEnabled: _isSmMoneyEnabled,
              isLoading: _isLoadingSmMoney,
              availableBalance: _smMoneyBalance,
              appliedAmount: _smMoneyApplied,
              maxAllowed: _smMoneyMaxAllowed,
              onToggle: (enabled) {
                setState(() {
                  _isSmMoneyEnabled = enabled;
                  if (enabled) {
                    // Apply max allowed SM Money
                    _smMoneyApplied = _smMoneyMaxAllowed > _smMoneyBalance
                        ? _smMoneyBalance
                        : _smMoneyMaxAllowed;
                    _gatewayPayable = _finalPrice - _smMoneyApplied;
                  } else {
                    _smMoneyApplied = 0;
                    _gatewayPayable = _finalPrice;
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Price Breakdown Section
            PriceBreakdownSection(
              subtotalPrice: widget.totalPrice,
              finalPrice: _finalPrice,
              isCouponApplied: _isCouponApplied,
              discountAmount: _discountAmount,
              isSmMoneyApplied: _isSmMoneyEnabled,
              smMoneyAmount: _smMoneyApplied,
              gatewayPayable: _gatewayPayable,
            ),
            const SizedBox(height: 32),

            // Payment Method Selection
            const Text(
              "Payment Method",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            
            // Option 1: eSewa
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'esewa';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedPaymentMethod == 'esewa' ? AppTheme.accentLime : Colors.white.withOpacity(0.08),
                    width: _selectedPaymentMethod == 'esewa' ? 1.5 : 1,
                  ),
                  boxShadow: _selectedPaymentMethod == 'esewa'
                      ? [BoxShadow(color: AppTheme.accentLime.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset("assets/logos/esewa.png", height: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "eSewa Mobile Wallet",
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Pay instantly using eSewa gateway",
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _selectedPaymentMethod == 'esewa' ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                      color: _selectedPaymentMethod == 'esewa' ? AppTheme.accentLime : Colors.white.withOpacity(0.3),
                      size: 24,
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Option 2: Yatra Balance
            GestureDetector(
              onTap: () {
                if (!_isWalletEnabled) {
                  ToastService.showToast(msg: "Please activate your wallet in your profile first.", context: context, type: ToastType.info);
                  return;
                }
                setState(() {
                  _selectedPaymentMethod = 'wallet';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedPaymentMethod == 'wallet' ? AppTheme.accentLime : Colors.white.withOpacity(0.08),
                    width: _selectedPaymentMethod == 'wallet' ? 1.5 : 1,
                  ),
                  boxShadow: _selectedPaymentMethod == 'wallet'
                      ? [BoxShadow(color: AppTheme.accentLime.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppTheme.accentLime,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Shuvmarg ',
                                  style: TextStyle(color: AppTheme.textPrimary),
                                ),
                                TextSpan(
                                  text: 'Money',
                                  style: TextStyle(color: AppTheme.accentLime),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          _isLoadingWallet
                              ? SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textSecondary.withOpacity(0.5)),
                                  ),
                                )
                              : Text(
                                  !_isWalletEnabled 
                                      ? "Wallet Not Active" 
                                      : _walletBalance < _finalPrice
                                          ? "Balance: Rs. ${_walletBalance.toStringAsFixed(0)} (Insufficient)"
                                          : "Available Balance: Rs. ${_walletBalance.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    color: !_isWalletEnabled || _walletBalance < _finalPrice 
                                        ? Colors.redAccent.withOpacity(0.8) 
                                        : AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Icon(
                      _selectedPaymentMethod == 'wallet' ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                      color: _selectedPaymentMethod == 'wallet' ? AppTheme.accentLime : Colors.white.withOpacity(0.3),
                      size: 24,
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Floating Bottom Checkout Bar with Trust Signals
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trust Signal
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary.withOpacity(0.8), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "Secure Checkout • Free Cancellation up to 12 hrs",
                      style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xE000564E),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
                  boxShadow: [BoxShadow(color: AppTheme.primaryDarkest.withOpacity(0.8), blurRadius: 20, offset: const Offset(0, -10))],
                ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Payable",
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Rs. $_finalPrice",
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _isBooking ? null : (_selectedPaymentMethod == 'wallet' ? _payThroughWallet : _payThroughEsewa),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            color: _isBooking ? AppTheme.primary : AppTheme.accentLime,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isBooking ? [] : [BoxShadow(color: AppTheme.accentLime.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Text(
                                _isBooking ? "Processing..." : "Pay & Book",
                                style: TextStyle(
                                  color: _isBooking ? AppTheme.textSecondary : const Color(0xFF003D38),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (!_isBooking) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, color: Color(0xFF003D38), size: 18),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ), // ClipRRect
          ), // Container
        ], // Column children
      ), // Column
    ), // Positioned
  ], // Stack children
); // Stack
  }
}
