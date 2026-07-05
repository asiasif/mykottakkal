import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/event_booking_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminEventBookingsScreen extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const AdminEventBookingsScreen({super.key, required this.eventId, required this.eventTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bookings: $eventTitle")),
      body: StreamBuilder<List<EventBookingModel>>(
        stream: DbService().getEventBookings(eventId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!;
          
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.event_busy, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No bookings yet.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          return Column(
            children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                        Text("Total Registrations: ", style: TextStyle(fontSize: 16)),
                        Text("${bookings.length}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: bookings.length,
                    separatorBuilder: (_,__) => Divider(),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Colors.purple[50],
                            child: Text("${index + 1}", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(booking.userName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        subtitle: Text("Registered: ${DateFormat('MMM d, hh:mm a').format(booking.timestamp)}"),
                        trailing: IconButton(
                            icon: Icon(Icons.phone, color: Colors.green),
                            onPressed: () => launchUrl(Uri.parse("tel:${booking.userPhone}")),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
