import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:mykottakkal/services/auth_service.dart';
import 'package:mykottakkal/views/worker/worker_bookings_screen.dart';
import 'package:mykottakkal/views/login_screen.dart';
import 'package:mykottakkal/views/worker/worker_profile_screen.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/views/worker/worker_application_screen.dart';
import 'package:mykottakkal/views/worker/worker_id_card_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Scaffold(body: Center(child: Text("Please Login")));

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA), // Light grey/white background
      body: StreamBuilder<WorkerModel?>(
        stream: DbService().getWorker(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final worker = snapshot.data;

          // 1. Not Applied
          if (worker == null) {
            return _buildStatusPage(
              context,
              icon: Icons.assignment_ind,
              color: Colors.grey,
              title: "Complete Your Profile",
              message: "Get verified to start receiving jobs.",
              buttonText: "Apply Now",
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerApplicationScreen())),
            );
          }

          // 2. Pending
          if (worker.status == 'Pending') {
            return _buildStatusPage(
              context,
              icon: Icons.hourglass_top,
              color: Colors.orange,
              title: "Verification Pending",
              message: "Your application is under review by the Admin.\nThis usually takes 24 hours.",
            );
          }

          // 3. Rejected
          if (worker.status == 'Rejected') {
            return _buildStatusPage(
              context,
              icon: Icons.error_outline,
              color: Colors.red,
              title: "Application Rejected",
              message: "Please contact admin or try applying again.",
              buttonText: "Re-Apply",
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerApplicationScreen())),
            );
          }

          // 4. Approved - Dashboard
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: worker.profileImage != null ? NetworkImage(worker.profileImage!) : null,
                            child: worker.profileImage == null ? Icon(Icons.person, size: 30) : null,
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Welcome back,", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              Text(
                                worker.name.split(' ')[0],
                                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Online Toggle (Status Indicator)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: worker.isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 4, backgroundColor: worker.isAvailable ? Colors.green : Colors.red),
                            SizedBox(width: 8),
                            Text(
                              worker.isAvailable ? "Online" : "Offline",
                              style: TextStyle(color: worker.isAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Rating", "${worker.rating.toStringAsFixed(1)}", Icons.star, Colors.amber)),
                      SizedBox(width: 16),
                      Expanded(child: _buildStatCard("Reviews", "${worker.ratingCount}", Icons.rate_review, Colors.blue)),
                      SizedBox(width: 16),
                      Expanded(child: _buildStatCard("Jobs", "N/A", Icons.work, Colors.purple)), // Placeholder for total jobs
                    ],
                  ),
                  SizedBox(height: 32),

                  Text("Quick Actions", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  // Action Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        context,
                        title: "My Bookings",
                        icon: Icons.calendar_month,
                        color: Color(0xFF2E7D32),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerBookingsScreen())),
                      ),
                      _buildActionCard(
                        context,
                        title: "Profile",
                        icon: Icons.person,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerProfileScreen())),
                      ),
                      _buildActionCard(
                        context,
                        title: "ID Card",
                        icon: Icons.badge,
                        color: Colors.teal,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerIdCardScreen(worker: worker))),
                      ),
                       _buildActionCard(
                        context,
                        title: "Logout",
                        icon: Icons.logout,
                        color: Colors.redAccent,
                        onTap: () async {
                           await Provider.of<AuthService>(context, listen: false).signOut();
                           if (context.mounted) {
                             Navigator.pushAndRemoveUntil(
                               context, 
                               MaterialPageRoute(builder: (context) => LoginScreen(role: 'worker')), 
                               (route) => false
                             );
                           }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(height: 12),
            Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPage(BuildContext context, {required IconData icon, required Color color, required String title, required String message, String? buttonText, VoidCallback? onPressed}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            SizedBox(height: 24),
            Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], height: 1.5)),
            if (buttonText != null) ...[
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(buttonText),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
