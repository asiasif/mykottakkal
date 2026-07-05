import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/models/issue_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:intl/intl.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("My Reports", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<IssueModel>>(
        stream: DbService().getUserIssues(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text("No reports found", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }

          final issues = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return Card(
                elevation: 2,
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
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(issue.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getStatusColor(issue.status)),
                            ),
                            child: Text(
                              issue.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(issue.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, y').format(issue.timestamp),
                            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(_getCategoryIcon(issue.category), size: 20, color: Colors.grey[700]),
                          SizedBox(width: 8),
                          Text(issue.category, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        issue.description,
                        style: GoogleFonts.outfit(color: Colors.grey[800]),
                      ),
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
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
     switch (category) {
      case 'Waste': return Icons.delete_outline;
      case 'Road': return Icons.add_road;
      case 'Street Light': return Icons.lightbulb_outline;
      case 'Water Leak': return Icons.water_drop_outlined;
      default: return Icons.report_problem_outlined;
    }
  }
}
