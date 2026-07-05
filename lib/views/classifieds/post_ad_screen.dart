import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mykottakkal/services/cloudinary_service.dart';
import 'package:mykottakkal/models/ad_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _category = 'Others';
  final List<String> _categories = ['Vehicles', 'Electronics', 'Furniture', 'Others'];
  
  File? _image;
  bool _isLoading = false;
  bool _isEstimating = false; // Animation state

  // Smart Price Heuristics
  void _estimatePrice() async {
    final title = _titleController.text.toLowerCase();
    final category = _category;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter a title first!")));
      return;
    }

    setState(() => _isEstimating = true);
    await Future.delayed(Duration(milliseconds: 800)); // Fake AI delay for "thinking" effect

    String? estimatedRange;
    
    // 1. Electronics
    if (category == 'Electronics') {
      if (title.contains('iphone')) estimatedRange = "₹20,000 - ₹50,000";
      else if (title.contains('samsung')) estimatedRange = "₹15,000 - ₹40,000";
      else if (title.contains('redmi') || title.contains('realme')) estimatedRange = "₹8,000 - ₹15,000";
      else if (title.contains('laptop') || title.contains('macbook') || title.contains('dell') || title.contains('hp')) estimatedRange = "₹25,000 - ₹60,000";
      else if (title.contains('tv') || title.contains('television')) estimatedRange = "₹10,000 - ₹30,000";
      else if (title.contains('watch')) estimatedRange = "₹1,000 - ₹5,000";
    } 
    // 2. Vehicles
    else if (category == 'Vehicles') {
       if (title.contains('scooter') || title.contains('activa') || title.contains('access')) estimatedRange = "₹30,000 - ₹60,000";
       else if (title.contains('car') || title.contains('maruti') || title.contains('hyundai')) estimatedRange = "₹2,00,000 - ₹5,00,000";
       else if (title.contains('bike') || title.contains('royal enfield') || title.contains('splendor')) estimatedRange = "₹40,000 - ₹80,000";
    }
    // 3. Furniture
    else if (category == 'Furniture') {
       if (title.contains('sofa')) estimatedRange = "₹5,000 - ₹15,000";
       else if (title.contains('table')) estimatedRange = "₹2,000 - ₹8,000";
       else if (title.contains('chair')) estimatedRange = "₹1,000 - ₹4,000";
       else if (title.contains('bed')) estimatedRange = "₹8,000 - ₹20,000";
    }

    setState(() => _isEstimating = false);

    if (estimatedRange != null) {
      _showEstimationSheet(estimatedRange);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not estimate based on title. Try browsing similar ads.")));
    }
  }

  void _showEstimationSheet(String range) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 40),
              SizedBox(height: 16),
              Text("Smart Price Estimate", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Based on market trends in Kottakkal for '${_titleController.text}':", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 16),
              Text(range, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700])),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                   // Clean string to get average or just set start of range? 
                   // Let's just copy the lower bound for convenience
                   String lowerBound = range.split(' - ')[0].replaceAll('₹', '').replaceAll(',', '').trim();
                   _priceController.text = lowerBound;
                   Navigator.pop(context);
                },
                child: Text("Use Lower Estimate"),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
              )
            ],
          ),
        );
      }
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submitAd() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and add photo")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final imageUrl = await CloudinaryService().uploadImage(XFile(_image!.path));
      
      if (imageUrl == null) throw "Image upload failed";

      final ad = AdModel(
        id: Uuid().v4(),
        sellerId: user.uid,
        sellerName: user.displayName ?? "User", // Ideally fetch from DB
        title: _titleController.text,
        price: double.parse(_priceController.text),
        description: _descController.text,
        imageUrl: imageUrl,
        category: _category,
        contactPhone: _phoneController.text,
        postedDate: DateTime.now(),
      );

      await DbService().postAd(ad);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ad Posted!")));
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Sell Item"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
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
                  image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
                ),
                child: _image == null 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), SizedBox(height: 8), Text("Add Photo")],
                      )
                    : null,
              ),
            ),
            SizedBox(height: 24),
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Title (e.g. 2018 iPad)", border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextField(
              controller: _priceController, 
              keyboardType: TextInputType.number, 
              decoration: InputDecoration(
                labelText: "Price (₹)", 
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: _isEstimating 
                     ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                     : Icon(Icons.auto_awesome, color: Colors.amber), 
                  onPressed: _estimatePrice,
                  tooltip: "Get Smart Estimate",
                )
              )
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(labelText: "Category", border: OutlineInputBorder()),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            SizedBox(height: 16),
            TextField(controller: _descController, maxLines: 3, decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Contact Phone", border: OutlineInputBorder())),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitAd,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Post Ad"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
