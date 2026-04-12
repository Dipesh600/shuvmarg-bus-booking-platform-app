import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';

class MoreOptions extends StatefulWidget {
  const MoreOptions({super.key});

  @override
  State<MoreOptions> createState() => _MoreOptionsState();
}

class _MoreOptionsState extends State<MoreOptions> {
  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.card_travel, 'label': 'My Bookings'},
    {'icon': Icons.headset_mic, 'label': 'Customer Support'},
    {'icon': Icons.track_changes, 'label': 'Flight Tracker', 'badge': 'Pro'},
    {'icon': Icons.security, 'label': 'Travel Insurance'},
    {'icon': Icons.credit_card, 'label': 'Credit Card', 'badge': 'Free'},
    {'icon': Icons.group, 'label': 'Group Booking'},
    {'icon': Icons.local_taxi, 'label': 'Airport Cabs'},
    {'icon': Icons.event_note, 'label': 'Plan'},
  ];

  // Function to handle navigation based on the label
  void _navigateToScreen(String label, BuildContext context) {
    if (label == 'My Bookings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
      );
    }
    // Add more conditions for other screens if needed
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "More Options",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // color: AppColors.primary.withOpacity(0.1),
              border: Border.all(
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menuItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return GestureDetector(
                      onTap: () => _navigateToScreen(item['label'], context),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(item['icon'],
                                    size: 32, color: Colors.blue),
                              ),
                              if (item['badge'] != null)
                                Container(
                                  margin:
                                      const EdgeInsets.only(right: 4, top: 2),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item['badge'] == 'Free'
                                        ? Colors.purple
                                        : Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['badge'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['label'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder MyBookingsScreen
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: const Center(
        child: Text(
          'Your Bookings Will Appear Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
