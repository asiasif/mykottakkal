import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/football_match_model.dart';
import 'package:mykottakkal/models/bulletin_notice_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/sports/post_notice_screen.dart';
import 'package:intl/intl.dart';

class FootballBulletinScreen extends StatefulWidget {
  const FootballBulletinScreen({super.key});

  @override
  State<FootballBulletinScreen> createState() => _FootballBulletinScreenState();
}

class _FootballBulletinScreenState extends State<FootballBulletinScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0), // Warm Cream
      appBar: AppBar(
        title: Text("Sports & Notices", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1B5E20), // Dark Sports Green
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.yellowAccent,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.yellowAccent,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "Sevens Football", icon: Icon(Icons.sports_soccer)),
            Tab(text: "Notice Board", icon: Icon(Icons.campaign)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFootballTab(),
          _buildNoticeBoardTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please log in to post a notice!")),
            );
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PostNoticeScreen()));
        },
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: Text("Post Notice", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- FOOTBALL TAB ---

  Widget _buildFootballTab() {
    return StreamBuilder<List<FootballMatchModel>>(
      stream: DbService().getFootballMatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No matches listed.", style: GoogleFonts.outfit(color: Colors.grey)));
        }

        final matches = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _buildMatchCard(match);
          },
        );
      },
    );
  }

  Widget _buildMatchCard(FootballMatchModel match) {
    final isLive = match.status == 'Live';
    final isUpcoming = match.status == 'Upcoming';

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Match Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isLive ? Colors.red[50] : Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  match.tournamentName,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                if (isLive)
                  Row(
                    children: [
                      const _BlinkingLiveDot(),
                      const SizedBox(width: 6),
                      Text(
                        "LIVE - ${match.minute}",
                        style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  )
                else
                  Text(
                    match.status.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: isUpcoming ? Colors.blue : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Scoreboard / Matchup
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Team A
                    Expanded(
                      child: Text(
                        match.teamA,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF3E2723)),
                        maxLines: 2,
                      ),
                    ),
                    
                    // Score display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isUpcoming
                          ? Text(
                              "VS",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1B5E20)),
                            )
                          : Text(
                              "${match.scoreA}  -  ${match.scoreB}",
                              style: GoogleFonts.firaCode(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF1B5E20)),
                            ),
                    ),

                    // Team B
                    Expanded(
                      child: Text(
                        match.teamB,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF3E2723)),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Venue & Schedule Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFF1B5E20)),
                        const SizedBox(width: 4),
                        Text(
                          match.venue,
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${match.matchDate} • ${match.matchTime}",
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NOTICE BOARD TAB ---

  Widget _buildNoticeBoardTab() {
    return StreamBuilder<List<BulletinNoticeModel>>(
      stream: DbService().getBulletinNotices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Notice board is empty.", style: GoogleFonts.outfit(color: Colors.grey)));
        }

        final notices = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            final notice = notices[index];
            return _buildNoticeCard(notice);
          },
        );
      },
    );
  }

  Widget _buildNoticeCard(BulletinNoticeModel notice) {
    final Color categoryColor = _getCategoryColor(notice.category);
    final String formattedDate = DateFormat('MMM d, h:mm a').format(notice.postedDate);

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    notice.category.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: categoryColor),
                  ),
                ),
                Text(
                  formattedDate,
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.title,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF3E2723)),
            ),
            const SizedBox(height: 6),
            Text(
              notice.description,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[800], height: 1.4),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_pin, size: 14, color: categoryColor),
                const SizedBox(width: 6),
                Text(
                  "By: ${notice.postedBy}",
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Traffic':
        return Colors.orange[800]!;
      case 'Water/Power':
        return Colors.blue[800]!;
      case 'Health Alert':
        return Colors.red[800]!;
      default:
        return Colors.purple[800]!;
    }
  }
}

// Blinking Red Dot Animation Widget for LIVE Matches
class _BlinkingLiveDot extends StatefulWidget {
  const _BlinkingLiveDot();

  @override
  State<_BlinkingLiveDot> createState() => _BlinkingLiveDotState();
}

class _BlinkingLiveDotState extends State<_BlinkingLiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
