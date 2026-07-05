import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/job_application_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/job_model.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicationsListScreen extends StatelessWidget {
  final JobModel job;
  const JobApplicationsListScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Applicants for ${job.jobTitle}", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<List<JobApplicationModel>>(
        stream: DbService().getJobApplications(job.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
             return Center(child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
             ));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 60, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text("No applications received yet.", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          final apps = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Card(
                elevation: 1,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[50],
                    child: Text(app.applicantName[0].toUpperCase(), style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(app.applicantName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Applied: ${_formatDate(app.appliedDate)}"),
                      Text("Phone: ${app.applicantPhone}", style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.phone, color: Colors.green),
                    onPressed: () => _callApplicant(context, app.applicantPhone),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _callApplicant(BuildContext context, String phone) async {
    final url = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch dialer")));
    }
  }
}
