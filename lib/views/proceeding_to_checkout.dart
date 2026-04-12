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
import 'package:sumarg/views/ticket_screen.dart';
import 'package:sumarg/views/widgets/button_widget.dart';

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
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ticket ID
                  // Text(
                  //   '174-36-XXXX',
                  //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  //         fontWeight: FontWeight.bold,
                  //         letterSpacing: 1.2,
                  //       ),
                  // ),
                  // const SizedBox(height: 20),
                  // Route and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            widget.busData.departureTime,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.busData.routeDetail.from,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Divider(
                            color: Colors.orange,
                            thickness: 2,
                            height: 20,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            widget.busData.arrivalTime,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.busData.routeDetail.to,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Selected Seats",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(widget.selectedSeats,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date and Bus No
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Date",
                                style: TextStyle(color: Colors.grey)),
                            Text(widget.busData.tripDate),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Booking Time",
                                style: TextStyle(color: Colors.grey)),
                            Text("11:25 AM"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Passenger Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Passenger",
                              style: TextStyle(color: Colors.grey)),
                          Text(widget.name),
                        ],
                      ),
                      // Column(
                      //  crossAxisAlignment: CrossAxisAlignment.end,
                      //  children: const [
                      //   Text("ID", style: TextStyle(color: Colors.grey)),
                      //   Text("246-87-XXXX"),
                      //  ],
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Buss Name",
                              style: TextStyle(color: Colors.grey)),
                          Text(widget.busData.busDetail.busName),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Bus No",
                              style: TextStyle(color: Colors.grey)),
                          Text(widget.busData.busDetail.busNumber),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Boarding Points Section
          if (widget.busData.busDetail.amenities.isNotEmpty)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Boarding Point",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBoardingPoint,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                          ),
                          hint: const Text(
                            'Select boarding point',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          items: widget.busData.busDetail.amenities.map((String point) {
                            return DropdownMenuItem<String>(
                              value: point,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedBoardingPoint = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Coupon Section (Outside of ticket card)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Dropdown Header
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isCouponDropdownExpanded = !_isCouponDropdownExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Have a Coupon Code?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isCouponDropdownExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 24,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dropdown Content
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _isCouponDropdownExpanded ? null : 0,
                    child: _isCouponDropdownExpanded
                        ? Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _couponController,
                                        enabled: !_isCouponApplied,
                                        decoration: InputDecoration(
                                          hintText: 'Enter coupon code',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Colors.blue, width: 2),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          filled: true,
                                          fillColor: _isCouponApplied
                                              ? Colors.grey.shade100
                                              : Colors.white,
                                        ),
                                        textCapitalization:
                                            TextCapitalization.characters,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    ElevatedButton(
                                      onPressed: _isCouponApplied
                                          ? _removeCoupon
                                          : (_isApplyingCoupon
                                              ? null
                                              : _applyCoupon),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isCouponApplied
                                            ? Colors.red
                                            : Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isApplyingCoupon
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              _isCouponApplied
                                                  ? 'Remove'
                                                  : 'Apply',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                                if (_couponMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _isCouponApplied
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _isCouponApplied
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.red.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isCouponApplied
                                              ? Icons.check_circle
                                              : Icons.error,
                                          color: _isCouponApplied
                                              ? Colors.green
                                              : Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _couponMessage!,
                                            style: TextStyle(
                                              color: _isCouponApplied
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Yatra Points Section
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Dropdown Header
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isYatraPointsDropdownExpanded =
                            !_isYatraPointsDropdownExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Use Yatra Points?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isYatraPointsDropdownExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 24,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dropdown Content
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _isYatraPointsDropdownExpanded ? null : 0,
                    child: _isYatraPointsDropdownExpanded
                        ? Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                // Available points info
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.stars,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      _isLoadingYatraPoints
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.green,
                                              ),
                                            )
                                          : Text(
                                              'Available Points: $_availableYatraPoints',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _yatraPointsController,
                                        enabled: !_isYatraPointsApplied,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Enter points to use',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Colors.green, width: 2),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          filled: true,
                                          fillColor: _isYatraPointsApplied
                                              ? Colors.grey.shade100
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    ElevatedButton(
                                      onPressed: _isYatraPointsApplied
                                          ? _removeYatraPoints
                                          : (_isApplyingYatraPoints ||
                                                  _isLoadingYatraPoints
                                              ? null
                                              : _applyYatraPoints),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isYatraPointsApplied
                                            ? Colors.red
                                            : Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isApplyingYatraPoints ||
                                              _isLoadingYatraPoints
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              _isYatraPointsApplied
                                                  ? 'Remove'
                                                  : 'Apply',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                                if (_yatraPointsMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _isYatraPointsApplied
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _isYatraPointsApplied
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.red.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isYatraPointsApplied
                                              ? Icons.check_circle
                                              : Icons.error,
                                          color: _isYatraPointsApplied
                                              ? Colors.green
                                              : Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _yatraPointsMessage!,
                                            style: TextStyle(
                                              color: _isYatraPointsApplied
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Price Breakdown Section (Outside of ticket card)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Price Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Subtotal",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Rs. ${widget.totalPrice}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (_isCouponApplied) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Coupon Discount",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "- Rs. ${_discountAmount.round()}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_isYatraPointsApplied) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Yatra Points Discount",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "- Rs. ${widget.totalPrice - _finalPrice}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_isCouponApplied || _isYatraPointsApplied) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.orange, thickness: 1),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Rs. $_finalPrice",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
