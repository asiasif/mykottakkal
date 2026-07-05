import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Added
import 'package:mykottakkal/services/auth_service.dart'; // Added
import 'package:mykottakkal/views/email_login_screen.dart';
import 'package:mykottakkal/views/landing_screen.dart'; 

class LoginScreen extends StatefulWidget { // Converted to StatefulWidget
  final String role;
  const LoginScreen({super.key, this.role = 'user'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    
    final user = await Provider.of<AuthService>(context, listen: false).signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (user != null) {
        if (widget.role == 'admin') {
           Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else if (widget.role == 'merchant') {
           Navigator.pushReplacementNamed(context, '/merchant-dashboard');
        } else if (widget.role == 'worker') {
           Navigator.pushReplacementNamed(context, '/worker-dashboard');
        } else {
           Navigator.pushReplacementNamed(context, '/user-home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign-In Failed or Cancelled.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine title text based on role, or generic
    String titleText = "Kottakkal City";
    String subtitleText = "Legacy of Tradition";

    if (widget.role == 'admin') {
      titleText = "Admin Portal";
      subtitleText = "City Management";
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Traditional Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/kottakkal_traditional_bg.png', 
              fit: BoxFit.cover,
               // Add a dark overlay for readability
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          
          // 2. Content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Icon
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFD4AF37), width: 2), // Gold Border
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Icon(Icons.temple_buddhist, size: 60, color: Color(0xFFD4AF37)), 
                  ),
                  SizedBox(height: 24),
                  
                  // Text
                  Text(
                    titleText,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF9F5F0), // Cream text
                      shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    subtitleText,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      letterSpacing: 1.2,
                      color: Color(0xFFD4AF37), // Gold text
                    ),
                  ),

                  SizedBox(height: 48),

                  // Login Option Card
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 400),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9F5F0).withOpacity(0.95), // Parchment/Cream background
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10)),
                      ],
                      border: Border.all(color: Color(0xFFD4AF37), width: 1), // Gold Border
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Welcome Back",
                          style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),

                        // Google Sign In (Replaces Email)
                        _isLoading 
                          ? Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                          : _buildLoginButton(
                              context, 
                              "Sign in with Google", 
                              Icons.g_mobiledata, // Or use a custom Google icon
                              _handleGoogleLogin,
                            ),
                        
                        SizedBox(height: 12),
                        
                        // Keep Email as secondary option? Or user asked to REPLACE?
                        // "instead of login with email i need sign with google" -> Replace main button.
                        // I will add a small text button for Email just in case, or remove it entirely if strictly interpreted.
                        // Let's keep Phone as secondary.
                        
                        _buildLoginButton(
                          context, 
                          "Login with Phone", 
                          Icons.phone, 
                          () {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Phone Login coming soon")));
                          },
                          isOutlined: true,
                        ),

                        // Optional: Small Email Login link for Admin/Debug?
                        SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EmailLoginScreen(role: widget.role))),
                            child: Text("Login with Email", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ),
                        ),

                        if (widget.role == 'user') ...[
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[400])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text("OR", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ),
                              Expanded(child: Divider(color: Colors.grey[400])),
                            ],
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandingScreen()));
                            },
                             child: Text("Continue as Guest", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, String text, IconData icon, VoidCallback onPressed, {bool isOutlined = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : Color(0xFF2E7D32),
        foregroundColor: isOutlined ? Color(0xFF2E7D32) : Colors.white,
        elevation: isOutlined ? 0 : 4,
        side: isOutlined ? BorderSide(color: Color(0xFF2E7D32)) : BorderSide.none,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 12),
          Text(text, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
