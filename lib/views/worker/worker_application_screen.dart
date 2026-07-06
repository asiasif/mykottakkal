import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/services/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/views/worker/worker_dashboard_screen.dart';

class WorkerApplicationScreen extends StatefulWidget {
  const WorkerApplicationScreen({super.key});

  @override
  State<WorkerApplicationScreen> createState() => _WorkerApplicationScreenState();
}

class _WorkerApplicationScreenState extends State<WorkerApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController(); // Optional

  String _selectedCategory = 'Farmer';
  final List<String> _categories = [
    'Farmer',
    'Coconut Climber',
    'Grass Cutter',
    'Plumber',
    'Electrician',
    'Auto Taxi'
  ];

  XFile? _profileImage;
  Uint8List? _profileBytes;
  XFile? _certificateImage;
  Uint8List? _certificateBytes;
  bool _isLoading = false;
  Position? _currentPosition; // Store location
  bool _isGettingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location captured!")));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error getting location: $e")));
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _pickImage(bool isProfile) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (isProfile) {
          _profileImage = pickedFile;
          _profileBytes = bytes;
        } else {
          _certificateImage = pickedFile;
          _certificateBytes = bytes;
        }
      });
    }
  }

  void _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Image is required")));
      return;
    }
    // Certificate is optional, but recommended

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // 1. Upload Images
      String? profileUrl = await CloudinaryService().uploadImage(_profileImage!);
      String? certUrl;
      if (_certificateImage != null) {
        certUrl = await CloudinaryService().uploadImage(_certificateImage!);
      }

      // 2. Create Worker Model
      final worker = WorkerModel(
        uid: user.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        category: _selectedCategory,
        description: _descController.text.trim(),
        price: _priceController.text.isNotEmpty ? double.tryParse(_priceController.text) : null,
        address: _addressController.text.trim(),
        profileImage: profileUrl,
        certificateUrl: certUrl,
        status: 'Pending', // Explicitly Pending
        isAvailable: true,
        rating: 0.0,
        latitude: _currentPosition?.latitude, // Add Latitude
        longitude: _currentPosition?.longitude, // Add Longitude
      );

      // 3. Save to DB
      await DbService().saveWorkerProfile(worker);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Application Submitted!")));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerDashboardScreen()));
      }
    } catch (e) {
      print("Application Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error submitting application: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Worker Application"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Join Kottakkal Connect", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Complete verification to start getting jobs.", style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 24),

              // Profile Image Picker
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(true),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _profileBytes != null ? MemoryImage(_profileBytes!) : null,
                    child: _profileImage == null ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey) : null,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(child: Text("Profile Photo *", style: TextStyle(fontSize: 12))),
              SizedBox(height: 24),

              // Fields
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
                decoration: InputDecoration(labelText: "Category", prefixIcon: Icon(Icons.category)),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(labelText: "Address", prefixIcon: Icon(Icons.home)),
                validator: (v) => v!.isEmpty ? "Required for verification" : null,
              ),
              SizedBox(height: 16),

              // Location Button
              ElevatedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: _isGettingLocation 
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(Icons.my_location),
                label: Text(_currentPosition == null ? "Get Current Location" : "Location Captured (Update?)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPosition == null ? Colors.blueGrey : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              if (_currentPosition == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text("* Location is required for 'Find Near Me'", style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(labelText: "Description (Experience, Skills)", prefixIcon: Icon(Icons.description)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Starting Price (₹) - Optional", prefixIcon: Icon(Icons.currency_rupee)),
              ),
              SizedBox(height: 24),

              // Certificate Picker
              Text("Verify Your Skill (Optional)", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickImage(false),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                    child: _certificateBytes != null 
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(_certificateBytes!, fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file, size: 40, color: Colors.grey),
                          Text("Upload Certificate / ID Proof"),
                        ],
                      ),
                ),
              ),
              SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit Application"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
