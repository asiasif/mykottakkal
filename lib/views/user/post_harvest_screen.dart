import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/models/organic_harvest_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';

class PostHarvestScreen extends StatefulWidget {
  const PostHarvestScreen({super.key});

  @override
  State<PostHarvestScreen> createState() => _PostHarvestScreenState();
}

class _PostHarvestScreenState extends State<PostHarvestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imageController = TextEditingController();

  String _selectedCategory = 'Vegetables';
  String _selectedUnit = 'kg';
  bool _isSubmitting = false;

  final List<String> _categories = ['Vegetables', 'Fruits', 'Grains', 'Tubers', 'Others'];
  final List<String> _units = ['kg', 'bundle', 'piece', 'box', 'packet'];

  @override
  void initState() {
    super.initState();
    _prefillFarmerData();
  }

  Future<void> _prefillFarmerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final profile = await DbService().getUser(user.uid).first;
        if (profile != null) {
          setState(() {
            _phoneController.text = profile.phone;
          });
        }
      } catch (e) {
        debugPrint("Error prefilling farmer data: $e");
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submitHarvest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final profile = await DbService().getUser(user.uid).first;
      final farmerName = profile?.name ?? 'Farmer';

      final newHarvest = OrganicHarvestModel(
        id: const Uuid().v4(),
        farmerId: user.uid,
        farmerName: farmerName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        unit: _selectedUnit,
        quantity: double.parse(_qtyController.text),
        location: _locationController.text.trim(),
        phone: _phoneController.text.trim(),
        imageUrl: _imageController.text.trim(),
        timestamp: DateTime.now(),
        isApproved: false, // Default goes to pending
      );

      await DbService().postOrganicHarvest(newHarvest);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Harvest listing submitted! It will go live after admin approval."),
            backgroundColor: Colors.green,
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Post Today's Harvest", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isSubmitting 
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Farmer's Listing Details", 
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[900])
                    ),
                    const SizedBox(height: 4),
                    Text("Tell buyers what fresh produce you harvested today.", 
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])
                    ),
                    const SizedBox(height: 24),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration("Product Title", hint: "e.g., Organic Tapioca / Nendran Banana"),
                      validator: (value) => value == null || value.trim().isEmpty ? "Please enter product title" : null,
                    ),
                    const SizedBox(height: 16),

                    // Row for Category & Unit
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: _inputDecoration("Category"),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val ?? 'Vegetables'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: _inputDecoration("Sale Unit"),
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (val) => setState(() => _selectedUnit = val ?? 'kg'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row for Price & Qty
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration("Price (₹ per $_selectedUnit)", hint: "e.g., 45"),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return "Enter price";
                              if (double.tryParse(value) == null) return "Invalid price";
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _qtyController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration("Quantity Available", hint: "e.g., 20"),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return "Enter quantity";
                              if (double.tryParse(value) == null) return "Invalid qty";
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration("Your Location / Stand", hint: "e.g., Kottakkal Town / Changuvetty"),
                      validator: (value) => value == null || value.trim().isEmpty ? "Please enter location" : null,
                    ),
                    const SizedBox(height: 16),

                    // Contact Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("WhatsApp / Contact Phone", hint: "e.g., +919876543210"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return "Please enter phone number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Image URL
                    TextFormField(
                      controller: _imageController,
                      decoration: _inputDecoration("Product Image URL (Optional)", hint: "Paste an online image link"),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _inputDecoration("Listing Description", hint: "Explain details about how it was grown, harvest time, or delivery notes."),
                      validator: (value) => value == null || value.trim().isEmpty ? "Please enter description" : null,
                    ),
                    const SizedBox(height: 36),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submitHarvest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text("Submit Harvest Listing", 
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.inter(color: Colors.green[900], fontSize: 13),
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.green[800]!)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
