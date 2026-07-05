import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/booking_model.dart';
import 'package:mykottakkal/models/review_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';

class RateWorkerDialog extends StatefulWidget {
  final BookingModel booking;
  const RateWorkerDialog({super.key, required this.booking});

  @override
  State<RateWorkerDialog> createState() => _RateWorkerDialogState();
}

class _RateWorkerDialogState extends State<RateWorkerDialog> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rate ${widget.booking.workerName}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("How was the service?", style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Write a review (optional)...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _rating == 0 || _isLoading ? null : _submitReview,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: _isLoading ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text("Submit"),
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isLoading = true);
    try {
      final review = ReviewModel(
        id: Uuid().v4(),
        workerId: widget.booking.workerId,
        userId: widget.booking.userId,
        userName: widget.booking.userName,
        rating: _rating,
        comment: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );

      await DbService().submitReview(review, widget.booking.id);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Review submitted!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
