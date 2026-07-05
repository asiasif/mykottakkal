import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/ad_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AdDetailScreen extends StatelessWidget {
  final AdModel ad;
  const AdDetailScreen({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(ad.imageUrl, fit: BoxFit.cover),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(ad.title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold))),
                        Text("₹ ${ad.price.toInt()}", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800])),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(ad.sellerName, style: TextStyle(color: Colors.grey[700])),
                        Spacer(),
                        Text(_formatDate(ad.postedDate), style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Divider(height: 32),
                    Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    Text(ad.description, style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800])),
                    SizedBox(height: 100), // Space for FAB
                  ]),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () => _callSeller(context),
              icon: Icon(Icons.call),
              label: Text("Call Seller"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  void _callSeller(BuildContext context) async {
    final url = "tel:${ad.contactPhone}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch dialer")));
    }
  }
}
