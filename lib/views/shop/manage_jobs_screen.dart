import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/models/job_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/shop/job_applications_list_screen.dart';
import 'package:uuid/uuid.dart';

class ShopManageJobsScreen extends StatefulWidget {
  final String shopId;
  final String shopName;

  const ShopManageJobsScreen({super.key, required this.shopId, required this.shopName});

  @override
  State<ShopManageJobsScreen> createState() => _ShopManageJobsScreenState();
}

class _ShopManageJobsScreenState extends State<ShopManageJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Manage Recruitment", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<JobModel>>(
        stream: DbService().getJobs(), // We will filter locally or update DbService to support filtering
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          
          final allJobs = snapshot.data ?? [];
          // Filter for this shop
          final myJobs = allJobs.where((job) => job.recruiterId == widget.shopId).toList();

          if (myJobs.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.work_outline, size: 60, color: Colors.grey[300]),
                   SizedBox(height: 16),
                   Text("No active job postings.", style: TextStyle(color: Colors.grey[500])),
                   SizedBox(height: 24),
                   ElevatedButton(
                     onPressed: _showPostJobDialog,
                     child: Text("Post First Job"),
                   )
                 ],
               ),
             );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: myJobs.length,
            itemBuilder: (context, index) {
              final job = myJobs[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job.jobTitle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("Posted: ${_formatDate(job.postedDate)}", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red[300]),
                            onPressed: () => _deleteJob(job.id),
                          )
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.monetization_on, size: 16, color: Colors.green),
                              SizedBox(width: 4),
                              Text(job.salaryRange, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobApplicationsListScreen(job: job))),
                            child: Text("View Applicants"),
                          )
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(job.description, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPostJobDialog,
        backgroundColor: Colors.purple,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Post Vacancy"),
      ),
    );
  }

  String _formatDate(DateTime date) {
      return "${date.day}/${date.month}/${date.year}";
  }

  void _deleteJob(String id) async {
    bool confirm = await showDialog(
        context: context, 
        builder: (_) => AlertDialog(
            title: Text("Close Vacancy?"),
            content: Text("This will remove the job from the public list."),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Close"))
            ],
        )
    ) ?? false;
    
    if (confirm) {
        await DbService().deleteJob(id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Job Closed")));
    }
  }

  void _showPostJobDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final salaryController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Post Vacancy"),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    TextField(controller: titleController, decoration: InputDecoration(labelText: "Job Title (e.g. Sales Staff)")),
                    TextField(controller: descController, decoration: InputDecoration(labelText: "Description"), maxLines: 2),
                    TextField(controller: salaryController, decoration: InputDecoration(labelText: "Salary Range (e.g. 12k - 15k)")),
                    TextField(controller: phoneController, decoration: InputDecoration(labelText: "Contact Phone"), keyboardType: TextInputType.phone),
                ],
            )
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
                if (titleController.text.isEmpty || phoneController.text.isEmpty) return;

                final job = JobModel(
                    id: Uuid().v4(),
                    recruiterId: widget.shopId,
                    recruiterName: widget.shopName,
                    jobTitle: titleController.text,
                    category: 'Shop',
                    description: descController.text,
                    salaryRange: salaryController.text,
                    contactPhone: phoneController.text,
                    postedDate: DateTime.now()
                );

                await DbService().postJob(job);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vacancy Posted!")));
            },
            child: Text("Post"),
          )
        ],
      ),
    );
  }
}
