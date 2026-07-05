import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:mykottakkal/services/auth_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Who are you?", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildRoleCard(
              context,
              title: "I need a Service",
              subtitle: "Find Farmers, Workers, etc.",
              icon: Icons.search,
              color: Colors.blueAccent,
              role: 'user',
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              context,
              title: "I am a Worker",
              subtitle: "List my services (Farmer, Climber...)",
              icon: Icons.handyman,
              color: Colors.orangeAccent,
              role: 'worker',
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              context,
              title: "I am a Shop Owner",
              subtitle: "Post daily updates & offers",
              icon: Icons.store,
              color: Colors.purpleAccent,
              role: 'merchant',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required String role}) {
    return InkWell(
      onTap: () async {
        if (role == 'user') {
           final user = FirebaseAuth.instance.currentUser;
           if (user != null) {
             bool exists = await Provider.of<AuthService>(context, listen: false).checkUserExists(user.uid);
             if (exists) {
               Navigator.pushNamed(context, '/user-home');
             } else {
               Navigator.pushNamed(context, '/user-profile-setup');
             }
           } else {
             Navigator.pushNamed(context, '/user-profile-setup');
           }
        } else if (role == 'worker') {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            bool exists = await Provider.of<AuthService>(context, listen: false).checkWorkerExists(user.uid);
            if (exists) {
              Navigator.pushNamed(context, '/worker-dashboard');
            } else {
              Navigator.pushNamed(context, '/worker-registration');
            }
          } else {
            Navigator.pushNamed(context, '/worker-registration');
          }
        } else {
           Navigator.pushNamed(context, '/merchant-dashboard');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
