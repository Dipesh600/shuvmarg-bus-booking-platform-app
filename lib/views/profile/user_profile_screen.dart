import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/widgets/glass_card.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/profile/change_password_screen.dart';
import 'package:sumarg/views/profile/change_profile_picture.dart';
import 'package:sumarg/views/support/emergency_contact.dart';
import 'package:sumarg/views/support/help_center_screen.dart';
import 'package:sumarg/views/profile/invite_friends_page.dart';
import 'package:sumarg/views/support/privacy_policy_screen.dart';
import 'package:sumarg/views/profile/refereal_history_screen.dart';
import 'package:sumarg/views/profile/reward_history_screen.dart';
import 'package:sumarg/views/support/support_screen.dart';
import 'package:sumarg/views/support/terms_condition_screen.dart';
import 'package:sumarg/views/widgets/loading_widgets/profile_loading.dart';
import 'package:sumarg/providers/profile_provider.dart';
import 'package:sumarg/views/wallet/wallet_screen.dart';
import 'package:sumarg/views/wallet/wallet_pin_sheet.dart';
import 'package:sumarg/views/tickets/my_trip_screen.dart';
import 'package:sumarg/providers/notification_provider.dart';
import 'package:sumarg/views/notifications/notification_history_screen.dart';
import 'package:sumarg/utils/page_transitions.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  final AuthController _authController = AuthController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Future<void> _logout() async {
    try {
      await _authController.clearLoginData();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error during logout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error logging out. Please try again.")),
        );
      }
    }
  }

  Future<void> _copyReferralCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Referral code copied!',
          style: TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, child) {
        if (profile.needsLogin && !profile.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          });
          return Scaffold(
              backgroundColor: AppTheme.primaryDark,
              body: const Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: AppTheme.primaryDark,
          body: profile.isLoading || profile.name == null
              ? const ProfileLoading()
              : SafeArea(
                  bottom: false,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Stack(
                        children: [
                          // Removed Abstract Background Glow to match consistent top blend
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                // ── HERO HEADER ──
                                _buildHeroHeader(profile),

                                const SizedBox(height: 36),

                                // ── FINTECH WALLET CARD ──
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: _buildFintechWalletCard(profile),
                                ),

                                const SizedBox(height: 32),

                                // ── SMART ACTION RAIL ──
                                _buildSmartActionRail(),

                                const SizedBox(height: 36),

                                // ── STORY CARD (INVITE) ──
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: _buildStoryCard(),
                                ),

                                const SizedBox(height: 48),

                                // ── ACCOUNT SETTINGS ──
                                _buildAccountSection(profile),

                                const SizedBox(height: 36),

                                // ── LEGAL SETTINGS ──
                                _buildLegalSection(),

                                const SizedBox(height: 48),

                                // ── DANGER ZONE ──
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Column(
                                    children: [
                                      _buildSignOutButton(),
                                      const SizedBox(height: 16),
                                      _buildDeleteAccountButton(),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 48),

                                // ── BRANDING & VERSION ──
                                _buildBrandingAndVersion(),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. HERO HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroHeader(ProfileProvider profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                _buildAvatarSection(profile),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600, // SemiBold
                                color: AppTheme.textPrimary,
                                fontFamily: AppTheme.fontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF00B4D8),
                              size: 20,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              final result = await Navigator.push(
                context,
                PremiumFadeRoute(page: const NotificationHistoryScreen()),
              );
              if (result == true) {
                if (context.mounted) {
                  final notificationProvider =
                      Provider.of<NotificationProvider>(context, listen: false);
                  await notificationProvider.refreshNotifications();
                }
              }
            },
            child: Consumer<NotificationProvider>(
              builder: (context, notificationProvider, _) {
                final unreadCount = notificationProvider.unreadCount;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.stroke, width: 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: AppTheme.textPrimary, size: 24),
                      if (unreadCount > 0)
                        Positioned(
                          top: 12,
                          right: 14,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentLime,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(ProfileProvider profile) {
    return GestureDetector(
      onTap: () => _navigateToProfilePicture(profile),
      child: Hero(
        tag: 'profilePicture',
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.textPrimary, AppTheme.accentLime],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentLime.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0), // border width
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryDark,
              ),
              child: ClipOval(
                child: profile.profilePic != null && profile.profilePic!.isNotEmpty
                    ? Image.network(
                        profile.profilePic!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(profile),
                      )
                    : _buildDefaultAvatar(profile),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(ProfileProvider profile) {
    final initials = (profile.name ?? '?')
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      color: AppTheme.primary,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
    );
  }

  void _navigateToProfilePicture(ProfileProvider profile) async {
    final result = await Navigator.push(
      context,
      PremiumFadeRoute(
        page: ChangeProfilePicture(
          name: profile.name ?? '',
          profilePic: profile.profilePic ?? '',
        ),
      ),
    );
    if (result == true && mounted) {
      context.read<ProfileProvider>().refreshProfile();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. FINTECH WALLET CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFintechWalletCard(ProfileProvider profile) {
    final isLoading = profile.walletLoading;
    final balance = profile.walletBalance;
    final balanceWhole = isLoading
        ? '...'
        : (balance?.toStringAsFixed(0) ?? '0');
    final balanceDecimal = isLoading ? '' : '.${_getDecimal(balance)}';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PremiumFadeRoute(page: const WalletScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.95),
              AppTheme.primaryDark.withOpacity(0.98),
            ],
          ),
          border: Border.all(
            color: AppTheme.stroke.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDark.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: AppTheme.accentLime.withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Background Glow Effect ──
            Positioned(
              top: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentLime.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Floating Wallet Illustration ──
            Positioned(
              right: -40,
              top: -30,
              bottom: -30,
              child: Image.asset(
                'assets/images/profile/profile_wallet.png',
                fit: BoxFit.fitHeight,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 135),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                        fontFamily: AppTheme.fontFamily,
                      ),
                      children: [
                        TextSpan(
                          text: 'SHUVMARG ',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        TextSpan(
                          text: 'MONEY',
                          style: TextStyle(color: AppTheme.accentLime),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Balance / State Display ──
                  Builder(builder: (_) {
                    if (isLoading) {
                      // Loading shimmer placeholder
                      return Row(
                        children: [
                          Container(
                            width: 120,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      );
                    }

                    if (profile.isWalletEnabled) {
                      // ✅ PIN is set — show full balance
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            'Rs. ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _formatNumberWithCommas(balanceWhole),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                                fontFamily: AppTheme.fontFamily,
                                height: 1.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            balanceDecimal,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary.withOpacity(0.8),
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ],
                      );
                    }

                    if (balance != null && balance > 0) {
                      // ⚠️ Legacy user — has balance but no PIN
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: AppTheme.accentLime.withOpacity(0.7),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Rs. ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _formatNumberWithCommas(balanceWhole),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary.withOpacity(0.6),
                                fontFamily: AppTheme.fontFamily,
                                height: 1.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }

                    // 🆕 New user — no balance, no PIN
                    return const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Not Active',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontFamily: AppTheme.fontFamily,
                          height: 1.0,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // ── Bottom Row: CTA action ──
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // View Details CTA
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            PremiumFadeRoute(page: const WalletScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLime,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentLime.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            profile.isWalletEnabled
                                ? 'View History'
                                : (balance != null && balance > 0)
                                    ? 'Secure Wallet'
                                    : 'Enable Wallet',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryDark,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDecimal(double? value) {
    if (value == null) return '00';
    final decimal = ((value - value.truncate()) * 100).round();
    return decimal.toString().padLeft(2, '0');
  }

  String _formatNumberWithCommas(String number) {
    if (number == '...') return number;
    final chars = number.split('');
    final result = <String>[];
    for (int i = chars.length - 1, count = 0; i >= 0; i--, count++) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        result.insert(0, ',');
      }
      result.insert(0, chars[i]);
    }
    return result.join();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. SMART ACTION RAIL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSmartActionRail() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildActionChip(
            icon: Icons.directions_bus_outlined,
            label: 'Upcoming Trip',
            iconColor: AppTheme.textPrimary,
            onTap: () {
              Navigator.push(
                context,
                PremiumFadeRoute(page: const MyTripScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
          _buildActionChip(
            icon: Icons.receipt_long_outlined,
            label: 'Refunds',
            iconColor: AppTheme.textPrimary,
            onTap: () {
              Navigator.push(
                context,
                PremiumFadeRoute(page: const RewardHistoryScreen()), // Assuming rewards/refunds share logic for now
              );
            },
          ),
          const SizedBox(width: 12),
          _buildActionChip(
            icon: Icons.headset_mic_outlined,
            label: 'Support',
            iconColor: AppTheme.textPrimary,
            onTap: () {
              Navigator.push(
                context,
                PremiumFadeRoute(page: const SupportScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
          _buildActionChip(
            icon: Icons.health_and_safety_outlined,
            label: 'Emergency',
            iconColor: AppTheme.textPrimary,
            onTap: () {
              Navigator.push(
                context,
                PremiumFadeRoute(page: const EmergencyContact()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDarkest.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500, // Medium
                color: AppTheme.textPrimary,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. STORY CARD (INVITE FRIENDS)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStoryCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PremiumFadeRoute(page: const InviteFriendsPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF1E293B).withOpacity(0.5), // Subtle slate tint
          border: Border.all(
            color: AppTheme.stroke.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // ── Abstract Particles / Gradient ──
              Positioned(
                bottom: -20,
                right: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00B4D8).withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // ── Illustration ──
                    Image.asset(
                      'assets/images/profile/invite_friend.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    
                    // ── Text Content ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Travel together.\nEarn together.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600, // SemiBold
                              color: AppTheme.textPrimary,
                              fontFamily: AppTheme.fontFamily,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Invite friends and unlock premium rewards.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400, // Regular
                              color: AppTheme.textSecondary.withOpacity(0.8),
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Action Arrow ──
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppTheme.textPrimary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. ACCOUNT SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAccountSection(ProfileProvider profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 16),
          child: Text(
            'ACCOUNT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600, // SemiBold
              color: AppTheme.textSecondary.withOpacity(0.6),
              letterSpacing: 1.5,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardBg.withOpacity(0.25),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppTheme.textSecondary,
                    title: 'Personal Information',
                    subtitle: 'View and edit your personal details',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        PremiumFadeRoute(
                          page: ChangeProfilePicture(
                            name: profile.name ?? '',
                            profilePic: profile.profilePic ?? '',
                          ),
                        ),
                      );
                      if (result == true && mounted) {
                        context.read<ProfileProvider>().refreshProfile();
                      }
                    },
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 20, endIndent: 20),
                  _buildListTile(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppTheme.textSecondary,
                    title: 'Wallet & Payments',
                    subtitle: 'Manage balance, cards & refunds',
                    onTap: () {
                      Navigator.push(
                        context,
                        PremiumFadeRoute(page: const WalletScreen()),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 20, endIndent: 20),
                  _buildListTile(
                    icon: Icons.settings_outlined,
                    iconColor: AppTheme.textSecondary,
                    title: 'Security & Settings',
                    subtitle: 'Change password & preferences',
                    onTap: () {
                      Navigator.push(
                        context,
                        PremiumFadeRoute(page: const ChangePasswordScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. LEGAL SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 16),
          child: Text(
            'MORE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600, // SemiBold
              color: AppTheme.textSecondary.withOpacity(0.6),
              letterSpacing: 1.5,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardBg.withOpacity(0.25),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppTheme.textSecondary,
                    title: 'Help Center & FAQ',
                    subtitle: 'Get help and find answers',
                    onTap: () {
                      Navigator.push(
                        context,
                        PremiumFadeRoute(page: const HelpCenterScreen()),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 20, endIndent: 20),
                  _buildListTile(
                    icon: Icons.article_outlined,
                    iconColor: AppTheme.textSecondary,
                    title: 'Terms & Conditions',
                    subtitle: 'Read our platform rules',
                    onTap: () {
                      Navigator.push(
                        context,
                        PremiumFadeRoute(page: const TermsConditionScreen()),
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 20, endIndent: 20),
                  _buildListTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppTheme.textSecondary,
                    title: 'Privacy Policy',
                    subtitle: 'View our privacy policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        PremiumFadeRoute(page: const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Adjusted horizontal padding to 20 for card fit
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Medium
                      color: AppTheme.textPrimary,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400, // Regular
                      color: AppTheme.textSecondary.withOpacity(0.8),
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppTheme.textSecondary.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DANGER ZONE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleSignOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // Pill shape
            side: BorderSide(color: AppTheme.stroke, width: 1),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: _handleDeleteAccount,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // Pill shape
          ),
        ),
        child: const Text(
          'Delete Account',
          style: TextStyle(
            color: Color(0xFFFF4D4F),
            fontSize: 15,
            fontWeight: FontWeight.w500, // Medium
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Account',
            style: TextStyle(color: Color(0xFFFF4D4F))),
        content: const Text(
          'Are you sure you want to delete your account? This action is permanent and all your data (trips, balance, profile) will be removed.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textPrimary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D4F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
            child: const Text(
              'Delete',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sign Out',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentLime,
                foregroundColor: AppTheme.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100))),
            child: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BRANDING & VERSION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBrandingAndVersion() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.0,
              ),
              children: [
                TextSpan(
                  text: 'Shuv ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Marg',
                  style: TextStyle(color: AppTheme.accentLime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Safe journeys, every time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary.withOpacity(0.4),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
