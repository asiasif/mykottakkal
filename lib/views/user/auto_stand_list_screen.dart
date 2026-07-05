import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/auto_stand_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UserAutoStandListScreen extends StatelessWidget {
  const UserAutoStandListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Auto Taxi Stands", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<AutoStandModel>>(
        stream: DbService().getAutoStands(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No stands found.", style: GoogleFonts.outfit(color: Colors.grey)));

          final stands = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: stands.length,
            itemBuilder: (context, index) {
              final stand = stands[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                    border: Border.all(color: Colors.grey.shade100),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.amber[50], shape: BoxShape.circle),
                      child: Icon(Icons.local_taxi, color: Colors.amber[800]),
                  ),
                  title: Text(stand.standName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          SizedBox(height: 4),
                          Row(children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(stand.location, style: TextStyle(color: Colors.grey[600]))
                          ]),
                      ],
                  ),
                  trailing: ElevatedButton.icon(
                      onPressed: () => _callDriver(context, stand.driverPhone),
                      icon: Icon(Icons.call, size: 16),
                      label: Text("Call"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                      ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _callDriver(BuildContext context, String phone) async {
      final url = "tel:$phone";
      if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
      } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch dialer")));
      }
  }
}
