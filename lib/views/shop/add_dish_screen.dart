import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:mykottakkal/models/dish_model.dart';
import 'package:mykottakkal/services/cloudinary_service.dart';
import 'package:mykottakkal/services/db_service.dart';

class AddDishScreen extends StatefulWidget {
  final String shopId;
  final String shopType;

  const AddDishScreen({super.key, required this.shopId, required this.shopType});

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedCategory = ''; // Initialize empty, set in initState
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  
  // Food Rescue Logic
  bool _isRescueItem = false;
  final TextEditingController _originalPriceController = TextEditingController();

  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _getCategoryList();
    _selectedCategory = _categories.first;
  }

  List<String> _getCategoryList() {
    switch (widget.shopType) {
      case 'Restaurant':
      case 'Cafe':
        return ['Starter', 'Main Course', 'Dessert', 'Beverage', 'Snack', 'Other'];
      case 'Grocery':
        return ['Vegetables', 'Fruits', 'Dairy', 'Snacks', 'Beverages', 'Household', 'Other'];
      case 'Fashion':
        return ['Men', 'Women', 'Kids', 'Accessories', 'Footwear', 'Other'];
      case 'Electronics':
        return ['Mobiles', 'Laptops', 'Accessories', 'Home Appliances', 'Gadgets', 'Other'];
      case 'Medical':
        return ['Medicines', 'Equipment', 'Supplements', 'Personal Care', 'Other'];
      default: // General Store or Other
        return ['General', 'Household', 'Stationery', 'Gifts', 'Other'];
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submitDish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select an image")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Image
      String? imageUrl = await CloudinaryService().uploadImage(_selectedImage!);
      if (imageUrl == null) {
        throw Exception("Image upload failed");
      }

      // 2. Create Dish Model
      final dishId = Uuid().v4();
      final dish = DishModel(
        id: dishId,
        shopId: widget.shopId,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: imageUrl,
        category: _selectedCategory,
        createdAt: DateTime.now(),
        isRescueItem: _isRescueItem,
        originalPrice: _isRescueItem && _originalPriceController.text.isNotEmpty ? double.parse(_originalPriceController.text) : null,
      );

      // 3. Save to DB
      await DbService().addDish(dish);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dish added successfully!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding dish: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopType == 'Restaurant' || widget.shopType == 'Cafe' ? "Add New Dish" : "Add New Product", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                    image: _imageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_imageBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(widget.shopType == 'Restaurant' || widget.shopType == 'Cafe' ? "Tap to add dish image" : "Tap to add product image"),
                          ],
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: widget.shopType == 'Restaurant' || widget.shopType == 'Cafe' ? "Dish Name" : "Product Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (value) => value!.isEmpty ? "Please enter dish name" : null,
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text("Put on Food Rescue? (Happy Hour)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
                subtitle: Text("Items will be listed at 50% OFF to reduce waste.", style: TextStyle(fontSize: 12)),
                value: _isRescueItem,
                activeColor: Colors.orange,
                onChanged: (val) {
                   setState(() {
                      _isRescueItem = val;
                      if (!val) {
                         _originalPriceController.clear();
                         _priceController.clear(); // Reset if off
                      }
                   });
                }
              ),
              if (_isRescueItem) ...[
                 SizedBox(height: 16),
                 TextFormField(
                    controller: _originalPriceController,
                    decoration: InputDecoration(
                       labelText: "Original Price",
                       border: OutlineInputBorder(),
                       prefixIcon: Icon(Icons.money_off, color: Colors.grey),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                       if (val.isNotEmpty) {
                          double original = double.tryParse(val) ?? 0;
                          _priceController.text = (original / 2).toStringAsFixed(0); // Auto 50% OFF
                       }
                    },
                 ),
              ],
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                readOnly: _isRescueItem, // Read only if rescue mode
                decoration: InputDecoration(
                  labelText: _isRescueItem ? "Selling Price (50% OFF)" : "Price",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                  fillColor: _isRescueItem ? Colors.orange[50] : null,
                  filled: _isRescueItem
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Please enter price" : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? "Please enter description" : null,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitDish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(widget.shopType == 'Restaurant' || widget.shopType == 'Cafe' ? "Add Dish" : "Add Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
