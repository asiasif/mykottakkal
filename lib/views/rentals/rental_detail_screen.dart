import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/rental_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class RentalDetailScreen extends StatelessWidget {
  final RentalModel rental;
  const RentalDetailScreen({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(rental.imageUrl, fit: BoxFit.cover, errorBuilder: (c,o,s) => Container(color: Colors.grey, child: Icon(Icons.broken_image))),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(6)),
                            child: Text(rental.category, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[800])),
                          ),
                          Text("₹${rental.price.toStringAsFixed(0)}", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800])),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(rental.title, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(rental.location, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text("Description", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(rental.description, style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5)),
                      SizedBox(height: 24),
                      Divider(),
                      SizedBox(height: 16),
                      Text("Posted on ${DateFormat('dd MMM yyyy').format(rental.date)}", style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _callOwner(context, rental.contactPhone),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                icon: Icon(Icons.call),
                label: Text("Contact Owner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _callOwner(BuildContext context, String phone) async {
    final url = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch dialer")));
    }
  }
}
