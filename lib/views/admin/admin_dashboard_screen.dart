import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/services/auth_service.dart';
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/models/user_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/admin/admin_add_worker_screen.dart';
import 'package:mykottakkal/models/booking_model.dart';
import 'package:mykottakkal/views/login_screen.dart';
import 'package:mykottakkal/models/shop_model.dart';
import 'package:mykottakkal/views/admin/worker_verification_detail_screen.dart';
import 'package:mykottakkal/views/admin/shop_verification_detail_screen.dart';
import 'package:mykottakkal/views/admin/admin_add_event_screen.dart'; // Import
import 'package:mykottakkal/views/admin/admin_stats_chart.dart';
import 'package:mykottakkal/views/admin/widgets/admin_summary_card.dart';
import 'package:mykottakkal/views/admin/admin_issues_screen.dart'; 
import 'package:mykottakkal/views/admin/admin_manage_stands.dart'; // Import // Import
import 'package:mykottakkal/views/admin/admin_manage_jobs.dart'; // Import
import 'package:mykottakkal/views/admin/admin_manage_ads.dart'; // Import Classifieds
import 'package:mykottakkal/views/admin/admin_manage_bus.dart'; // Import Bus
import 'package:mykottakkal/views/admin/admin_manage_tourism.dart'; // Import Tourism
import 'package:mykottakkal/views/admin/admin_manage_emergency.dart'; // Import Emergency

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = ["Dashboard", "Workers", "Users", "Bookings", "Shops", "Issues", "Jobs", "Market"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Post Event",
            icon: Icon(Icons.campaign, color: Colors.blue),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAddEventScreen())),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen(role: 'admin')), (route) => false);
              }
            },
          )
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dash"),
          BottomNavigationBarItem(icon: Icon(Icons.engineering), label: "Workers"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shops"),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: "Issues"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Market"),
        ],
      ),
      floatingActionButton: _currentIndex == 1 // Only show FAB on Workers tab
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAddWorkerScreen()));
              },
              backgroundColor: Color(0xFF2E7D32),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildWorkerVerificationList();
      case 2:
        return _buildUserManagementList();
      case 3:
        return _buildBookingManagementList();
      case 4:
        return _buildShopManagementList();
      case 5:
        return AdminIssuesScreen();
      case 6:
        return AdminManageJobsScreen(); // Import
      case 7:
        return AdminManageAdsScreen();
      default:
        return Center(child: Text("Unknown Tab"));
    }
  }

  // 1. Overview Tab
  // 1. Overview Tab
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Admin Console", style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text("Dashboard Overview", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Stats Section
          Text("Live Statistics", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          SizedBox(height: 16),
          
          StreamBuilder(
            stream: DbService().getAllUsers(),
            builder: (context, userSnap) {
              final userCount = userSnap.data?.length ?? 0;
              return StreamBuilder(
                stream: DbService().getAllWorkers(),
                builder: (context, workerSnap) {
                  final workerCount = workerSnap.data?.length ?? 0;
                   return StreamBuilder(
                    stream: DbService().getApprovedShops(),
                    builder: (context, shopSnap) {
                      final shopCount = shopSnap.data?.length ?? 0;
                      return StreamBuilder(
                        stream: DbService().getAllBookings(),
                        builder: (context, bookingSnap) {
                          final bookingCount = bookingSnap.data?.length ?? 0;
                          final bookings = bookingSnap.data ?? [];

                          return Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.3, // Decreased from 1.5 to fix overflow
                                children: [
                                  AdminSummaryCard(title: "Users", value: "$userCount", icon: Icons.people, color: Colors.blue),
                                  AdminSummaryCard(title: "Workers", value: "$workerCount", icon: Icons.engineering, color: Colors.orange),
                                  AdminSummaryCard(title: "Shops", value: "$shopCount", icon: Icons.store, color: Colors.purple),
                                  AdminSummaryCard(title: "Bookings", value: "$bookingCount", icon: Icons.calendar_today, color: Colors.green),
                                ],
                              ),
                              
                              SizedBox(height: 32),

                              // Management Tools Section
                              Text("Feature Management", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                              SizedBox(height: 16),
                              
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 2.5, // Wider buttons
                                children: [
                                  _buildManageButton("Auto Stands", Icons.local_taxi, Colors.amber[800]!, () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminManageStandsScreen()))),
                                  _buildManageButton("Bus Timings", Icons.directions_bus, Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminManageBusScreen()))),
                                  _buildManageButton("Tourism", Icons.camera_alt, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminManageTourismScreen()))),
                                  _buildManageButton("Helpline", Icons.emergency, Colors.red[800]!, () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminManageEmergencyScreen()))),
                                ],
                              ),

                              SizedBox(height: 32),

                              Text("Booking Analytics", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                              SizedBox(height: 16),
                              if (bookings.isNotEmpty) AdminStatsChart(bookings: bookings),
                              if (bookings.isEmpty) 
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                  child: Center(child: Text("No booking data yet", style: TextStyle(color: Colors.grey))),
                                ),
                              SizedBox(height: 40),
                            ],
                          );
                        }
                      );
                    }
                  );
                }
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildManageButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.2))),
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Flexible(child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  // 2. Workers List
  Widget _buildWorkerVerificationList() {
    return StreamBuilder<List<WorkerModel>>(
      stream: DbService().getAllWorkers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState("No workers found.");

        final workers = snapshot.data!;
        // Sort: Pending first
        workers.sort((a, b) {
           if (a.status == 'Pending' && b.status != 'Pending') return -1;
           if (a.status != 'Pending' && b.status == 'Pending') return 1;
           return 0;
        });

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: workers.length,
          itemBuilder: (context, index) {
            final worker = workers[index];
            final isPending = worker.status == 'Pending';
            
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                border: isPending ? Border.all(color: Colors.orange.withOpacity(0.5)) : null,
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: worker.profileImage != null ? NetworkImage(worker.profileImage!) : null,
                  child: worker.profileImage == null ? Text(worker.name.isNotEmpty ? worker.name[0] : '?', style: TextStyle(fontWeight: FontWeight.bold)) : null,
                ),
                title: Text(worker.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.category, style: TextStyle(color: Colors.grey[600])),
                    if (isPending) 
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(4)),
                        child: Text("Action Required", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                  ],
                ),
                trailing: isPending
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 12)),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerVerificationDetailScreen(worker: worker))),
                        child: Text("Verify"),
                      )
                    : IconButton(icon: Icon(Icons.delete_outline, color: Colors.red[300]), onPressed: () => _confirmDelete(context, worker.uid, worker.name, 'worker')),
                onTap: isPending ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerVerificationDetailScreen(worker: worker))) : null,
              ),
            );
          },
        );
      },
    );
  }

  // 3. Users List
  Widget _buildUserManagementList() {
    return StreamBuilder<List<UserModel>>(
      stream: DbService().getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState("No users found.");

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          separatorBuilder: (c, i) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = snapshot.data![index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(user.name ?? "Unknown", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                subtitle: Text(user.phone),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                  onPressed: () => _confirmDelete(context, user.uid, user.name ?? "User", 'user'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 4. Bookings List
  Widget _buildBookingManagementList() {
    return StreamBuilder<List<BookingModel>>(
      stream: DbService().getAllBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState("No bookings found.");

        final bookings = snapshot.data!;
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.calendar_today, color: Colors.green, size: 20),
                ),
                title: Text(booking.serviceCategory, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                subtitle: Text("${booking.workerName} • ${booking.status}", style: TextStyle(color: booking.status == 'Confirmed' ? Colors.green : Colors.grey)),
                // trailing: Text("\$${booking.totalAmount}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Removed as field doesn't exist
              ),
            );
          },
        );
      },
    );
  }

  // 5. Shops List
  Widget _buildShopManagementList() {
    return StreamBuilder<List<ShopModel>>(
      stream: DbService().getPendingShops(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        
        final pendingShops = snapshot.data ?? [];
        
        return Column(
          children: [
             if (pendingShops.isEmpty) 
               Expanded(child: _buildEmptyState("No pending shop applications."))
             else
               Expanded(
                 child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: pendingShops.length,
                    itemBuilder: (context, index) {
                      final shop = pendingShops[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: shop.imageUrl != null ? DecorationImage(image: NetworkImage(shop.imageUrl!), fit: BoxFit.cover) : null,
                              color: Colors.grey[200],
                            ),
                            child: shop.imageUrl == null ? Icon(Icons.store, color: Colors.grey) : null,
                          ),
                          title: Text(shop.shopName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                          subtitle: Text("Owner: ${shop.ownerName}"),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopVerificationDetailScreen(shop: shop))),
                            child: Text("Review"),
                          ),
                        ),
                      );
                    },
                 ),
               ),
          ],
        );
      },
    );
  }

  // Helper Widgets
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String uid, String name, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete $name?"),
        content: Text("Are you sure you want to remove this $type? Action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (type == 'user') await DbService().deleteUser(uid);
              else if (type == 'worker') await DbService().deleteWorker(uid);
              else if (type == 'shop') await DbService().deleteShop(uid);
              
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name deleted")));
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
