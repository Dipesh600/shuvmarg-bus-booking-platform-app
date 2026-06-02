import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../utils/api_endpoints.dart';
import '../../apis/api_services.dart';
import '../../utils/app_theme.dart';
import 'wallet_pin_sheet.dart';
import 'wallet_faq_sheet.dart';
import 'scratch_card_widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isPinSet = false;
  double _balance = 0.0;
  List<dynamic> _transactions = [];
  List<dynamic> _scratchCards = [];
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 1;
  bool _hasMore = false;
  static const int _pageLimit = 10;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _fetchWalletDetails();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchWalletDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _transactions = [];
      _scratchCards = [];
      _hasMore = false;
    });

    try {
      final endpoint = '${ApiEndpoints.baseUrl}/api/wallet/details?page=1&limit=$_pageLimit';
      final scratchEndpoint = '${ApiEndpoints.baseUrl}/api/wallet/scratch-cards';

      final results = await Future.wait([
        ApiService().getDataWithToken(endpoint),
        ApiService().getDataWithToken(scratchEndpoint),
      ]);

      final data = results[0];
      final scratchData = results[1];

      if (data != null && data['status'] == true) {
        final pagination = data['data']['pagination'];
        if (!mounted) return;
        setState(() {
          _isPinSet = data['data']['isPinSet'] == true;
          _balance = (data['data']['balance'] as num).toDouble();
          _transactions = data['data']['activities'] ?? [];
          _hasMore = pagination != null ? (pagination['hasMore'] ?? false) : false;
          _scratchCards = (scratchData != null && scratchData['status'] == true) 
              ? (scratchData['data'] ?? []) 
              : [];
          _isLoading = false;
        });
        _animController.forward(from: 0.0);
      } else {
        throw Exception(data['message'] ?? 'Failed to retrieve wallet details');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        String errorText = e.toString();
        if (errorText.contains('Exception: Error in fetching data: DioException [unknown]: ')) {
          errorText = errorText.split('Exception: Error in fetching data: DioException [unknown]: ').last;
        } else {
          errorText = errorText.replaceAll('Exception: ', '');
        }
        _errorMessage = errorText;
        _isLoading = false;
      });
    }
  }

  Future<void> _scratchCard(String cardId) async {
    try {
      final endpoint = '${ApiEndpoints.baseUrl}/api/wallet/scratch/$cardId';
      final data = await ApiService().postDataWithToken(endpoint, {});
      if (data != null && data['status'] == true) {
        // Wait a moment for animation, then refresh balance quietly
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            ApiService().getDataWithToken('${ApiEndpoints.baseUrl}/api/wallet/details?page=1&limit=$_pageLimit').then((value) {
              if (value != null && value['status'] == true && mounted) {
                setState(() {
                  _balance = (value['data']['balance'] as num).toDouble();
                });
              }
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error scratching card: $e');
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final endpoint = '${ApiEndpoints.baseUrl}/api/wallet/details?page=$nextPage&limit=$_pageLimit';
      final data = await ApiService().getDataWithToken(endpoint);

      if (data != null && data['status'] == true) {
        final pagination = data['data']['pagination'];
        final newTransactions = data['data']['activities'] ?? [];
        if (!mounted) return;
        setState(() {
          _transactions = [..._transactions, ...newTransactions];
          _currentPage = nextPage;
          _hasMore = pagination != null ? (pagination['hasMore'] ?? false) : false;
          _isLoadingMore = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Brand design color palette:
    const primaryBg = Color(0xFF003D38);
    const cardBg = Color(0xFF00564E);
    const accentLime = Color(0xFFD3D925);
    const textPrimary = Color(0xFFF5F7F6);
    const textSecondary = Color(0xFFB7C7C3);

    return Scaffold(
      backgroundColor: primaryBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Satoshi', // Match AppTheme.fontFamily
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(
                text: 'Shuvmarg ',
                style: TextStyle(color: textPrimary),
              ),
              TextSpan(
                text: 'Money',
                style: TextStyle(color: accentLime),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: textPrimary),
            onPressed: () {
              WalletFaqSheet.show(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentLime),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: textPrimary, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchWalletDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentLime,
                            foregroundColor: primaryBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: RefreshIndicator(
                    onRefresh: _fetchWalletDetails,
                    color: accentLime,
                    backgroundColor: cardBg,
                    child: Builder(
                      builder: (context) {
                        // Compute real statistics from _transactions
                        double thisWeekRefunds = 0.0;
                        int transactionsThisMonth = 0;
                        final now = DateTime.now();
                        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
                        final startOfMonth = DateTime(now.year, now.month, 1);

                        for (var tx in _transactions) {
                          if (tx['createdAt'] == null) continue;
                          final txDate = DateTime.parse(tx['createdAt']).toLocal();
                          
                          if (txDate.isAfter(startOfMonth) || txDate.isAtSameMomentAs(startOfMonth)) {
                            transactionsThisMonth++;
                          }
                          
                          if ((txDate.isAfter(startOfWeek) || txDate.isAtSameMomentAs(startOfWeek)) && tx['type'] == 'credit') {
                            thisWeekRefunds += (tx['amount'] as num).toDouble();
                          }
                        }

                        // If the user hasn't set up their wallet PIN,
                        // force them through the setup flow — regardless of
                        // whether they already have a balance (legacy users).
                        if (!_isPinSet) {
                          return _buildEmptyState(context);
                        }

                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                            top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
                            bottom: 20.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // High-fidelity glowing Glassmorphic balance card
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: cardBg.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                              gradient: RadialGradient(
                                center: Alignment.topRight,
                                radius: 1.5,
                                colors: [
                                  accentLime.withOpacity(0.15),
                                  primaryBg,
                                ],
                              ),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/profile/wallet.png'),
                                fit: BoxFit.cover,
                                opacity: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cardBg.withOpacity(0.25),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'AVAILABLE BALANCE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 18),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        textBaseline: TextBaseline.alphabetic,
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        children: [
                                          const Text(
                                            'Rs. ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            NumberFormat('#,##,###.00').format(_balance),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 42,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 32),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(color: accentLime.withOpacity(0.15), shape: BoxShape.circle),
                                                  child: const Icon(Icons.bar_chart_rounded, color: accentLime, size: 18),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('This week', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
                                                      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('+ Rs. ${NumberFormat('#,##,###').format(thisWeekRefunds)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
                                                      const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('in refunds', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(color: accentLime.withOpacity(0.15), shape: BoxShape.circle),
                                                  child: const Icon(Icons.sync_rounded, color: accentLime, size: 18),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('Total transactions', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
                                                      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('$transactionsThisMonth', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
                                                      const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('this month', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
                                                    ],
                                                  ),
                                                ),
                                              ],
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
                          const SizedBox(height: 32),
                          if (_scratchCards.isNotEmpty) ...[
                            const Text(
                              'Cashback & Rewards',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _scratchCards.length,
                                itemBuilder: (context, index) {
                                  final card = _scratchCards[index];
                                  return ScratchCardWidget(
                                    cardId: card['_id'],
                                    amount: (card['amount'] as num).toDouble(),
                                    isScratched: card['status'] == 'SCRATCHED',
                                    onScratchComplete: () {
                                      _scratchCard(card['_id']);
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                          // Section title
                          const Text(
                            'Transaction History',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_transactions.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_rounded, color: textSecondary.withOpacity(0.3), size: 48),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No transactions yet.',
                                    style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )
                          else
                            _buildGroupedTransactions(),
                            
                          if (_hasMore) ...
                            [
                              const SizedBox(height: 16),
                              Center(
                                child: _isLoadingMore
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD3D925)),
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: _loadMoreTransactions,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text('View More Transactions', style: TextStyle(color: Color(0xFFD3D925), fontSize: 13, fontWeight: FontWeight.w600)),
                                            SizedBox(width: 6),
                                            Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFD3D925), size: 18),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildGroupedTransactions() {
    final Map<String, List<dynamic>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Brand Palette
    const cardBg = Color(0xFF00564E);
    const accentLime = Color(0xFFD3D925);
    const textPrimary = Color(0xFFF5F7F6);
    const textSecondary = Color(0xFFB7C7C3);
    const strokeColor = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

    for (var tx in _transactions) {
      if (tx['createdAt'] == null) continue;
      final txDateRaw = DateTime.parse(tx['createdAt']).toLocal();
      final txDate = DateTime(txDateRaw.year, txDateRaw.month, txDateRaw.day);

      String groupKey;
      if (txDate == today) {
        groupKey = "Today";
      } else if (txDate == yesterday) {
        groupKey = "Yesterday";
      } else {
        groupKey = DateFormat('MMMM d, yyyy').format(txDate);
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(tx);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final groupTitle = entry.key;
        final transactions = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Text(
                groupTitle,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...transactions.map((tx) {
              final isCredit = tx['direction'] == 'CREDIT' || tx['type'] == 'credit' || tx['type'] == 'CASHBACK' || tx['type'] == 'ADMIN_CREDIT' || tx['type'] == 'REFUND';
              
              // Map types for better icons/colors
              final txType = (tx['type'] ?? '').toString().toUpperCase();
              
              IconData txIcon;
              Color txIconColor;
              Color txIconBg;
              
              if (txType == 'CASHBACK') {
                txIcon = Icons.stars_rounded;
                txIconColor = accentLime;
                txIconBg = accentLime.withOpacity(0.15);
              } else if (txType == 'REFUND') {
                txIcon = Icons.refresh_rounded;
                txIconColor = const Color(0xFF10B981);
                txIconBg = const Color(0xFF10B981).withOpacity(0.15);
              } else if (txType == 'REFERRAL_UNLOCK') {
                txIcon = Icons.people_rounded;
                txIconColor = accentLime;
                txIconBg = accentLime.withOpacity(0.15);
              } else if (!isCredit) {
                txIcon = Icons.directions_bus_rounded;
                txIconColor = const Color(0xFFF87171); // Soft red
                txIconBg = const Color(0xFFF87171).withOpacity(0.15);
              } else {
                txIcon = Icons.account_balance_wallet_rounded;
                txIconColor = const Color(0xFF10B981);
                txIconBg = const Color(0xFF10B981).withOpacity(0.15);
              }

              final amount = (tx['amount'] as num).toDouble();
              final dateStr = tx['createdAt'] != null
                  ? DateFormat('h:mm a').format(DateTime.parse(tx['createdAt']).toLocal())
                  : '—';
              
              // Handle new note field from SM Ledger or fallback to remarks
              final note = tx['note'] ?? tx['remarks'] ?? '';
              
              // Title extraction logic based on type or note
              String displayTitle = 'Fund Credited';
              if (!isCredit) displayTitle = 'Fund Debited';
              if (txType == 'CASHBACK') displayTitle = 'Cashback Earned';
              if (txType == 'REFUND') displayTitle = 'Booking Refund';
              if (txType == 'REFERRAL_UNLOCK') displayTitle = 'Referral Reward';
              if (txType == 'DEBIT') displayTitle = 'Ticket Booking';
              if (txType == 'EXPIRY') displayTitle = 'Credits Expired';
              
              String txId = '';
              if (tx['_id'] != null) {
                txId = 'TRX-${tx['_id'].toString().substring(0, 8).toUpperCase()}';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardBg.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: strokeColor),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF003D38).withOpacity(0.25),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Soft floating icon
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: txIconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(txIcon, color: txIconColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          
                          // Transaction Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayTitle,
                                  style: const TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  note.isNotEmpty ? note : txId,
                                  style: TextStyle(
                                    color: textSecondary.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Amount and Time
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isCredit ? "+" : "-"} Rs. ${NumberFormat('#,##,###').format(amount)}',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  color: textSecondary.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    const primaryBg = Color(0xFF003D38);
    const accentLime = Color(0xFFD3D925);
    const textSecondary = Color(0xFFB7C7C3);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/wallet_nostate.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // Spacer to push content exactly below the baked-in wallet illustration and text
            SizedBox(height: MediaQuery.of(context).size.height * 0.58),
                
                // Features Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureItem(Icons.bolt_rounded, 'Instant\nRefunds', accentLime, textSecondary),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                    _buildFeatureItem(Icons.shield_rounded, '100% Secure\nTransactions', accentLime, textSecondary),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                    _buildFeatureItem(Icons.account_balance_wallet_rounded, 'Easy\nPayments', accentLime, textSecondary),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Enable Wallet Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await WalletPinSheet.show(context, mode: WalletPinMode.setup);
                      if (success == true) {
                        // Refresh the screen completely to show the active wallet state
                        _fetchWalletDetails();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentLime,
                      foregroundColor: primaryBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      _balance > 0
                          ? 'Secure Your Wallet'
                          : 'Enable Wallet',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color iconColor, Color textColor) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
