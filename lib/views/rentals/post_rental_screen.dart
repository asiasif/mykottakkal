import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mykottakkal/services/cloudinary_service.dart';
import 'package:mykottakkal/models/rental_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';

class PostRentalScreen extends StatefulWidget {
  const PostRentalScreen({super.key});

  @override
  State<PostRentalScreen> createState() => _PostRentalScreenState();
}

class _PostRentalScreenState extends State<PostRentalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _category = 'House';
  final List<String> _categories = ['House', 'Shop', 'Vehicle', 'Equipment'];
  
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please add an image")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = await CloudinaryService().uploadImage(XFile(_image!.path));
      if (url == null) throw "Image upload failed";

      final rental = RentalModel(
        id: Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        category: _category,
        price: double.parse(_priceController.text),
        location: _locController.text,
        imageUrl: url,
        contactPhone: _phoneController.text,
        date: DateTime.now(),
      );

      await DbService().addRental(rental);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rental Posted Successfully!")));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post Rental Ad"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100], 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null
                  ),
                  child: _image == null 
                      ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), Text("Add Photo", style: TextStyle(color: Colors.grey))]) 
                      : null,
                ),
              ),
              SizedBox(height: 20),
              
              Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Ad Title", hintText: "e.g. 2BHK House for Rent", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Price / Rent (₹)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _locController,
                decoration: InputDecoration(labelText: "Location", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Contact Phone", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(labelText: "Description", alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[900], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Post AD", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
