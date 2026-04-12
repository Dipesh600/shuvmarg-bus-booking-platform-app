import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/controllers/auth_controller/auth_controller.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/auth/login_screen.dart';
import 'package:sumarg/views/change_password_screen.dart';
import 'package:sumarg/views/change_profile_picture.dart';
import 'package:sumarg/views/emergency_contact.dart';
import 'package:sumarg/views/help_center_screen.dart';
import 'package:sumarg/views/invite_friends_page.dart';
import 'package:sumarg/views/privacy_policy_screen.dart';
import 'package:sumarg/views/refereal_history_screen.dart';
import 'package:sumarg/views/reward_history_screen.dart';
import 'package:sumarg/views/support_screen.dart';
import 'package:sumarg/views/terms_condition_screen.dart';
import 'package:sumarg/views/widgets/loading_widgets/profile_loading.dart';
import 'package:sumarg/providers/profile_provider.dart';

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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

  Future<void> _logout() async {
    try {
      await _authController.clearLoginData();
      if (mounted) {
        // Clear local provider data if needed or just redirect
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied to clipboard'),
        duration: Duration(seconds: 2),
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
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: profile.isLoading || profile.name == null
              ? const ProfileLoading()
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(profile),
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildSettingsSection(profile),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(ProfileProvider profile) {
    return SliverAppBar(
      expandedHeight: 420,
      floating: false,
      pinned: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildProfileHeader(profile),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider profile) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  _buildAvatarSection(profile),
                  const SizedBox(height: 12),
                  _buildNameEmailSection(profile),
                  const SizedBox(height: 12),
                  _buildStatsStrip(profile),
                  const SizedBox(height: 12),
                  if (!profile.referralLoading &&
                      profile.referralDashboard != null &&
                      profile.referralDashboard!.status)
                    _buildReferralCodeCard(profile),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(ProfileProvider profile) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.7 + 0.3 * value,
          child: Opacity(
            opacity: value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 98,
                  height: 98,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFF8C00),
                        Color(0xFFFF4D79),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withOpacity(0.4 * value),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeProfilePicture(
                          name: profile.name ?? '',
                          profilePic: profile.profilePic ?? '',
                        ),
                      ),
                    );
                    if (result == true) {
                      context.read<ProfileProvider>().refreshProfile();
                    }
                  },
                  child: Hero(
                    tag: 'profilePicture',
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: profile.profilePic != null &&
                                profile.profilePic!.isNotEmpty
                            ? Image.network(
                                profile.profilePic!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.network(
                                  'https://giftolexia.com/wp-content/uploads/2015/11/dummy-profile.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.network(
                                'https://giftolexia.com/wp-content/uploads/2015/11/dummy-profile.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeProfilePicture(
                            name: profile.name ?? '',
                            profilePic: profile.profilePic ?? '',
                          ),
                        ),
                      );
                      if (result == true) {
                        context.read<ProfileProvider>().refreshProfile();
                      }
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameEmailSection(ProfileProvider profile) {
    return Column(
      children: [
        Text(
          profile.name ?? '',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email ?? '',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (profile.phone != null && profile.phone!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.phone!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 11),
                    SizedBox(width: 3),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatsStrip(ProfileProvider profile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFF59E0B).withOpacity(0.25),
            value: profile.yatraLoading
                ? '...'
                : (profile.yatraPoints?.toStringAsFixed(0) ?? '—'),
            label: 'Yatra Points',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip(
            icon: Icons.group_rounded,
            iconColor: const Color(0xFF60A5FA),
            iconBg: const Color(0xFF60A5FA).withOpacity(0.25),
            value: profile.referralLoading
                ? '...'
                : (profile.referralDashboard?.data.totalUsersUsedCode
                        .toString() ??
                    '—'),
            label: 'Referrals',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip(
            icon: Icons.diamond_rounded,
            iconColor: const Color(0xFFA78BFA),
            iconBg: const Color(0xFFA78BFA).withOpacity(0.25),
            value: profile.referralLoading
                ? '...'
                : (profile.referralDashboard?.data.totalReferralPoints
                        .toString() ??
                    '—'),
            label: 'Ref. Points',
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.6),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(ProfileProvider profile) {
    if (profile.referralDashboard == null) return const SizedBox.shrink();
    final code = profile.referralDashboard!.data.referralCode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REFERRAL CODE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.55),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _copyReferralCode(code),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text(
                    'Copy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ProfileProvider profile) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _buildSettingsGroup(
            title: 'Bonus History',
            items: [
              _buildSettingItem(
                icon: Icons.card_giftcard,
                title: 'Yatra Points History',
                subtitle: 'All Reward History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RewardHistoryScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.ios_share,
                title: 'Referal History',
                subtitle: 'Earn yatra points per referal',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReferalHistoryScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.group_add_rounded,
                title: 'Invite Friends',
                subtitle: 'Share your referral code',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InviteFriendsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSettingsGroup(
            title: 'Account Settings',
            items: [
              _buildSettingItem(
                icon: Icons.person_outline,
                title: 'Personal information',
                subtitle: 'View and edit your personal info',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeProfilePicture(
                        name: profile.name ?? '',
                        profilePic: profile.profilePic ?? '',
                      ),
                    ),
                  );
                  if (result == true) {
                    context.read<ProfileProvider>().refreshProfile();
                  }
                },
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'Change password',
                subtitle: 'Update your password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.delete_forever_outlined,
                title: 'Delete account',
                subtitle: 'Permanently delete your account',
                onTap: _handleDeleteAccount,
              ),
            ],
          ),
          _buildSettingsGroup(
            title: 'App Preferences',
            items: [
              _buildSettingItem(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English/Nepali',
                onTap: _showLanguageDialog,
              ),
              _buildSettingItem(
                icon: Icons.payment_outlined,
                title: 'Default payment method',
                subtitle: 'Choose your payment method',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.brightness_6_outlined,
                title: 'Theme',
                subtitle: 'Light/Dark mode',
                onTap: () {},
              ),
            ],
          ),
          _buildSettingsGroup(
            title: 'Booking Preferences',
            items: [
              _buildSettingItem(
                icon: Icons.route_outlined,
                title: 'Frequent routes',
                subtitle: 'View and manage saved routes',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.contact_phone_outlined,
                title: 'Emergency contacts',
                subtitle: 'Manage emergency contacts',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyContact(),
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSettingsGroup(
            title: 'Support & Help',
            items: [
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Help center/FAQ',
                subtitle: 'Get help and find answers',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.support_agent_outlined,
                title: 'Contact support',
                subtitle: 'Get in touch with support',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SupportScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.star_rate_outlined,
                title: 'Rate app',
                subtitle: 'Share your feedback',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.article_outlined,
                title: 'Terms & conditions',
                subtitle: 'Read our terms and conditions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsConditionScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy policy',
                subtitle: 'View our privacy policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSignOutButton(),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.grey[500],
                letterSpacing: 0.6,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleSignOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
          'Are you sure you want to delete your account? This action is permanent and all your data (trips, points, profile) will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would call an API. 
              // For now, we clear data and logout.
              _logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
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
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = [
      {'name': 'English', 'flag': '🇺🇸'},
      {'name': 'Nepali', 'flag': '🇳🇵'},
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              ...languages.map(
                (lang) => _buildLanguageOption(
                  lang['name'] as String,
                  lang['flag'] as String,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String name, String flag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
