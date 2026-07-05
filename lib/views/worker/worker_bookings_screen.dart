import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/booking_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mykottakkal/views/chat_screen.dart';

class WorkerBookingsScreen extends StatelessWidget {
  const WorkerBookingsScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(body: Center(child: Text("Not Logged In")));
    }

    return Scaffold(
      // backgroundColor: Colors.grey[50], // Removed to allow theme background
      appBar: AppBar(
        title: Text("My Bookings", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: DbService().getBookingsForWorker(user.uid),
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
                Icon(Icons.event_note, size: 84, color: Colors.grey[300]),
                SizedBox(height: 16),
                Text("No bookings yet", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                Text("Your new opportunities will appear here.", style: TextStyle(color: Colors.grey[400])),
              ],
            ));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final dateStr = booking.bookingDate.toString().split(' ')[0];
              final isToday = DateTime.now().toString().split(' ')[0] == dateStr;

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isToday ? Colors.green[50] : Colors.blue[50], 
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: Column(
                              children: [
                                Text(
                                  dateStr.split('-')[2], // Day
                                  style: GoogleFonts.outfit(
                                    fontSize: 24, 
                                    fontWeight: FontWeight.bold,
                                    color: isToday ? Colors.green[800] : Colors.blue[800],
                                  )
                                ),
                                Text(
                                  isToday ? "Today" : "Date", 
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isToday ? Colors.green[800] : Colors.blue[800],
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(booking.userName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () async {
                                    if (booking.userLatitude != null && booking.userLongitude != null) {
                                      final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${booking.userLatitude},${booking.userLongitude}");
                                      if (await canLaunchUrl(googleMapsUrl)) {
                                        await launchUrl(googleMapsUrl);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not open maps")));
                                      }
                                    } else {
                                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location not provided by client")));
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on, size: 14, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text(
                                        (booking.userLatitude != null) ? "View Location on Map" : "Location Not Available",
                                        style: TextStyle(color: Colors.blue, fontSize: 13, decoration: TextDecoration.underline)
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(booking.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _getStatusColor(booking.status).withOpacity(0.2))
                                    ),
                                    child: Text(booking.status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusColor(booking.status))),
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.grey[100]),
                      ),
                      if (booking.status == 'Confirmed' || booking.status == 'On the Way' || booking.status == 'Working')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(bookingId: booking.id, otherUserName: booking.userName)));
                              },
                              icon: Icon(Icons.chat, size: 18),
                              label: Text("Chat with User"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Contact", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(booking.userPhone, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                            ],
                          ),
                          Row(
                            children: [
                              // Status Flow Buttons
                              if (booking.status == 'Pending')
                                ElevatedButton(
                                  onPressed: () => DbService().updateBookingStatus(booking.id, 'Confirmed'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: Text("Accept"),
                                ),
                              if (booking.status == 'Confirmed')
                                ElevatedButton(
                                  onPressed: () => DbService().updateBookingStatus(booking.id, 'On the Way'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                  child: Text("Start Trip"),
                                ),
                              if (booking.status == 'On the Way')
                                ElevatedButton(
                                  onPressed: () => DbService().updateBookingStatus(booking.id, 'Working'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                  child: Text("Start Work"),
                                ),
                              if (booking.status == 'Working')
                                ElevatedButton(
                                  onPressed: () => DbService().updateBookingStatus(booking.id, 'Completed'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                                  child: Text("Complete"),
                                ),

                              SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _makePhoneCall(booking.userPhone),
                                icon: Icon(Icons.call, size: 18),
                                label: Text("Call"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
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
