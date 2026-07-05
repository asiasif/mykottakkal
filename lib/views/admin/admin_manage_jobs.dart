import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/job_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';

class AdminManageJobsScreen extends StatefulWidget {
  const AdminManageJobsScreen({super.key});

  @override
  State<AdminManageJobsScreen> createState() => _AdminManageJobsScreenState();
}

class _AdminManageJobsScreenState extends State<AdminManageJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Job Portal Management", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<JobModel>>(
        stream: DbService().getJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No active jobs.", style: GoogleFonts.outfit(color: Colors.grey)));

          final jobs = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job.jobTitle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Row(
                                    children: [
                                        Icon(Icons.business, size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(job.recruiterName, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                                        SizedBox(width: 12),
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                                            child: Text(job.category, style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                                        )
                                    ]
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red[300]),
                            onPressed: () => _deleteJob(job.id),
                          )
                        ],
                      ),
                      SizedBox(height: 12),
                      Text("Salary: ${job.salaryRange}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                      SizedBox(height: 8),
                      Text(job.description, style: TextStyle(color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
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
        backgroundColor: Colors.black,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Post Daily Wage Job", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _deleteJob(String id) async {
    bool confirm = await showDialog(
        context: context, 
        builder: (_) => AlertDialog(
            title: Text("Delete Job?"),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete"))
            ],
        )
    ) ?? false;
    
    if (confirm) {
        await DbService().deleteJob(id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Job Deleted")));
    }
  }

  void _showPostJobDialog() {
    final titleController = TextEditingController();
    final loadingController = TextEditingController();
    final descController = TextEditingController();
    final salaryController = TextEditingController();
    final phoneController = TextEditingController();
    String category = 'Daily Wage';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Post Daily Wage Job"),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    TextField(controller: titleController, decoration: InputDecoration(labelText: "Job Title (e.g. Painter)")),
                    TextField(controller: descController, decoration: InputDecoration(labelText: "Description"), maxLines: 2),
                    TextField(controller: salaryController, decoration: InputDecoration(labelText: "Salary / Wage")),
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
                    recruiterId: null, // Admin
                    recruiterName: "Direct Requirement", // Or "Admin"
                    jobTitle: titleController.text,
                    category: category,
                    description: descController.text,
                    salaryRange: salaryController.text,
                    contactPhone: phoneController.text,
                    postedDate: DateTime.now()
                );

                await DbService().postJob(job);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Job Posted!")));
            },
            child: Text("Post"),
          )
        ],
      ),
    );
  }
}
