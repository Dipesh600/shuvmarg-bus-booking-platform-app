import 'package:sumarg/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sumarg/providers/feedback_provider.dart';
import 'package:sumarg/models/trip_data.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
class ReviewScreen extends StatefulWidget {
  final TripData trip;

  const ReviewScreen({super.key, required this.trip});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  double _rating = 0.0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }


  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);

    try {
      final response = await feedbackProvider.submitReview(
        bookingId: widget.trip.bookingId,
        rating: _rating.toInt(),
        comment: _reviewController.text.trim(),
      );
      
      if (mounted) {
        if (response.status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bus and route info
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.trip.from} to ${widget.trip.to}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bus: ${widget.trip.busNumber} • ${widget.trip.operatorName}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${widget.trip.date} • ${widget.trip.time}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Rating
              const Text(
                'How was your trip?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Review text
              const Text(
                'Share your experience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reviewController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Tell us about your experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please write your review';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Submit button
              Consumer<FeedbackProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _rating == 0 || provider.isSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: provider.isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit Review',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
