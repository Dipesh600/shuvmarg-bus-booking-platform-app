import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sumarg/controllers/referal_controller/referal_controller.dart';
import 'package:sumarg/models/referal_history_response.dart';
import 'package:intl/intl.dart';

// Sumarg Design Tokens as per the rulebook
class SumargColors {
  static const Color primary = Color(0xFF00564E);
  static const Color primaryDark = Color(0xFF003D38);
  static const Color secondary = Color(0xFF568C82);
  static const Color accentLime = Color(0xFFD3D925);
  static const Color textPrimary = Color(0xFFF5F7F6);
  static const Color textSecondary = Color(0xFFB7C7C3);
  static const Color stroke = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
}

/// Referral History Screen — V2 (Progressive Unlock)
/// Sumarg Visual Language: Dark UI + Floating Cards + Soft Blur + Neon Accent
class ReferalHistoryScreen extends StatefulWidget {
  const ReferalHistoryScreen({super.key});

  @override
  State<ReferalHistoryScreen> createState() => _ReferalHistoryScreenState();
}

class _ReferalHistoryScreenState extends State<ReferalHistoryScreen> {
  final ReferalController _controller = ReferalController();
  bool _loading = true;
  String? _error;
  List<ReferalHistoryEntry> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _controller.getReferalHistory();
      if (!mounted) return;
      if (res.status) {
        setState(() {
          _items = res.data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = res.message.isNotEmpty ? res.message : 'Failed to load data';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load data';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SumargColors.primaryDark,
      appBar: AppBar(
        title: const Text(
          'Referral History',
          style: TextStyle(
            color: SumargColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: SumargColors.textPrimary),
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    SumargColors.primary.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: RefreshIndicator(
              color: SumargColors.primaryDark,
              backgroundColor: SumargColors.accentLime,
              onRefresh: _fetch,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: SumargColors.accentLime));
    }
    if (_error != null) {
      return _buildErrorState();
    }
    if (_items.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 64),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (_, i) => _buildCard(_items[i]),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: SumargColors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: SumargColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetch,
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
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 86, 78, 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: SumargColors.stroke),
            ),
            child: Column(
              children: [
                Icon(Icons.history,
                    size: 48, color: SumargColors.secondary.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  'No history yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: SumargColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your referral earnings timeline will appear here.',
                  style: TextStyle(fontSize: 14, color: SumargColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ReferalHistoryEntry item) {
    final isFullyUnlocked = item.status == 'FULLY_UNLOCKED';
    final dateFormatter = DateFormat('MMM d, yyyy');

    return Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Name, Joined Date, Status Badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.04),
                      child: Text(
                        item.referredUser.name.isNotEmpty
                            ? item.referredUser.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: SumargColors.accentLime,
                          fontWeight: FontWeight.w700,
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
                            item.referredUser.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: SumargColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Joined ${dateFormatter.format(item.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SumargColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isFullyUnlocked 
                            ? SumargColors.accentLime.withOpacity(0.1)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isFullyUnlocked ? 'Complete' : 'Active',
                        style: TextStyle(
                          color: isFullyUnlocked 
                              ? SumargColors.accentLime
                              : SumargColors.textPrimary.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Journey Progress',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: SumargColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${item.journeysCompleted}/5 Trips',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: SumargColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.04),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      SumargColors.accentLime,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Financials
                Row(
                  children: [
                    Expanded(
                      child: _metricTile(
                        Icons.account_balance_wallet_rounded,
                        'Earned',
                        'Rs. ${item.totalUnlocked.toInt()}',
                        SumargColors.accentLime,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _metricTile(
                        Icons.lock_outline_rounded,
                        'Locked',
                        'Rs. ${item.lockedRemaining.toInt()}',
                        SumargColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Timeline of Unlocks
                if (item.unlockHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(height: 1, color: SumargColors.stroke),
                  const SizedBox(height: 20),
                  const Text(
                    'Unlock Timeline',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: SumargColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...item.unlockHistory.map((historyItem) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: SumargColors.accentLime.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                size: 12, color: SumargColors.accentLime),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trip ${historyItem.journeyNumber} Completed',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: SumargColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFormatter.format(historyItem.unlockedAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: SumargColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '+ Rs. ${historyItem.amountUnlocked.toInt()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: SumargColors.accentLime,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricTile(IconData icon, String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SumargColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: valueColor.withOpacity(0.8), size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: SumargColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}