import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/issue_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Import

class AdminIssuesScreen extends StatefulWidget {
  const AdminIssuesScreen({super.key});

  @override
  State<AdminIssuesScreen> createState() => _AdminIssuesScreenState();
}

class _AdminIssuesScreenState extends State<AdminIssuesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Civic Issues", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<IssueModel>>(
        stream: DbService().getAllIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No issues reported yet."));
          }

          final issues = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(issue.category, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            DateFormat('MMM d, hh:mm a').format(issue.timestamp),
                            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        issue.description,
                        style: GoogleFonts.outfit(color: Colors.grey[800]),
                      ),
                      
                      // New: Image & Location
                      if (issue.imageUrl != null || issue.latitude != null)
                      Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Row(
                              children: [
                                  if (issue.imageUrl != null)
                                    Padding(
                                        padding: EdgeInsets.only(right: 12),
                                        child: InkWell(
                                            onTap: () => showDialog(
                                                context: context,
                                                builder: (_) => Dialog(child: Image.network(issue.imageUrl!))
                                            ),
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(issue.imageUrl!, width: 60, height: 60, fit: BoxFit.cover),
                                            ),
                                        ),
                                    ),
                                    
                                  if (issue.latitude != null && issue.longitude != null)
                                    ElevatedButton.icon(
                                        onPressed: () async {
                                            final url = "https://www.google.com/maps/search/?api=1&query=${issue.latitude},${issue.longitude}";
                                            if (await canLaunchUrl(Uri.parse(url))) {
                                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                            }
                                        },
                                        icon: Icon(Icons.map, size: 16),
                                        label: Text("View on Map"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue[50],
                                            foregroundColor: Colors.blue,
                                            elevation: 0
                                        ),
                                    )
                              ],
                          ),
                      ),

                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300)
                                ),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                        value: issue.status,
                                        items: ['Pending', 'In Progress', 'Resolved'].map((String status) {
                                            return DropdownMenuItem<String>(
                                                value: status,
                                                child: Text(
                                                    status, 
                                                    style: TextStyle(
                                                        color: _getStatusColor(status), 
                                                        fontWeight: FontWeight.bold
                                                    )
                                                ),
                                            );
                                        }).toList(),
                                        onChanged: (newStatus) {
                                            if (newStatus != null && newStatus != issue.status) {
                                                _updateStatus(issue, newStatus);
                                            }
                                        },
                                    ),
                                ),
                            ),
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

  Future<void> _updateStatus(IssueModel issue, String newStatus) async {
    bool confirm = true;
    if (newStatus == 'Resolved') {
        confirm = await showDialog(
            context: context, 
            builder: (context) => AlertDialog(
                title: Text("Mark as Resolved?"),
                content: Text("This will award 10 Green Points to the user. Proceed?"),
                actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Confirm")),
                ],
            )
        ) ?? false;
    }

    if (confirm) {
        await DbService().updateIssueStatus(issue.id, newStatus, issue.userId);
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(newStatus == 'Resolved' ? "Status updated & Points awarded!" : "Status updated"),
                backgroundColor: Colors.green,
            ));
        }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Resolved': return Colors.green;
      default: return Colors.grey;
    }
  }
}
