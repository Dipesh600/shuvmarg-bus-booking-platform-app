import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/feedback_provider.dart';
import 'package:sumarg/models/trip_data.dart';
import 'package:sumarg/utils/app_theme.dart';
import 'package:sumarg/utils/toast_service.dart';

class ReviewScreen extends StatefulWidget {
  final TripData trip;

  const ReviewScreen({super.key, required this.trip});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _rating = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final feedbackProvider =
        Provider.of<FeedbackProvider>(context, listen: false);

    try {
      final response = await feedbackProvider.submitReview(
        bookingId: widget.trip.bookingId,
        fleetId: widget.trip.fleetId,
        rating: _rating,
        comment: _reviewController.text.trim(),
      );

      if (mounted) {
        if (response.status) {
          HapticFeedback.mediumImpact();
          ToastService.showToast(msg: response.message);
          Navigator.pop(context, true);
        } else {
          ToastService.showToast(msg: response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.showToast(msg: e.toString());
      }
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Poor';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }

  String _getRatingEmoji(int rating) {
    switch (rating) {
      case 1:
        return '😞';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '⭐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              // ── Header ──
              _buildHeader(),

              // ── Body ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Trip Context Card
                        _buildTripCard(),
                        const SizedBox(height: 32),

                        // Rating Section
                        _buildRatingSection(),
                        const SizedBox(height: 32),

                        // Review Text Section
                        _buildReviewInput(),
                        const SizedBox(height: 40),

                        // Submit CTA
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Glass Header ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        border:
            Border(bottom: BorderSide(color: AppTheme.stroke, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Rate Your Trip',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Trip Context Card ─────────────────────────────────────────────────────
  Widget _buildTripCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.stroke, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDarkest.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Route
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.trip.from,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.trip.time,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppTheme.accentLime, size: 20),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLime.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.trip.date,
                            style: const TextStyle(
                              color: AppTheme.accentLime,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.trip.to,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bus info ribbon
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_bus_rounded,
                        color: AppTheme.textSecondary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.trip.operatorName} • ${widget.trip.busNumber}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  // ── Rating Section ────────────────────────────────────────────────────────
  Widget _buildRatingSection() {
    return Column(
      children: [
        // Emoji + Label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            _getRatingEmoji(_rating),
            key: ValueKey(_rating),
            style: const TextStyle(fontSize: 48),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            _getRatingLabel(_rating),
            key: ValueKey(_rating),
            style: TextStyle(
              color: _rating > 0
                  ? AppTheme.accentLime
                  : AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Star Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isSelected = starIndex <= _rating;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _rating = starIndex);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentLime.withOpacity(0.15)
                      : AppTheme.inputBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentLime.withOpacity(0.5)
                        : AppTheme.stroke,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.accentLime.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isSelected
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: isSelected
                      ? AppTheme.accentLime
                      : AppTheme.textSecondary.withOpacity(0.5),
                  size: 26,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Review Text Input ─────────────────────────────────────────────────────
  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share your experience',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your review helps other travelers make better decisions',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: _reviewController,
              maxLines: 5,
              maxLength: 500,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
              cursorColor: AppTheme.accentLime,
              decoration: InputDecoration(
                hintText: 'How was the bus condition, driver behavior, punctuality...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
                counterStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
                filled: true,
                fillColor: AppTheme.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: AppTheme.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppTheme.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                      color: AppTheme.accentLime.withOpacity(0.5),
                      width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please write your review';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit CTA ────────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return Consumer<FeedbackProvider>(
      builder: (context, provider, _) {
        final isEnabled = _rating > 0 && !provider.isSubmitting;
        return GestureDetector(
          onTap: isEnabled ? _submitReview : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppTheme.accentLime
                  : AppTheme.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: AppTheme.accentLime.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: provider.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryDark,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Submit Review',
                      style: TextStyle(
                        color: isEnabled
                            ? AppTheme.primaryDark
                            : AppTheme.textSecondary.withOpacity(0.5),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
