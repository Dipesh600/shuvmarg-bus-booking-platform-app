import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/buss_ticket_search_screen.dart';
import 'package:sumarg/views/hiace_screen.dart';
import 'package:sumarg/views/jeep_screen.dart';
import 'package:sumarg/views/minit_bus_screen.dart';
import 'package:sumarg/views/notification_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/notification_provider.dart';
import 'package:sumarg/providers/profile_provider.dart';

class NewDashboardScreen extends StatefulWidget {
  const NewDashboardScreen({super.key});

  @override
  State<NewDashboardScreen> createState() =>
      _NewDashboardScreenState();
}

class _NewDashboardScreenState extends State<NewDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Defer loading notification data to after the first frame to avoid 
    // notifyListeners() during build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotificationData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Function to load notification count and access token
  Future<void> _loadNotificationData() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    // Fetch real notification count from API if user is logged in
    if (!profileProvider.needsLogin) {
      await notificationProvider.loadNotifications();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 100, // Taller for premium header
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.swap_calls_rounded, color: AppColors.secondary, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "SUMARG",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Explore Beyond",
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          Consumer2<ProfileProvider, NotificationProvider>(
            builder: (context, profileProvider, notificationProvider, _) {
              final isLoggedIn = !profileProvider.needsLogin;
              final unreadCount = notificationProvider.unreadCount;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, // Premium thin icon
                          color: AppColors.primary, size: 28),
                    onPressed: () async {
                      if (!isLoggedIn) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        // Navigate to NotificationHistoryScreen
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NotificationHistoryScreen(),
                          ),
                        );

                        // Refresh notification count when returning from notification screen
                        if (result == true) {
                          await notificationProvider.refreshNotifications();
                        }
                      }
                    },
                  ),
                  ),
                  if (isLoggedIn && unreadCount > 0) ...[
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary, // Orange for active
          unselectedLabelColor: Colors.grey.shade400,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(
              icon: Icon(Icons.directions_bus),
              text: 'Bus',
            ),
            Tab(
              icon: Icon(Icons.airport_shuttle),
              text: 'Mini Bus',
            ),
            Tab(
              icon: Icon(Icons.local_taxi),
              text: 'Hiace',
            ),
            Tab(
              icon: Icon(Icons.directions_car),
              text: 'Jeep',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BusTicketSearchScreen(),
          MiniBusScreen(),
          HiceScreen(),
          JeepScreen(),
        ],
      ),
    );
  }
}
