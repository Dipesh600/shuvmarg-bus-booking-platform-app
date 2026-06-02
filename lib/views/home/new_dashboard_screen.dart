import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/profile_provider.dart';
import 'package:sumarg/providers/notification_provider.dart';
import 'package:sumarg/controllers/auth_controller/login_provider.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/widgets/glass_card.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/notifications/notification_history_screen.dart';
import 'package:sumarg/views/search/buss_ticket_search_screen.dart';
import 'package:sumarg/utils/page_transitions.dart';
import 'package:sumarg/views/wallet/wallet_screen.dart';


class NewDashboardScreen extends StatefulWidget {
  const NewDashboardScreen({super.key});

  @override
  State<NewDashboardScreen> createState() => _NewDashboardScreenState();
}

class _NewDashboardScreenState extends State<NewDashboardScreen> {
  int _selectedCategoryIndex = 0; // 0: Bus, 1: Mini Bus, 2: Hiace, 3: Jeep
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    final loginProvider =
        Provider.of<LoginProvider>(context, listen: false);

    if (loginProvider.isLoggedIn) {
      await notificationProvider.loadNotifications();
    }
  }

  Widget _buildCategoryIcon(
      {required int index, required IconData icon, required String label}) {
    bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.accentLime : Colors.transparent,
                width: 2,
              ),
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.04),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppTheme.accentLime : AppTheme.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.accentLime : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        children: [
          // Background Hero Image — positioned below the fixed header
          Positioned(
            top: 50, // Reverted to original position
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/home_bus.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
                // Bottom fade to blend into the background
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.primaryDark],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ───────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Space for the header and bus illustration
                  const SizedBox(height: 240),

                  // =========================
                  // VEHICLE CATEGORIES ROW
                  // =========================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCategoryIcon(
                              index: 0,
                              icon: Icons.directions_bus,
                              label: "Bus"),
                          _buildCategoryIcon(
                              index: 1,
                              icon: Icons.airport_shuttle,
                              label: "Mini Bus"),
                          _buildCategoryIcon(
                              index: 2,
                              icon: Icons.local_taxi,
                              label: "Hiace"),
                          _buildCategoryIcon(
                              index: 3,
                              icon: Icons.directions_car,
                              label: "Jeep"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // =========================
                  // DYNAMIC CONTENT
                  // =========================
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedCategoryIndex == 0
                        ? const BusTicketSearchScreen()
                        : _buildComingSoonCard(
                            key: ValueKey(_selectedCategoryIndex),
                          ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Fixed header (never scrolls, stays on top of scroll content) ────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: (_scrollOffset / 10).clamp(0.0, 10.0),
                  sigmaY: (_scrollOffset / 10).clamp(0.0, 10.0),
                ),
                child: Container(
                  color: AppTheme.primaryDark.withOpacity(
                    (_scrollOffset / 100).clamp(0.0, 0.85),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 12.0),
              child: Consumer2<NotificationProvider, ProfileProvider>(
                builder: (context, notificationProvider, profileProvider, _) {
                  final isLoggedIn = !profileProvider.needsLogin;
                  final unreadCount = notificationProvider.unreadCount;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BRAND LOGO TYPOGRAPHY
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Shuv ',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary),
                                ),
                                TextSpan(
                                  text: 'Marg',
                                  style: TextStyle(
                                      color: AppTheme.accentLime),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Safe journeys, every time",
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ],
                      ),

                      // RIGHT ACTIONS: WALLET & NOTIFICATION
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLoggedIn) ...[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PremiumFadeRoute(page: const WalletScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryDark.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.stroke, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/home_wallet.png',
                                      width: 18,
                                      height: 18,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 6),
                                    if (!profileProvider.isWalletEnabled) ...[
                                      // PIN not set — show lock icon instead of balance
                                      const Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppTheme.accentLime,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Setup',
                                        style: TextStyle(
                                          color: AppTheme.accentLime,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: AppTheme.fontFamily,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        'Rs. ${profileProvider.walletBalance?.toStringAsFixed(0) ?? '0'}',
                                        style: const TextStyle(
                                          color: AppTheme.accentLime,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: AppTheme.fontFamily,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          // NOTIFICATION BELL
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final loginProvider =
                                      Provider.of<LoginProvider>(context,
                                          listen: false);
                                  final isUserCurrentlyLoggedIn =
                                      loginProvider.isLoggedIn;

                                  if (!isUserCurrentlyLoggedIn) {
                                    Navigator.push(
                                      context,
                                      PremiumFadeRoute(page: const LoginScreen()),
                                    );
                                  } else {
                                    final result = await Navigator.push(
                                      context,
                                      PremiumFadeRoute(
                                          page: const NotificationHistoryScreen()),
                                    );
                                    if (result == true) {
                                      await notificationProvider
                                          .refreshNotifications();
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppTheme.stroke, width: 1),
                                    color: Colors.transparent,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppTheme.textPrimary,
                                    size: 22,
                                  ),
                                ),
                              ),
                              if (isLoggedIn && unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentLime,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppTheme.primaryDark,
                                          width: 2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard({Key? key}) {
    final labels = ['', 'Mini Bus', 'Hiace', 'Jeep'];
    final icons = [
      Icons.directions_bus,
      Icons.airport_shuttle_outlined,
      Icons.local_taxi_outlined,
      Icons.directions_car_outlined,
    ];
    final subtitles = [
      '',
      'Mini bus booking services',
      'Hiace booking services',
      'Jeep booking services',
    ];
    final i = _selectedCategoryIndex;

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.accentLime.withValues(alpha: 0.3)),
              ),
              child: Icon(icons[i], size: 26, color: AppTheme.accentLime),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labels[i],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subtitles[i]} is coming soon!',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontFamily: AppTheme.fontFamily,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentLime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.accentLime.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'SOON',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentLime,
                  letterSpacing: 1.2,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
