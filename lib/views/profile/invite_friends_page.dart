import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sumarg/controllers/referal_controller/referal_controller.dart';
import 'package:sumarg/models/referal_dashboard_response.dart';
import 'package:intl/intl.dart';
import 'referral_faq_sheet.dart';

// Sumarg Design Tokens as per the rulebook
class SumargColors {
  static const Color primary = Color(0xFF00564E);
  static const Color primaryDark = Color(0xFF003D38);
  static const Color secondary = Color(0xFF568C82);
  static const Color accentLime = Color(0xFFD3D925);
  static const Color accentGold = Color(0xFFD9CD25);
  static const Color textPrimary = Color(0xFFF5F7F6);
  static const Color textSecondary = Color(0xFFB7C7C3);
  static const Color stroke = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
}

/// Invite Friends Page — Referral V2 (Progressive Unlock)
/// Sumarg Visual Language: Dark UI + Glassmorphism + Lime Accent
class InviteFriendsPage extends StatefulWidget {
  const InviteFriendsPage({super.key});

  @override
  State<InviteFriendsPage> createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {
  final ReferalController _controller = ReferalController();
  ReferralDashboardData? _dashboardData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _controller.getReferalDashboard();

    setState(() {
      _isLoading = false;
      if (result.status) {
        _dashboardData = result.data;
      } else {
        _error = result.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SumargColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Invite Friends',
          style: TextStyle(
            color: SumargColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: SumargColors.textPrimary),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => ReferralFaqSheet.show(context),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'FAQ',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    SumargColors.primary.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    SumargColors.accentLime.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: SumargColors.accentLime))
                : _error != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadDashboard,
                        color: SumargColors.primaryDark,
                        backgroundColor: SumargColors.accentLime,
                        child: _buildContent(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: SumargColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Something went wrong',
            style: const TextStyle(color: SumargColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: SumargColors.accentLime,
              foregroundColor: SumargColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _dashboardData!;
    final summary = data.summary;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HERO BANNER ──────────────────────────────────────────
          _buildHeroBanner(data.referralCode),

          const SizedBox(height: 32),

          // ── EARNINGS SUMMARY ─────────────────────────────────────
          _buildEarningsSummary(summary),

          const SizedBox(height: 32),

          // ── HOW IT WORKS ─────────────────────────────────────────
          _buildHowItWorks(),

          const SizedBox(height: 32),

          // ── REFERRAL LIST ────────────────────────────────────────
          if (data.referrals.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Your Referrals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: SumargColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...data.referrals.map((r) => _buildReferralCard(r)).toList(),
          ] else ...[
            _buildEmptyState(),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HERO BANNER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildHeroBanner(String code) {
    final shareText =
        'Join Shuvmarg and travel smart! Use my referral code $code to get started. Download now: https://shuvmarg.com';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 86, 78, 0.88),
          border: Border.all(color: SumargColors.stroke),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 86, 78, 0.25),
              blurRadius: 40,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard, color: SumargColors.accentLime, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Invite & Earn',
                    style: TextStyle(
                      color: SumargColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Earn up to NPR 100 per friend',
                    style: TextStyle(
                      color: SumargColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Code card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: SumargColors.stroke),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          code.isNotEmpty ? code : '—',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: SumargColors.accentLime,
                            letterSpacing: 2,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (code.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Code copied!',
                                    style: TextStyle(color: SumargColors.primaryDark, fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: SumargColors.accentLime,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: SumargColors.accentLime.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.copy, color: SumargColors.accentLime, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Share button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Share.share(shareText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SumargColors.accentLime,
                        foregroundColor: SumargColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Share Link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EARNINGS SUMMARY
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEarningsSummary(ReferralSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'Earned',
              value: 'Rs. ${summary.totalEarned.toInt()}',
              isHighlighted: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              label: 'Locked',
              value: 'Rs. ${summary.totalLocked.toInt()}',
              isHighlighted: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 86, 78, 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SumargColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: SumargColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isHighlighted ? SumargColors.accentLime : SumargColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HOW IT WORKS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildHowItWorks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How it works',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: SumargColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 86, 78, 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: SumargColors.stroke),
            ),
            child: Column(
              children: [
                _buildStep('1', 'Friend signs up using your code'),
                const SizedBox(height: 20),
                _buildStep('2', 'Rs. 100 gets locked in your wallet'),
                const SizedBox(height: 20),
                _buildStep('3', 'Money unlocks as friend completes trips'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Rs. 30 → 20 → 20 → 20 → 10',
                    style: TextStyle(
                      fontSize: 14,
                      color: SumargColors.accentLime,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: SumargColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: SumargColors.stroke),
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                color: SumargColors.accentLime,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: SumargColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // REFERRAL CARD
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildReferralCard(ReferralEntry referral) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 86, 78, 0.88),
        border: Border.all(color: SumargColors.stroke),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 86, 78, 0.25),
            blurRadius: 40,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.04),
                      child: Text(
                        referral.referredUser.name.isNotEmpty
                            ? referral.referredUser.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: SumargColors.accentLime,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            referral.referredUser.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: SumargColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${referral.journeysCompleted} trips completed',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SumargColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (referral.status == 'FULLY_UNLOCKED')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: SumargColors.accentLime.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Complete',
                          style: TextStyle(
                            fontSize: 10,
                            color: SumargColors.accentLime,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10,
                            color: SumargColors.textPrimary.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Earned vs Locked row
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat(
                        'Earned',
                        'Rs. ${referral.totalUnlocked.toInt()}',
                        SumargColors.accentLime,
                      ),
                    ),
                    Container(width: 1, height: 30, color: SumargColors.stroke),
                    Expanded(
                      child: _buildMiniStat(
                        'Locked',
                        'Rs. ${referral.lockedRemaining.toInt()}',
                        SumargColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Dots Timeline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (i) {
                    final journeyNum = i + 1;
                    final unlocked = referral.unlockHistory
                        .any((h) => h.journeyNumber == journeyNum);
                    
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? SumargColors.accentLime.withOpacity(0.1)
                            : Colors.white.withOpacity(0.02),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: unlocked
                              ? SumargColors.accentLime.withOpacity(0.3)
                              : SumargColors.stroke,
                        ),
                      ),
                      child: Center(
                        child: unlocked
                            ? const Icon(Icons.check, size: 16, color: SumargColors.accentLime)
                            : Text(
                                '$journeyNum',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: SumargColors.textSecondary.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: SumargColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 86, 78, 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SumargColors.stroke),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: SumargColors.secondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No referrals yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: SumargColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your code with friends to start earning!',
            style: TextStyle(fontSize: 14, color: SumargColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
