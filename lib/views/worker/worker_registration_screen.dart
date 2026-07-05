import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/services/cloudinary_service.dart';

class WorkerRegistrationScreen extends StatefulWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  State<WorkerRegistrationScreen> createState() => _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState extends State<WorkerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = 'Farmer';
  
  final List<String> _categories = [
    'Farmer', 
    'Coconut Climber', 
    'Grass Cutter', 
    'Manual Labour', 
    'Plumber', 
    'Electrician'
  ];

  XFile? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  Future<void> _registerWorker() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? imageUrl;
      if (_imageFile != null) {
         imageUrl = await CloudinaryService().uploadImage(_imageFile!);
      }

      final user = FirebaseAuth.instance.currentUser;
      String uid = user?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();
      String phone = user?.phoneNumber ?? "9876543210"; 
      
      final newWorker = WorkerModel(
        uid: uid,
        name: _nameController.text,
        phone: phone,
        category: _selectedCategory,
        description: _descController.text,
        isAvailable: true,
        profileImage: imageUrl,
      );

      await DbService().saveWorkerProfile(newWorker);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/worker-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Worker Profile Setup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Tell us about your work", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                    child: _imageFile == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[400])
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(child: Text("Tap to upload photo", style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Your Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: "Job Category", border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(labelText: "Description (Experience, Tools, etc.)", border: OutlineInputBorder()),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerWorker,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : Text("Create Profile"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
