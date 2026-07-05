import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mykottakkal/models/dish_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/shop/add_dish_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ManageMenuScreen extends StatelessWidget {
  final String shopId;
  final String shopType;

  const ManageMenuScreen({super.key, required this.shopId, required this.shopType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(shopType == 'Restaurant' || shopType == 'Cafe' ? "Manage Menu" : "Manage Products", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: "scan",
              onPressed: () => _scanMenu(context),
              label: Text("Scan Menu"),
              icon: Icon(Icons.camera_alt),
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
            SizedBox(width: 16),
            FloatingActionButton.extended(
              heroTag: "add",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddDishScreen(shopId: shopId, shopType: shopType)));
              },
              label: Text("Add Manual"),
              icon: Icon(Icons.add),
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<DishModel>>(
        stream: DbService().getDishesByShop(shopId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(shopType == 'Restaurant' || shopType == 'Cafe' ? Icons.restaurant_menu : Icons.inventory_2, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(shopType == 'Restaurant' || shopType == 'Cafe' ? "No dishes added yet." : "No products added yet.", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }

          final dishes = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: dishes.length,
            itemBuilder: (context, index) {
              final dish = dishes[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: dish.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[300]),
                          errorWidget: (context, url, error) => Icon(Icons.broken_image),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dish.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("₹${dish.price.toStringAsFixed(0)}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Text(dish.category, style: TextStyle(fontSize: 12, color: Colors.grey)),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Switch(
                                  value: dish.isAvailable,
                                  onChanged: (value) {
                                    final updatedDish = DishModel(
                                      id: dish.id,
                                      shopId: dish.shopId,
                                      name: dish.name,
                                      description: dish.description,
                                      price: dish.price,
                                      imageUrl: dish.imageUrl,
                                      category: dish.category,
                                      isAvailable: value,
                                      createdAt: dish.createdAt,
                                    );
                                    DbService().updateDish(updatedDish);
                                  },
                                  activeColor: Color(0xFF2E7D32),
                                ),
                                Text(dish.isAvailable ? "Available" : "Unavailable", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Delete Dish?"),
                              content: Text("Are you sure you want to delete ${dish.name}?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                                TextButton(
                                  onPressed: () {
                                    DbService().deleteDish(dish.id);
                                    Navigator.pop(context);
                                  },
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _scanMenu(BuildContext context) async {
    // 1. Pick Image (Mock)
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    // 2. Show Loading "OCR Processing"
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 16),
              Text("Scanning Menu...", style: GoogleFonts.outfit(fontSize: 16)),
              Text("Extracting dishes & prices", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );

    // 3. Mock OCR Service Delay
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context); // Close loader

    // 4. Mock Detected Data
    final List<Map<String, dynamic>> detectedDishes = [
      {'name': 'Chicken Biryani', 'price': 180.0, 'desc': 'Kottakkal Special Dum Biryani'},
      {'name': 'Beef Roast', 'price': 150.0, 'desc': 'Spicy Kerala Style Beef'},
      {'name': 'Porotta', 'price': 15.0, 'desc': 'Flaky Layered Bread'},
      {'name': 'Lime Juice', 'price': 20.0, 'desc': 'Fresh Lime'},
    ];

    // 5. Show Review Dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detected ${detectedDishes.length} Items", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: detectedDishes.length,
            itemBuilder: (context, index) {
              final item = detectedDishes[index];
              return ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text(item['name']),
                subtitle: Text(item['desc']),
                trailing: Text("₹${item['price']}", style: TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Add all to DB
              for (var item in detectedDishes) {
                 final dish = DishModel(
                    id: Uuid().v4(),
                    shopId: shopId,
                    name: item['name'],
                    description: item['desc'],
                    price: item['price'],
                    imageUrl: "https://res.cloudinary.com/dnumx9k2i/image/upload/v1738781575/biriyani_t8x8gq.jpg", // Placeholder food image
                    category: "Main Course",
                    createdAt: DateTime.now(),
                 );
                 await DbService().addDish(dish);
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Menu items added successfully!"), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800], foregroundColor: Colors.white),
            child: Text("Add All to Menu"),
          )
        ],
      ),
    );
  }
}
