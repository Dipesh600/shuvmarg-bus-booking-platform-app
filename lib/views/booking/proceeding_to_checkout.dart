import 'package:sumarg/utils/toast_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
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
import 'package:sumarg/models/yatra_points_response.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/utils/esewa_config.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/tickets/ticket_screen.dart';
import 'package:sumarg/views/widgets/button_widget.dart';
import 'package:sumarg/views/booking/checkout/ticket_summary_card.dart';
import 'package:sumarg/views/booking/checkout/boarding_point_section.dart';
import 'package:sumarg/views/booking/checkout/coupon_section.dart';
import 'package:sumarg/views/booking/checkout/yatra_points_section.dart';
import 'package:sumarg/views/booking/checkout/price_breakdown_section.dart';

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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Ticket Summary"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (name == null)
              ? const Center(child: CircularProgressIndicator())
              : TicketSummaryWidget(
                  totalPrice: widget.totalPrice,
                  selectedSeats: widget.selectedSeats,
                  busData: widget.busData,
                  name: name!,
                  profilePic: profilePic!,
                  role: role!),
    );
  }
}

class TicketSummaryWidget extends StatefulWidget {
  final String name;
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
  bool _isYatraPointsDropdownExpanded = false;
  final TextEditingController _yatraPointsController = TextEditingController();
  bool _isApplyingYatraPoints = false;
  bool _isYatraPointsApplied = false;
  String? _yatraPointsMessage;
  int _yatraPointsUsed = 0;
  double _availableYatraPoints = 0;
  bool _isLoadingYatraPoints = true;
  bool _isBooking = false;
  String? _selectedBoardingPoint;

  Future<void> _directBookTicket() async {
    setState(() {
      _isBooking = true;
    });
    Map<String, dynamic> data = {
      "tripId": widget.busData.id,
      "seatNumbers": widget.selectedSeats.split(',').map((s) => s.trim()).toList(),
      "gateway": "esewa",
      "transactionId": "TEST_TXN_${DateTime.now().millisecondsSinceEpoch}",
      if (_isYatraPointsApplied) "yatrapointsUsed": _yatraPointsUsed,
      if (_selectedBoardingPoint != null)
        "boardingPoint": _selectedBoardingPoint,
    };
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final response = await ticketProvider.bookTicket(data);

    setState(() {
      _isBooking = false;
    });

    if (response.status) {
      // ignore: use_build_context_synchronously
      String ticketId = response.ticketId;
      // ignore: use_build_context_synchronously
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
                        ticketId: ticketId,
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
      ToastService.showToast(
        msg: response.message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("my error ${response.message}");
    }
  }

  @override
  void initState() {
    super.initState();
    _finalPrice = widget.totalPrice;
    _selectedBoardingPoint = null;
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _couponController.dispose();
    _yatraPointsController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    print("fetching user details");
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      // Ensure profile is loaded
      await profileProvider.loadProfile();
      
      if (profileProvider.yatraPoints != null) {
        setState(() {
          _availableYatraPoints = profileProvider.yatraPoints!;
          _isLoadingYatraPoints = false;
        });
      } else {
        setState(() {
          _availableYatraPoints = 0;
          _isLoadingYatraPoints = false;
        });
      }
    } catch (e) {
      setState(() {
        _availableYatraPoints = 0;
        _isLoadingYatraPoints = false;
      });
      debugPrint("Error fetching user details: $e");
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

  Future<void> _applyYatraPoints() async {
    final pointsText = _yatraPointsController.text.trim();
    if (pointsText.isEmpty) {
      setState(() {
        _yatraPointsMessage = 'Please enter points to use';
      });
      return;
    }

    final pointsToUse = int.tryParse(pointsText);
    if (pointsToUse == null || pointsToUse <= 0) {
      setState(() {
        _yatraPointsMessage = 'Please enter valid points';
      });
      return;
    }

    if (_isLoadingYatraPoints) {
      setState(() {
        _yatraPointsMessage = 'Please wait while we load your points';
      });
      return;
    }

    if (pointsToUse > _availableYatraPoints) {
      setState(() {
        _yatraPointsMessage =
            'You only have $_availableYatraPoints points available';
      });
      return;
    }

    setState(() {
      _isApplyingYatraPoints = true;
      _yatraPointsMessage = null;
    });

    try {
      // Prepare request data for Yatra points validation
      Map<String, dynamic> validationData = {
        "yatrapointsToUse": pointsToUse,
        "scheduleId": widget.busData.id,
        "seatNumbers": [widget.selectedSeats]
      };

      final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
      
      // Call the API via provider
      final YatraPointsResponse response =
          await ticketProvider.validateYatraPoints(validationData);

      setState(() {
        _isApplyingYatraPoints = false;

        if (response.status && response.data != null) {
          // Update final price with the validated amount from server
          _finalPrice = response.data!.finalAmount;
          _yatraPointsUsed = pointsToUse;
          _isYatraPointsApplied = true;
          _yatraPointsMessage =
              'Yatra Points applied successfully! Final amount: Rs. ${response.data!.finalAmount}';
        } else {
          // Handle unsuccessful response
          _isYatraPointsApplied = false;
          _yatraPointsUsed = 0;
          _finalPrice = widget.totalPrice; // Reset to original price
          _yatraPointsMessage = response.message.isNotEmpty
              ? response.message
              : 'Failed to validate Yatra points';
        }
      });
    } catch (e) {
      setState(() {
        _isApplyingYatraPoints = false;
        _isYatraPointsApplied = false;
        _yatraPointsUsed = 0;
        _finalPrice = widget.totalPrice; // Reset to original price
        _yatraPointsMessage =
            'Error validating Yatra points. Please try again.';
      });
      debugPrint("Yatra points validation error: $e");
    }
  }

  void _removeYatraPoints() {
    setState(() {
      _yatraPointsController.clear();
      _isYatraPointsApplied = false;
      _finalPrice = widget.totalPrice; // Reset to original total price
      _yatraPointsUsed = 0;
      _yatraPointsMessage = null;
    });
  }

// Esewa
  _payThroughEsewa() async {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: EsewaKeys.clientId,
          secretId: EsewaKeys.secretId,
        ),
        esewaPayment: EsewaPayment(
          productId: widget.busData.id,
          productName: widget.busData.busDetail.busName,
          productPrice: _finalPrice.toString(),
          callbackUrl: '',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          debugPrint(":::SUCCESS::: => $data");
          // bookTicket(data.refId)
          verifyTransactionStatus(data.refId);
        },
        onPaymentFailure: (data) {
          debugPrint(":::FAILURE::: => $data");
        },
        onPaymentCancellation: (data) {
          debugPrint(":::CANCELLATION::: => $data");
        },
      );
    } on Exception catch (e) {
      debugPrint("EXCEPTION : ${e.toString()}");
    }
  }

  void verifyTransactionStatus(refId) async {
    setState(() {
      _isBooking = true;
    });
    Map<String, dynamic> data = {
      "tripId": widget.busData.id,
      "seatNumbers": widget.selectedSeats.split(',').map((s) => s.trim()).toList(),
      "gateway": "esewa",
      "transactionId": refId,
      if (_isYatraPointsApplied) "yatrapointsUsed": _yatraPointsUsed,
      if (_selectedBoardingPoint != null)
        "boardingPoint": _selectedBoardingPoint,
    };
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final response = await ticketProvider.bookTicket(data);

    setState(() {
      _isBooking = false;
    });

    if (response.status) {
      // ignore: use_build_context_synchronously
      String ticketId = response.ticketId;
      // ignore: use_build_context_synchronously
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
                        ticketId: ticketId,
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
      ToastService.showToast(
        msg: response.message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("my error ${response.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ticket Summary Card
          TicketSummaryCard(
            busData: widget.busData,
            selectedSeats: widget.selectedSeats,
            passengerName: widget.name,
          ),
          const SizedBox(height: 20),
          // Boarding Points Section
          BoardingPointSection(
            boardingPoints: widget.busData.busDetail.amenities,
            selectedPoint: _selectedBoardingPoint,
            onChanged: (String? newValue) {
              setState(() {
                _selectedBoardingPoint = newValue;
              });
            },
          ),
          const SizedBox(height: 20),

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

          const SizedBox(height: 20),

          // Yatra Points Section
          YatraPointsSection(
            controller: _yatraPointsController,
            isExpanded: _isYatraPointsDropdownExpanded,
            isApplying: _isApplyingYatraPoints,
            isApplied: _isYatraPointsApplied,
            isLoadingPoints: _isLoadingYatraPoints,
            availablePoints: _availableYatraPoints,
            message: _yatraPointsMessage,
            onToggleExpanded: () {
              setState(() {
                _isYatraPointsDropdownExpanded = !_isYatraPointsDropdownExpanded;
              });
            },
            onApply: _applyYatraPoints,
            onRemove: _removeYatraPoints,
          ),

          const SizedBox(height: 20),

          // Price Breakdown Section
          PriceBreakdownSection(
            subtotalPrice: widget.totalPrice,
            finalPrice: _finalPrice,
            isCouponApplied: _isCouponApplied,
            discountAmount: _discountAmount,
            isYatraPointsApplied: _isYatraPointsApplied,
          ),

          const SizedBox(height: 30),
          const Text(
            "Payment Method",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 14),
          InkWell(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/logos/esewa.png",
                  height: 60,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          ButtonWidget(
            onPressed: _isBooking
                ? null
                : () {
                    _payThroughEsewa();
                  },
            text: _isBooking ? 'Processing...' : 'Confirm Booking',
          ),
          const SizedBox(height: 20),
          ButtonWidget(
            onPressed: _isBooking
                ? null
                : () {
                    _directBookTicket();
                  },
            text: _isBooking ? 'Booking...' : 'Test Booking',
          ),
        ],
      ),
    );
  }
}
