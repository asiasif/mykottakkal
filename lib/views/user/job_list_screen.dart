import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/job_model.dart';
import 'package:mykottakkal/models/job_application_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  String _filter = 'All'; // All, Shop, Daily Wage
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Modern light bg
      appBar: AppBar(
        title: Text("Local Jobs", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search jobs (e.g. Sales, Driver)...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Filter Chips
            Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                    children: [
                        _buildFilterChip('All'),
                        SizedBox(width: 8),
                        _buildFilterChip('Shop'),
                        SizedBox(width: 8),
                        _buildFilterChip('Daily Wage'),
                    ],
                ),
            ),
            
            // Job List
            Expanded(
                child: StreamBuilder<List<JobModel>>(
                    stream: DbService().getJobs(),
                    builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No jobs available right now.", style: GoogleFonts.outfit(color: Colors.grey)));

                        var jobs = snapshot.data!;
                        if (_filter != 'All') {
                            if (_filter == 'Shop') {
                                jobs = jobs.where((j) => j.category == 'Shop').toList();
                            } else {
                                jobs = jobs.where((j) => j.category != 'Shop').toList();
                            }
                        }

                        if (_searchQuery.isNotEmpty) {
                            jobs = jobs.where((j) => 
                                j.jobTitle.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                j.description.toLowerCase().contains(_searchQuery.toLowerCase())
                            ).toList();
                        }

                        return ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: jobs.length,
                            itemBuilder: (context, index) {
                                final job = jobs[index];
                                return _buildJobCard(job);
                            },
                        );
                    },
                ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
      final isSelected = _filter == label;
      return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (bool selected) {
              setState(() => _filter = label);
          },
          backgroundColor: Colors.grey[100],
          selectedColor: Colors.black,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.transparent)),
      );
  }

  Widget _buildJobCard(JobModel job) {
      final isShop = job.category == 'Shop';
      return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))],
              border: Border.all(color: Colors.grey.shade100),
          ),
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
                                      Text(job.recruiterName, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                  ],
                              ),
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: isShop ? Colors.purple[50] : Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Text(
                                  isShop ? "Shop" : "Daily Wage", 
                                  style: TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold,
                                      color: isShop ? Colors.purple : Colors.orange
                                  )
                              ),
                          )
                      ],
                  ),
                  SizedBox(height: 16),
                  Row(
                      children: [
                          Icon(Icons.monetization_on_outlined, size: 18, color: Colors.green),
                          SizedBox(width: 8),
                          Text(job.salaryRange, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 15)),
                      ],
                  ),
                  SizedBox(height: 8),
                  Text(job.description, style: TextStyle(color: Colors.grey[700], height: 1.4)),
                  SizedBox(height: 20),
                  Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                              onPressed: () => _callRecruiter(job.contactPhone),
                              icon: Icon(Icons.call, size: 18),
                              label: Text("Call"),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.black),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                              onPressed: () => _applyForJob(job),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                              child: Text("Apply Now"),
                          ),
                        ),
                      ],
                  )
              ],
          ),
      );
  }

  void _applyForJob(JobModel job) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please login to apply")));
          return;
      }

      // Show simple confirmation dialog
      final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
              title: Text("Apply for ${job.jobTitle}?"),
              content: Text("The recruiter will receive your profile details (Name & Phone)."),
              actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true), 
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: Text("Send Application")
                  )
              ],
          )
      );

      if (confirm == true) {
          try {
              // Fetch user details for the application
              // Ideally we fetch from DbService, but if displayName/phone is in Auth use that.
              // Assuming user has a profile or at least Auth info.
              // For robustness, let's fetch profile or fallback to Auth default.
              final profile = await DbService().getUser(user.uid).first;
              // If profile is strictly required, handle that. 
              // Fallback to "User" if profile fetch fails or is null.
              String name = profile?.name ?? user.displayName ?? "Applicant";
              String phone = profile?.phone ?? user.phoneNumber ?? "No Phone";

              final application = JobApplicationModel(
                  id: Uuid().v4(),
                  jobId: job.id,
                  jobTitle: job.jobTitle,
                  applicantId: user.uid,
                  applicantName: name,
                  applicantPhone: phone,
                  status: 'Pending',
                  appliedDate: DateTime.now(),
              );

              await DbService().applyForJob(application);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Application Sent Successfully!")));
          } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))));
          }
      }
  }


  void _callRecruiter(String phone) async {
      final url = "tel:$phone";
      if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
      } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch dialer")));
      }
  }
}
