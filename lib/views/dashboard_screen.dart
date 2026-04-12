import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/widgets/available_busses_widget.dart';
import 'package:sumarg/views/widgets/search_widget.dart';
import 'available_busses_screen.dart';

class AvailableBuses extends StatefulWidget {
  const AvailableBuses({super.key});

  @override
  State<AvailableBuses> createState() => _AvailableBusesState();
}

class _AvailableBusesState extends State<AvailableBuses> {
  String? name;
  String? email;
  String? profilePic;
  @override
  void initState() {
    super.initState();
    _getProfileDetail();
  }

  Future<void> _getProfileDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        name = prefs.getString('name');
        email = prefs.getString('email');
        profilePic = prefs.getString('profilePicture');
      });
    } catch (e) {
      debugPrint("Error loading profile data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   backgroundColor: AppColors.background,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   title: Row(
      //     children: [
      //       CircleAvatar(
      //         radius: 20,
      //         backgroundColor: Colors.white,
      //         child: CircleAvatar(
      //           backgroundImage: NetworkImage(profilePic ??
      //               "https://giftolexia.com/wp-content/uploads/2015/11/dummy-profile.png"),
      //           radius: 26,
      //         ),
      //       ),
      //       const SizedBox(width: 10),
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           const Text(
      //             "Welcome",
      //             style: TextStyle(
      //               fontSize: 12,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           // Text(
      //           //   name!.split(' ').first,
      //           //   style: const TextStyle(fontSize: 10),
      //           // ),
      //         ],
      //       )
      //     ],
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              // Container(
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFD9F1F1),
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   padding: const EdgeInsets.all(16),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             const Text(
              //               "Travel at your own convience",
              //               style: TextStyle(
              //                   fontSize: 16, fontWeight: FontWeight.bold),
              //             ),
              //             const SizedBox(height: 8),
              //             ElevatedButton(
              //               onPressed: () {},
              //               style: ElevatedButton.styleFrom(
              //                 backgroundColor: Colors.teal,
              //                 shape: RoundedRectangleBorder(
              //                   borderRadius: BorderRadius.circular(8),
              //                 ),
              //               ),
              //               child: const Text("Book now"),
              //             )
              //           ],
              //         ),
              //       ),
              //       const SizedBox(width: 16),
              //       SizedBox(
              //         height: 80,
              //         width: 60,
              //         child: Image.network(
              //             'https://cdn-icons-png.flaticon.com/512/201/201623.png'),
              //       )
              //     ],
              //   ),
              // ),
              // ListTile(
              //   title: const Text(
              //     "Welcome",
              //     style: TextStyle(color: Colors.black),
              //   ),
              //   subtitle: Text(
              //     name ?? "Guest User",
              //     style: const TextStyle(color: Colors.grey),
              //   ),
              //   leading: CircleAvatar(
              //     radius: 20,
              //     backgroundColor: Colors.white,
              //     child: CircleAvatar(
              //       backgroundImage: NetworkImage(profilePic ??
              //           "https://giftolexia.com/wp-content/uploads/2015/11/dummy-profile.png"),
              //       radius: 26,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
              // Search
              const Search(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Moving today",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text("See all",
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 270,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) => busCard(context),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Available buses",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AvailableBussesScreen()));
                    },
                    child: Row(
                      children: [
                        Text("See all",
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              // ticket
              const SizedBox(
                height: 400,
                child: AvailableBussesWidget(),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

Widget busCard(BuildContext context) {
  return Container(
    width: 180,
    margin: const EdgeInsets.only(right: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Minimize column height
      children: [
        // Bus Image
        Center(
          child: Image.asset(
            'assets/busses/buss-2.png',
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),

        // Departure time
        Row(
          children: [
            Text("Departs at ", style: TextStyle(color: Colors.grey)),
            Text(
              "4:30 pm",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // From location
        Row(
          children: [
            Icon(Icons.radio_button_checked,
                color: Colors.red, size: 14),
            SizedBox(width: 6),
            Text("From "),
            SizedBox(width: 4),
            Text(
              "Kathmandu",
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 6),
              width: 1,
              height: 8,
              color: Colors.grey,
            ),
            Container(
              margin: const EdgeInsets.only(left: 6),
              width: 1,
              height: 8,
              color: Colors.grey,
            ),
          ],
        ),

        // To location
        Row(
          children: const [
            Icon(Icons.radio_button_checked,
                color: Colors.green, size: 14),
            SizedBox(width: 6),
            Text("To "),
            Text(
              "Biratnagar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Seats
        const Text(
          "4 seats available",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        // Book Now Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text(
              "Book Now",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
