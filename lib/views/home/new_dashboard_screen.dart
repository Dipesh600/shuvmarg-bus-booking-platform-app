import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/profile_provider.dart';
import 'package:sumarg/providers/notification_provider.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/notifications/notification_history_screen.dart';
import 'package:sumarg/views/search/buss_ticket_search_screen.dart';
import 'package:sumarg/views/buses/hiace_screen.dart';
import 'package:sumarg/views/buses/jeep_screen.dart';
import 'package:sumarg/views/buses/minit_bus_screen.dart';

class NewDashboardScreen extends StatefulWidget {
  const NewDashboardScreen({super.key});

  @override
  State<NewDashboardScreen> createState() => _NewDashboardScreenState();
}

class _NewDashboardScreenState extends State<NewDashboardScreen> {
  int _selectedCategoryIndex = 0; // 0: Bus, 1: Mini Bus, 2: Hiace, 3: Jeep

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    if (!profileProvider.needsLogin) {
      await notificationProvider.loadNotifications();
    }
  }

  Widget _buildCategoryIcon({required int index, required IconData icon, required String label}) {
    bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                width: 2,
              ),
              color: AppColors.primaryDarker,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.secondary : AppColors.secondary.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // 1. BRAND HEADER & NOTIFICATIONS
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, _) {
                    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                    final isLoggedIn = !profileProvider.needsLogin;
                    final unreadCount = notificationProvider.unreadCount;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // BRAND LOGO TYPOGRAPHY
                        const Text(
                          "shuvmarg",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                          ),
                        ),

                        // NOTIFICATION BELL
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final currentProfile = Provider.of<ProfileProvider>(context, listen: false);
                                final isUserCurrentlyLoggedIn = !currentProfile.needsLogin;
                                
                                if (!isUserCurrentlyLoggedIn) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                                } else {
                                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationHistoryScreen()));
                                  if (result == true) {
                                    await notificationProvider.refreshNotifications();
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.8), width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.secondary,
                                  size: 24,
                                ),
                              ),
                            ),
                            if (isLoggedIn && unreadCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary, width: 2),
                                  ),
                                  child: Text(
                                    unreadCount > 9 ? '9+' : '$unreadCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // =========================
              // 3. VEHICLE CATEGORIES ROW
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCategoryIcon(index: 0, icon: Icons.directions_bus, label: "Bus"),
                      const SizedBox(width: 24),
                      _buildCategoryIcon(index: 1, icon: Icons.airport_shuttle, label: "Mini Bus"),
                      const SizedBox(width: 24),
                      _buildCategoryIcon(index: 2, icon: Icons.local_taxi, label: "Hiace"),
                      const SizedBox(width: 24),
                      _buildCategoryIcon(index: 3, icon: Icons.directions_car, label: "Jeep"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // =========================
              // 4. DYNAMIC SEARCH CARD
              // =========================
              IndexedStack(
                index: _selectedCategoryIndex,
                children: const [
                   BusTicketSearchScreen(),
                   MiniBusScreen(),
                   HiceScreen(),
                   JeepScreen(),
                ],
              ),
              
              const SizedBox(height: 80), // Padding above bottom navigation bar
            ],
          ),
        ),
      ),
    );
  }
}
