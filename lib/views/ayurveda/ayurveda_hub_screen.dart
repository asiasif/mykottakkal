import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/wellness_center_model.dart';
import 'package:mykottakkal/models/wellness_booking_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/ayurveda/herb_finder_screen.dart';
import 'package:mykottakkal/views/ayurveda/wellness_booking_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AyurvedaHubScreen extends StatelessWidget {
  const AyurvedaHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0), // Warm Cream
      appBar: AppBar(
        title: Text("Ayurveda Hub", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32), // Deep Herbal Green
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Herb Finder Banner Card
            _buildHerbFinderBanner(context),

            // Wellness Centers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                "Ayurvedic Centers & Clinics",
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF3E2723)),
              ),
            ),
            _buildWellnessCentersList(context),

            // Bookings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                "My Consultations",
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF3E2723)),
              ),
            ),
            if (user == null)
              _buildLoginPrompt(context)
            else
              _buildBookingsList(context, user.uid),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHerbFinderBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&q=80&w=600'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2E7D32).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HerbFinderScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.spa, color: Color(0xFFD4AF37), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      "Digital Herb Finder",
                      style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Identify and explore traditional Malayalam medicinal herbs & their benefits.",
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWellnessCentersList(BuildContext context) {
    return SizedBox(
      height: 280,
      child: StreamBuilder<List<WellnessCenterModel>>(
        stream: DbService().getWellnessCenters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No clinics found.", style: GoogleFonts.outfit(color: Colors.grey)),
            );
          }

          final centers = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: centers.length,
            itemBuilder: (context, index) {
              final center = centers[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(center.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              center.name,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF3E2723)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  center.rating.toString(),
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 14),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    center.address.split(',')[0],
                                    style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _openMaps(context, center.googleMapLink),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2E7D32),
                                      side: const BorderSide(color: Color(0xFF2E7D32)),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text("Maps", style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => WellnessBookingScreen(
                                            centerId: center.id,
                                            centerName: center.name,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text("Book", style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, String uid) {
    return StreamBuilder<List<WellnessBookingModel>>(
      stream: DbService().getWellnessBookingsForUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month, color: Colors.grey[400], size: 24),
                const SizedBox(width: 12),
                Text(
                  "No consultations booked yet.",
                  style: GoogleFonts.outfit(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final bookings = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final Color statusColor = booking.status == 'Approved'
                ? Colors.green
                : (booking.status == 'Cancelled' ? Colors.red : Colors.orange);

            return Card(
              color: Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          booking.centerName,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF3E2723)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking.status.toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(booking.date, style: TextStyle(color: Colors.grey[800])),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(booking.time, style: TextStyle(color: Colors.grey[800])),
                      ],
                    ),
                    if (booking.message.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Concern: ${booking.message}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (booking.status == 'Pending') ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _confirmCancel(context, booking.id),
                          icon: const Icon(Icons.cancel, size: 16, color: Colors.red),
                          label: const Text("Cancel Booking", style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            "Log in to view and track your consultation requests.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _openMaps(BuildContext context, String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch maps")));
    }
  }

  void _confirmCancel(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cancel Booking", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to cancel this consultation booking request?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await DbService().cancelWellnessBooking(bookingId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Booking cancelled successfully")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error cancelling: $e")),
                  );
                }
              },
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
