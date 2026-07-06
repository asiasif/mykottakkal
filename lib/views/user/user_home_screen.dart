import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mykottakkal/services/auth_service.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/shop_update_model.dart';
import 'package:mykottakkal/views/user/worker_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/views/login_screen.dart';
import 'package:mykottakkal/views/user/user_bookings_screen.dart';

import 'package:mykottakkal/services/notification_helper.dart';
import 'package:mykottakkal/views/user/map_search_screen.dart';
import 'package:mykottakkal/views/shop/shop_categories_screen.dart';
import 'package:mykottakkal/views/user/map_search_screen.dart';
import 'package:mykottakkal/views/shop/shop_categories_screen.dart';
import 'package:mykottakkal/views/user/user_shop_orders_screen.dart'; 
import 'package:mykottakkal/views/user/job_list_screen.dart'; 
import 'package:mykottakkal/views/user/auto_stand_list_screen.dart'; // Import 
import 'package:mykottakkal/views/classifieds/classifieds_home_screen.dart'; // Import 
import 'package:mykottakkal/views/blood/blood_network_screen.dart'; // Import 
import 'package:mykottakkal/views/bus/bus_timing_screen.dart'; // Import Bus 
import 'package:mykottakkal/views/tourism/tourism_screen.dart'; // Import Tourism 
import 'package:mykottakkal/views/rentals/rentals_home_screen.dart'; // Import Rental 
import 'package:mykottakkal/views/user/emergency_screen.dart'; // Import Emergency // Import 
import 'package:mykottakkal/views/user/report_issue_screen.dart'; // Import
import 'package:mykottakkal/views/ayurveda/ayurveda_hub_screen.dart';
import 'package:mykottakkal/views/sports/football_bulletin_screen.dart';
import 'package:mykottakkal/views/user/my_reports_screen.dart'; // Import
import 'package:mykottakkal/models/user_model.dart'; // Import
import 'package:mykottakkal/views/user/daily_rates_screen.dart';
import 'package:mykottakkal/views/user/organic_bazaar_screen.dart';
import 'package:mykottakkal/models/event_model.dart'; // Import
import 'package:intl/intl.dart';
import 'package:mykottakkal/models/event_booking_model.dart'; // Import
import 'package:uuid/uuid.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _controller.forward();
    
    // Initialize Notifications on non-web platforms
    if (!kIsWeb) {
      NotificationHelper.init();
      NotificationHelper.monitorBookings();
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light bg
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildNotificationBar()), // Added Notification Bar
          SliverToBoxAdapter(child: _buildWelcomeSection()),
          SliverToBoxAdapter(child: _buildServicesGrid()), // Updated
          SliverToBoxAdapter(child: _buildEventsSection()), 
          SliverToBoxAdapter(child: _buildCommunityGrid()), // New Section
          SliverToBoxAdapter(child: SizedBox(height: 50)),
          SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: true,
      pinned: true,
      backgroundColor: Color(0xFF2E7D32), // Deep Herbal Green
      title: Text("Kottakkal City", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24)),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.history, color: Color(0xFFD4AF37)),  // Gold Icon
          tooltip: "My Bookings",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserBookingsScreen()));
          }
        ),
        IconButton(
          icon: Icon(Icons.receipt_long, color: Color(0xFFD4AF37)),  // Gold Icon
          tooltip: "My Shop Orders",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserShopOrdersScreen()));
          }
        ),
        IconButton(icon: Icon(Icons.notifications_outlined, color: Color(0xFFD4AF37)), onPressed: () {}),
        IconButton(
          icon: Icon(Icons.logout, color: Color(0xFFD4AF37)),
          onPressed: () async {
            await Provider.of<AuthService>(context, listen: false).signOut();
            if (context.mounted) {
               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen(role: 'user')), (route) => false);
            }
          },
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF3E2723), 
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)), 
          ],
          border: Border.all(color: const Color(0xFFD4AF37), width: 1), 
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ayurvedic Capital,", style: GoogleFonts.playfairDisplay(fontSize: 16, color: const Color(0xFFD4AF37), fontStyle: FontStyle.italic)), 
                      Text("Welcome Guest", style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text("Please log in to track bookings & earn points", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                Icon(Icons.temple_hindu, size: 60, color: const Color(0xFFD4AF37).withOpacity(0.9)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen(role: 'user')), (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF3E2723),
                  elevation: 0,
                ),
                child: const Text("Log In / Sign Up", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<UserModel?>(
      stream: DbService().getUser(currentUser.uid),
      builder: (context, snapshot) {
        final userPoints = snapshot.data?.points ?? 0;

        return Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF3E2723), 
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)], 
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8)), 
            ],
            border: Border.all(color: Color(0xFFD4AF37), width: 1), 
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ayurvedic Capital,", style: GoogleFonts.playfairDisplay(fontSize: 16, color: Color(0xFFD4AF37), fontStyle: FontStyle.italic)), 
                        Text("Find Expert Workers", style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white30)),
                          child: Text("Green Points: $userPoints 🌿", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent)),
                        )
                      ],
                    ),
                  ),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: Duration(seconds: 2),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: Icon(Icons.temple_hindu, size: 60, color: Color(0xFFD4AF37).withOpacity(0.9)));
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Civic Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportIssueScreen())),
                      icon: Icon(Icons.report_problem, size: 16),
                      label: Text("Report Issue"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyReportsScreen())),
                      icon: Icon(Icons.track_changes, size: 16),
                      label: Text("My Status"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildServicesGrid() {
    final services = [
      {'name': 'Farmer', 'icon': Icons.agriculture, 'color': Colors.green},
      {'name': 'Coconut\nClimber', 'icon': Icons.spa, 'color': Colors.brown},
      {'name': 'Grass\nCutter', 'icon': Icons.content_cut, 'color': Colors.lime},
      {'name': 'Auto\nTaxi', 'icon': Icons.local_taxi, 'color': Colors.amber},
      {'name': 'Plumber', 'icon': Icons.plumbing, 'color': Colors.blue},
      {'name': 'Electrician', 'icon': Icons.electrical_services, 'color': Colors.orange},
      {'name': 'Shops', 'icon': Icons.store, 'color': Colors.purple},
      {'name': 'Jobs', 'icon': Icons.work, 'color': Colors.teal},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Essential Services", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                tooltip: "View on Map",
                icon: Icon(Icons.map, color: Colors.green[700]),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MapSearchScreen())),
              ),
            ],
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // More dense for services
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildAnimatedCategoryCard(services[index], index, isSmall: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityGrid() {
    final community = [
      {'name': 'Buy &\nSell', 'icon': Icons.shopping_bag_outlined, 'color': Colors.pink},
      {'name': 'Blood\nBank', 'icon': Icons.bloodtype, 'color': Colors.red},
      {'name': 'Bus\nTimes', 'icon': Icons.directions_bus, 'color': Colors.indigo},
      {'name': 'Visit\nKottakkal', 'icon': Icons.camera_alt, 'color': Colors.teal},
      {'name': 'Rentals', 'icon': Icons.house, 'color': Colors.brown},
      {'name': 'Helpline', 'icon': Icons.emergency, 'color': Colors.red[900]},
      {'name': 'Ayurveda\nHub', 'icon': Icons.spa, 'color': const Color(0xFF2E7D32)},
      {'name': 'Football\nBulletin', 'icon': Icons.sports_soccer, 'color': const Color(0xFF1B5E20)},
      {'name': 'Market\nRates', 'icon': Icons.trending_up, 'color': Colors.orange[850]!},
      {'name': 'Farmers\nBazaar', 'icon': Icons.eco, 'color': Colors.green[800]!},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Explore & Community", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Larger cards for these features
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: community.length,
            itemBuilder: (context, index) {
              return _buildFeatureCard(community[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return StreamBuilder<List<EventModel>>(
      stream: DbService().getEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text("Happening in Kottakkal", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final event = snapshot.data![index];
                  return InkWell(
                    onTap: () => _showBookingSheet(context, event),
                    child: Container(
                      width: 280,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header color bar based on type
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: event.type == 'News' ? Colors.blue : (event.type == 'Notice' ? Colors.orange : Colors.purple),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(event.type.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                                    ),
                                    Text(event.date, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  event.title,
                                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  event.description,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        event.location,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                        maxLines: 1, overflow: TextOverflow.ellipsis
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
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

  void _showBookingSheet(BuildContext context, EventModel event) {
    if (event.type == 'News') return; // Don't book news

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isBooking = false;
        
        return StatefulBuilder(
            builder: (context, setSheetState) {
                return Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24))
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(event.title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text("${event.date} • ${event.location}", style: TextStyle(color: Colors.grey[600])),
                            SizedBox(height: 16),
                            Text(event.description, style: TextStyle(color: Colors.grey[800], height: 1.5)),
                            SizedBox(height: 32),
                            
                            SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                    ),
                                    onPressed: isBooking ? null : () async {
                                        final authUser = FirebaseAuth.instance.currentUser;
                                        if (authUser == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in to register for events!")));
                                            return;
                                        }
                                        setSheetState(() => isBooking = true);
                                        try {
                                            final user = await DbService().getUser(authUser.uid).first;
                                            if (user != null) {
                                                final booking = EventBookingModel(
                                                    id: Uuid().v4(),
                                                    eventId: event.id,
                                                    eventTitle: event.title,
                                                    userId: user.uid,
                                                    userName: user.name ?? 'User',
                                                    userPhone: user.phone,
                                                    timestamp: DateTime.now()
                                                );
                                                await DbService().bookEvent(booking);
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registered Successfully!")));
                                            }
                                        } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                            setSheetState(() => isBooking = false);
                                        }
                                    },
                                    child: isBooking 
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : Text("Register for Event")
                                ),
                            ),
                            SizedBox(height: 20),
                        ],
                    ),
                );
            }
        );
      }
    );
  }

  Widget _buildAnimatedCategoryCard(Map<String, dynamic> item, int index, {bool isSmall = false}) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval((1 / 8) * index, 1.0, curve: Curves.easeOut),
      )),
      child: InkWell(
        onTap: () {
            // Service Navigation Logic
            if (item['name'] == 'Shops') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => ShopCategoriesScreen()));
               return; 
            }
            if (item['name'] == 'Jobs') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => JobListScreen()));
               return; 
            }
            if (item['name'] == 'Auto\nTaxi') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => UserAutoStandListScreen()));
               return; 
            }

            // Fix newlines for matching
            String categoryName = (item['name'] as String).replaceAll('\n', ' ');
            Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerListScreen(category: categoryName)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: isSmall ? 22 : 28),
              ),
              SizedBox(height: 8),
              Text(
                item['name'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: isSmall ? 10 : 12, fontWeight: FontWeight.w600, height: 1.1),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> item, int index) {
      return InkWell(
        onTap: () {
            if (item['name'] == 'Buy &\nSell') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => ClassifiedsHomeScreen()));
            } else if (item['name'] == 'Blood\nBank') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => BloodNetworkScreen()));
            } else if (item['name'] == 'Bus\nTimes') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => BusTimingScreen()));
            } else if (item['name'] == 'Visit\nKottakkal') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => TourismScreen()));
            } else if (item['name'] == 'Rentals') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => RentalsHomeScreen()));
            } else if (item['name'] == 'Helpline') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => EmergencyScreen()));
            } else if (item['name'] == 'Ayurveda\nHub') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const AyurvedaHubScreen()));
            } else if (item['name'] == 'Football\nBulletin') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const FootballBulletinScreen()));
            } else if (item['name'] == 'Market\nRates') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyRatesScreen()));
            } else if (item['name'] == 'Farmers\nBazaar') {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganicBazaarScreen()));
            }
        },
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                    colors: [
                        (item['color'] as Color).withOpacity(0.8),
                        (item['color'] as Color),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                ),
                boxShadow: [BoxShadow(color: (item['color'] as Color).withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))]
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(item['icon'] as IconData, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text(
                        (item['name'] as String).replaceAll('\n', ' '),
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    )
                ],
            ),
        ),
      );
  }



  Widget _buildNotificationBar() {
    return StreamBuilder<List<ShopUpdateModel>>(
      stream: DbService().getShopUpdates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return SizedBox.shrink();

        final updates = snapshot.data!;
        // Concatenate active updates
        String marqueeText = updates.where((u) => u.isActive).map((u) => "${u.shopName}: ${u.message}   |   ").join();

        if (marqueeText.isEmpty) return SizedBox.shrink();

        return Container(
          width: double.infinity,
          height: 40,
          color: Colors.black, // Dark background for high visibility
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true, // Scroll right to left feel
            physics: BouncingScrollPhysics(), // Loop effect requires more complex logic, but simple scroll is good MVP
            itemBuilder: (context, index) {
               // Infinite scroll trick: 
               return Container(
                 padding: EdgeInsets.symmetric(horizontal: 10),
                 alignment: Alignment.center,
                 child: Text(
                   marqueeText, // Repeated text
                   style: GoogleFonts.firaCode(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 14),
                 ),
               );
            },
          ),
        );
      },
    );
  }
}

