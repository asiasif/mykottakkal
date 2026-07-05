import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mykottakkal/services/cloudinary_service.dart';
import 'package:mykottakkal/models/tourism_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';

class AdminManageTourismScreen extends StatefulWidget {
  const AdminManageTourismScreen({super.key});

  @override
  State<AdminManageTourismScreen> createState() => _AdminManageTourismScreenState();
}

class _AdminManageTourismScreenState extends State<AdminManageTourismScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text("Manage Tourism"), backgroundColor: Colors.teal[800], foregroundColor: Colors.white),
      body: StreamBuilder<List<TourismModel>>(
        stream: DbService().getPlaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          
          final places = snapshot.data ?? [];
          if (places.isEmpty) return Center(child: Text("No places added."));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(place.imageUrl), fit: BoxFit.cover)),
                  ),
                  title: Text(place.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(place.location),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePlace(place.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlaceDialog,
        backgroundColor: Colors.teal[800],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _deletePlace(String id) async {
    await DbService().deletePlace(id);
  }

  void _showAddPlaceDialog() {
    // Show a full screen dialog or navigate to a new page for adding
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddTourismPlaceScreen()));
  }
}

class AddTourismPlaceScreen extends StatefulWidget {
  const AddTourismPlaceScreen({super.key});

  @override
  State<AddTourismPlaceScreen> createState() => _AddTourismPlaceScreenState();
}

class _AddTourismPlaceScreenState extends State<AddTourismPlaceScreen> {
  final _nameController = TextEditingController();
  final _locController = TextEditingController();
  final _descController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
     if (_nameController.text.isEmpty || _image == null) return;
     setState(() => _isLoading = true);
     
     try {
       final url = await CloudinaryService().uploadImage(XFile(_image!.path));
       if (url != null) {
          final place = TourismModel(
            id: Uuid().v4(),
            name: _nameController.text,
            description: _descController.text,
            imageUrl: url,
            location: _locController.text,
          );
          await DbService().addPlace(place);
          if (mounted) Navigator.pop(context);
       }
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
     } finally {
       if (mounted) setState(() => _isLoading = false);
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Destination")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null),
                child: _image == null ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey) : null,
              ),
            ),
            SizedBox(height: 16),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Place Name", border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextField(controller: _locController, decoration: InputDecoration(labelText: "Location", border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextField(controller: _descController, maxLines: 4, decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder())),
            SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _submit, child: _isLoading ? CircularProgressIndicator() : Text("Save")))
          ],
        ),
      ),
    );
  }
}
