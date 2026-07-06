import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/models/user_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/services/cloudinary_service.dart';
import 'package:provider/provider.dart';
import 'package:mykottakkal/services/theme_service.dart';

class UserProfileSetupScreen extends StatefulWidget {
  const UserProfileSetupScreen({super.key});

  @override
  State<UserProfileSetupScreen> createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  XFile? _imageFile;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageFile = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      String? imageUrl;
      if (_imageFile != null) {
         imageUrl = await CloudinaryService().uploadImage(_imageFile!);
      }

      // Get current user ID (assuming Auth is working)
      // For now using time based ID if no user, but better to use Auth User
      // String uid = DateTime.now().millisecondsSinceEpoch.toString();
      // Better:
      final user = FirebaseAuth.instance.currentUser;
      String uid = user?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();
      String phone = user?.phoneNumber ?? "9876543210"; 

      UserModel newUser = UserModel(
        uid: uid,
        name: _nameController.text,
        phone: phone,
        role: 'user',
        isVerified: true,
        profileImage: imageUrl,
      );

      await DbService().saveUserProfile(newUser);
      
      if (mounted) {
         setState(() => _isLoading = false);
         Navigator.pushReplacementNamed(context, '/user-home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome to Kottakkal City App!",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Please enter your details to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey),
              ),
              SizedBox(height: 32),
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : null,
                    child: _imageFile == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[400])
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(child: Text("Tap to upload photo", style: TextStyle(color: Colors.grey))),
              SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? "Name is required" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address / Area",
                  hintText: "e.g., Changuvetty",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v!.isEmpty ? "Address is required" : null,
              ),
              SizedBox(height: 16),
               Consumer<ThemeService>(
                builder: (context, themeService, _) {
                  return SwitchListTile(
                    title: Text("Dark Mode"),
                    value: themeService.themeMode == ThemeMode.dark,
                    onChanged: (val) => themeService.toggleTheme(val),
                    secondary: Icon(Icons.dark_mode),
                  );
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Start Exploring"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
