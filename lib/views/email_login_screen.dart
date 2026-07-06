import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mykottakkal/services/auth_service.dart';

class EmailLoginScreen extends StatefulWidget {
  final String role;
  const EmailLoginScreen({super.key, this.role = 'user'});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => isLoading = true);
    
    // Pass role to signIn (if implementation supports it or just sign in)
    // For now assuming signInWithEmail handles auth, and we route based on widget.role or fetched user doc
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signInWithEmail(_emailController.text.trim(), _passwordController.text.trim());
    
    setState(() => isLoading = false);

    if (user != null) {
      if (widget.role == 'admin') {
         Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else if (widget.role == 'merchant') {
         Navigator.pushReplacementNamed(context, '/merchant-dashboard');
      } else if (widget.role == 'worker') {
         bool exists = await authService.checkWorkerExists(user.uid);
         if (mounted) {
           if (exists) {
             Navigator.pushReplacementNamed(context, '/worker-dashboard');
           } else {
             Navigator.pushReplacementNamed(context, '/worker-registration');
           }
         }
      } else {
         bool exists = await authService.checkUserExists(user.uid);
         if (mounted) {
           if (exists) {
             Navigator.pushReplacementNamed(context, '/user-home');
           } else {
             Navigator.pushReplacementNamed(context, '/user-profile-setup');
           }
         }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed. Check credentials.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login with Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: isLoading ? CircularProgressIndicator() : Text("Login"),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: Text("Don't have an account? Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}
