import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:mykottakkal/services/pdf_service.dart';
import 'package:mykottakkal/views/user/rate_worker_dialog.dart';
import 'package:mykottakkal/views/chat_screen.dart';

class UserBookingsScreen extends StatelessWidget {
  const UserBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(body: Center(child: Text("Not Logged In")));
    }

    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("My Bookings", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: DbService().getBookingsForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
           if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 84, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text("No bookings yet", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                Text("Book a worker to see them here.", style: TextStyle(color: Colors.grey[400])),
              ],
            ));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    final dateStr = DateFormat('MMM dd, yyyy').format(booking.bookingDate);
    final isCompleted = booking.status == 'Completed';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: Offset(0, 5))
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.workerName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(booking.serviceCategory, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(booking.status).withOpacity(0.2))
                  ),
                  child: Text(
                    booking.status, 
                    style: TextStyle(
                      color: _getStatusColor(booking.status), 
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    )
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.grey[100]),
            ),
             Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(dateStr, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
            SizedBox(height: 12),
            if (booking.status == 'Confirmed' || booking.status == 'On the Way' || booking.status == 'Working')
               Row(
                children: [
                   Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(bookingId: booking.id, otherUserName: booking.workerName)));
                      },
                      icon: Icon(Icons.chat, size: 18),
                      label: Text("Chat with Worker"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
               ),
            SizedBox(height: 8), 
            if (isCompleted)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!booking.isRated)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => RateWorkerDialog(booking: booking),
                          );
                        },
                        icon: Icon(Icons.star_rate, size: 18),
                        label: Text("Rate"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber[800],
                          side: BorderSide(color: Colors.amber[200]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: () {
                       PdfService().generateInvoice(booking);
                    },
                    icon: Icon(Icons.receipt_long, size: 18),
                    label: Text("Invoice"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      side: BorderSide(color: Colors.blue[200]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],  
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Confirmed': return Colors.blue;
      case 'On the Way': return Colors.purple;
      case 'Working': return Colors.amber[800]!;
      case 'Completed': return Colors.green;
      default: return Colors.grey;
    }
  }
}

