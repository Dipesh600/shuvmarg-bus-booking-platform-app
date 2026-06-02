import 'package:flutter/material.dart';
import 'package:sumarg/widgets/custom_bottom_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/auth_controller/login_provider.dart';
import 'package:sumarg/providers/ticket_provider.dart';
import 'package:sumarg/providers/profile_provider.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  void _loadLoginStatus() {
    Future.microtask(() {
      Provider.of<LoginProvider>(context, listen: false).loadLoginStatus();
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
            isLoggedIn ? const UserProfileScreen() : const LoginScreen(),
          ];

          return IndexedStack(
            index: _selectedIndex,
            children: screens,
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: CustomBottomNavBar(
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
            // Refresh wallet balance when switching to Home or Profile
            if (index == 0 || index == 3) {
              Provider.of<ProfileProvider>(context, listen: false)
                  .refreshWalletBalance();
            }
          },
        ),
      ),
    );
  }
}
