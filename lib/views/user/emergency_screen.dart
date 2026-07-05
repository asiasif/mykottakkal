import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/emergency_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: Text("Emergency Helpline", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<List<EmergencyModel>>(
        stream: DbService().getEmergencyContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No contacts found.", style: TextStyle(color: Colors.grey)));

          final contacts = snapshot.data!;
          // Group by Category? Or just simple list with icons.
          // Let's do a simple list with bold categorization colors.

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(contact.category).withOpacity(0.1),
                    child: Icon(_getCategoryIcon(contact.category), color: _getCategoryColor(contact.category)),
                  ),
                  title: Text(contact.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(contact.category, style: TextStyle(color: Colors.grey[600])),
                  trailing: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                    ),
                    onPressed: () => _callNumber(context, contact.phone),
                    icon: Icon(Icons.call),
                    label: Text("CALL")
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _callNumber(BuildContext context, String phone) async {
    final url = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch dialer")));
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Police': return Colors.blue[900]!;
      case 'Ambulance': return Colors.red;
      case 'Fire': return Colors.orange[900]!;
      case 'Hospital': return Colors.green;
      case 'Electricity': return Colors.yellow[800]!;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Police': return Icons.local_police;
      case 'Ambulance': return Icons.medical_services;
      case 'Fire': return Icons.local_fire_department;
      case 'Hospital': return Icons.local_hospital;
      case 'Electricity': return Icons.electric_bolt;
      default: return Icons.phone;
    }
  }
}
