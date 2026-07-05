import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/shop_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mykottakkal/views/shop/shop_details_screen.dart'; // Import ShopDetailsScreen

class ShopCategoriesScreen extends StatelessWidget {
  const ShopCategoriesScreen({super.key});

  final List<String> categories = const ['Restaurant', 'Cafe', 'Grocery', 'Fashion', 'Electronics', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kottakkal Shops", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
         backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ShopListScreen(category: category)));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(getCategoryIcon(category), size: 40, color: Color(0xFF2E7D32)),
                   SizedBox(height: 12),
                   Text(category, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Restaurant': return Icons.restaurant;
      case 'Cafe': return Icons.local_cafe;
      case 'Grocery': return Icons.shopping_basket;
      case 'Fashion': return Icons.checkroom;
      case 'Electronics': return Icons.devices;
      default: return Icons.store;
    }
  }
}

class ShopListScreen extends StatelessWidget {
  final String category;
  const ShopListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category), backgroundColor: Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: StreamBuilder<List<ShopModel>>(
        stream: DbService().getShopsByCategory(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No shops found in this category."));

          final shops = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailsScreen(shop: shop)));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (shop.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(shop.imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(shop.shopName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                                ),
                                if (shop.logoUrl != null)
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(shop.logoUrl!),
                                    backgroundColor: Colors.transparent,
                                  ),
                                if (shop.deliveryAvailable && shop.logoUrl == null) // Show delivery tag if no logo, or maybe beside?
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                                    child: Text("Delivery", style: TextStyle(color: Colors.green[800], fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            if (shop.deliveryAvailable && shop.logoUrl != null) 
                               Padding(
                                 padding: const EdgeInsets.only(top: 4.0),
                                 child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                                    child: Text("Delivery Available", style: TextStyle(color: Colors.green[800], fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                               ),
                            SizedBox(height: 4),
                            Text(shop.address, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            if (shop.description.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text(shop.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                       Navigator.push(context, MaterialPageRoute(builder: (_) => ShopDetailsScreen(shop: shop)));
                                    },
                                    icon: Icon(Icons.restaurant_menu, size: 16),
                                    label: Text("View Menu"),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // Make call
                                      launchUrl(Uri.parse("tel:${shop.mobile}"));
                                    },
                                    icon: Icon(Icons.call, size: 16),
                                    label: Text("Call"),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
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
}
