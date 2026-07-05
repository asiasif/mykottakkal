import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart'; // Import
import 'package:geolocator/geolocator.dart'; // Import
import 'package:mykottakkal/services/cloudinary_service.dart'; // Import
import 'dart:io';
import 'package:mykottakkal/models/issue_model.dart';
import 'package:mykottakkal/services/db_service.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Waste';
  bool _isLoading = false;

  final List<String> _categories = ['Waste', 'Road', 'Street Light', 'Water Leak', 'Other'];
  
  // New Fields
  XFile? _selectedImage;
  Position? _currentPosition;
  bool _isGettingLocation = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); 
    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
    }
  }

  Future<void> _getCurrentLocation() async {
      setState(() => _isGettingLocation = true);
      try {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.denied) return;
          }
          if (permission == LocationPermission.deniedForever) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permissions denied permanently")));
             return;
          }

          Position position = await Geolocator.getCurrentPosition();
          setState(() => _currentPosition = position);
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error getting location: $e")));
      } finally {
          setState(() => _isGettingLocation = false);
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Consistent light bg
      appBar: AppBar(
        title: Text("Report an Issue", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Help us keep Kottakkal clean and safe.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              
              // Category Dropdown
              Text("Category", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: GoogleFonts.outfit()),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Description Field
              Text("Description", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Describe the issue (e.g. location, details)...",
                  hintStyle: GoogleFonts.outfit(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
                
              // Image Picker
              Row(
                  children: [
                      _selectedImage != null 
                          ? Container(
                              height: 80, width: 80, 
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                      image: kIsWeb
                                          ? NetworkImage(_selectedImage!.path) as ImageProvider
                                          : FileImage(File(_selectedImage!.path)) as ImageProvider,
                                      fit: BoxFit.cover,
                                  )
                              )
                            )
                          : Container(
                              height: 80, width: 80,
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                          onPressed: _pickImage, 
                          icon: Icon(Icons.camera_alt),
                          label: Text("Add Photo")
                      )
                  ],
              ),
              SizedBox(height: 16),

              // Location Picker
              Row(
                 children: [
                     Icon(Icons.location_on, color: _currentPosition != null ? Colors.green : Colors.grey),
                     SizedBox(width: 8),
                     Expanded(
                       child: Text(_currentPosition != null ? "Location Attached" : "No Location Attached", 
                          style: TextStyle(color: _currentPosition != null ? Colors.green : Colors.grey)
                       ),
                     ),
                     _isGettingLocation 
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton(onPressed: _getCurrentLocation, child: Text("Attach My Location"))
                 ], 
              ),
              SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32), // Deep Green
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Submit Report", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String? imageUrl;
      if (_selectedImage != null) {
          imageUrl = await CloudinaryService().uploadImage(_selectedImage!);
      }

      final issue = IssueModel(
        id: Uuid().v4(),
        userId: user.uid,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        status: 'Pending',
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
      );

      await DbService().reportIssue(issue);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Issue reported successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
