import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/services/cloudinary_service.dart';
import 'package:mykottakkal/models/shop_model.dart';
import 'package:mykottakkal/views/shop/shop_dashboard_screen.dart';

class ShopRegistrationScreen extends StatefulWidget {
  const ShopRegistrationScreen({super.key});

  @override
  State<ShopRegistrationScreen> createState() => _ShopRegistrationScreenState();
}

class _ShopRegistrationScreenState extends State<ShopRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _googleMapLinkController = TextEditingController(); // NEW: Google Map Link

  String _selectedType = 'Restaurant';
  // Updated Categories to match User Module
  final List<String> _shopTypes = [
    'Restaurant',
    'Cafe',
    'Grocery',
    'Fashion',
    'Electronics',
    'Other'
  ];
  
  bool _deliveryAvailable = false;
  XFile? _shopImage; // Board / Front
  Uint8List? _shopBytes;
  XFile? _logoImage; // Logo
  Uint8List? _logoBytes;
  XFile? _licenseImage;
  Uint8List? _licenseBytes;
  bool _isLoading = false;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> _pickImage(int type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      if (mounted) {
        setState(() {
          if (type == 1) {
            _shopImage = image;
            _shopBytes = bytes;
          } else if (type == 2) {
            _logoImage = image;
            _logoBytes = bytes;
          } else if (type == 3) {
            _licenseImage = image;
            _licenseBytes = bytes;
          }
        });
      }
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_shopImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please upload a shop image')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String? shopImageUrl;
      String? logoImageUrl;
      String? licenseImageUrl;

      // Upload Images
      shopImageUrl = await _cloudinaryService.uploadImage(_shopImage!);
      if (_logoImage != null) {
        logoImageUrl = await _cloudinaryService.uploadImage(_logoImage!);
      }
      if (_licenseImage != null) {
        licenseImageUrl = await _cloudinaryService.uploadImage(_licenseImage!);
      }

      final shop = ShopModel(
        uid: user.uid,
        shopName: _shopNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        shopType: _selectedType,
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        deliveryAvailable: _deliveryAvailable,
        status: 'Pending',
        imageUrl: shopImageUrl,
        logoUrl: logoImageUrl,
        licenseUrl: licenseImageUrl,
        googleMapLink: _googleMapLinkController.text.trim(),
        timestamp: DateTime.now(),
      );

      await DbService().createShopApplication(shop);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Application Submitted Successfully!")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ShopDashboardScreen()),
        );
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: Text("Shop Partner Application"), 
        backgroundColor: Color(0xFF2E7D32), 
        foregroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apply to List Your Shop", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Join our network. Admin approval required before listing.", style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 24),

              _buildSectionHeader("Basic Details"),
              _buildTextField(_shopNameController, "Shop Name", Icons.store),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: _inputDecoration("Shop Category", Icons.category),
                items: _shopTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              SizedBox(height: 16),
              _buildTextField(_ownerNameController, "Owner Name", Icons.person),
              _buildTextField(_mobileController, "Mobile Number", Icons.phone, keyboardType: TextInputType.phone),
              _buildTextField(_emailController, "Email Address", Icons.email, keyboardType: TextInputType.emailAddress),
              
              SizedBox(height: 24),
              _buildSectionHeader("Location & Details"),
               _buildTextField(_addressController, "Shop Location / Address", Icons.location_on, maxLines: 2),
               _buildTextField(_googleMapLinkController, "Google Map Location Link", Icons.map, maxLines: 1), // Google Map Link
               SizedBox(height: 4),
               Text("  * Paste Google Maps share link here", style: TextStyle(color: Colors.grey, fontSize: 12)),
               SizedBox(height: 12),

              _buildTextField(_descriptionController, "Description", Icons.description, maxLines: 3),

              SizedBox(height: 16),
              SwitchListTile(
                title: Text("Delivery Available"),
                value: _deliveryAvailable,
                onChanged: (val) => setState(() => _deliveryAvailable = val),
                 activeColor: Color(0xFF2E7D32),
              ),

              SizedBox(height: 24),
              _buildSectionHeader("Documents & Images"),
              
              _buildImagePicker("Shop Board / Front Image *", _shopImage, _shopBytes, 1),
              _buildImagePicker("Shop Logo (Optional)", _logoImage, _logoBytes, 2),
              _buildImagePicker("License / Id Proof (Required)", _licenseImage, _licenseBytes, 3), // Emphasized License

              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Submit Application", style: GoogleFonts.outfit(fontSize: 18, color: Colors.white)),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "Please enter $label" : null,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildImagePicker(String label, XFile? file, Uint8List? bytes, int type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(type),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
              image: bytes != null ? DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover) : null,
            ),
            child: file == null 
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.add_a_photo, color: Colors.grey), Text("Tap to upload")],
                )) 
              : null,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
