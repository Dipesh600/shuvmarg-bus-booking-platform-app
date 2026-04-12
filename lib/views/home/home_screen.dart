import 'package:flutter/material.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/auth_controller/login_provider.dart';
import 'package:sumarg/providers/ticket_provider.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/tickets/my_trip_screen.dart';
import 'package:sumarg/views/home/new_dashboard_screen.dart';
import 'package:sumarg/views/profile/user_profile_screen.dart';
import 'package:sumarg/views/buses/available_busses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  void _loadLoginStatus() {
    Future.microtask(() {
      Provider.of<LoginProvider>(context, listen: false)
          .loadLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, _) {
          final isLoggedIn = loginProvider.isLoggedIn;

          final List<Widget> screens = [
            const NewDashboardScreen(),
            const AvailableBussesScreen(),
            isLoggedIn
                // ? const AllTicketScreen()
                ? const MyTripScreen()
                : const LoginScreen(),
            isLoggedIn
                ? const UserProfileScreen()
                : const LoginScreen(),
          ];

          return screens[_selectedIndex];
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DotNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                // If navigating to My Trips tab, refresh tickets
                if (index == 2) {
                  final tp = Provider.of<TicketProvider>(context, listen: false);
                  tp.refreshTickets();
                }
              },
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              dotIndicatorColor: AppColors.primary,
              paddingR: const EdgeInsets.symmetric(
                  vertical: 5, horizontal: 10), // Reduced horizontal padding to prevent minor overflow
              marginR: const EdgeInsets.all(0),
              itemPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Adjust internal bounds
              items: [
                DotNavigationBarItem(icon: const Icon(Icons.home)),
                DotNavigationBarItem(
                  icon: const FaIcon(FontAwesomeIcons.busSimple),
                ),
                DotNavigationBarItem(icon: const Icon(Icons.book)),
                DotNavigationBarItem(icon: const Icon(Icons.person)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
