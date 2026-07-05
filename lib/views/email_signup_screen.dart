import 'package:flutter/material.dart';
import 'package:mykottakkal/services/auth_service.dart';

class EmailSignUpScreen extends StatefulWidget {
  const EmailSignUpScreen({super.key});

  @override
  State<EmailSignUpScreen> createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  void _handleSignUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => isLoading = true);
    
    final user = await AuthService().signUpWithEmail(_emailController.text.trim(), _passwordController.text.trim());
    
    setState(() => isLoading = false);

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/role-selection');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign Up Failed.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
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
              decoration: InputDecoration(labelText: "Password (6+ chars)", border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: isLoading ? CircularProgressIndicator() : Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
