import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/models/ad_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/classifieds/post_ad_screen.dart';
import 'package:mykottakkal/views/classifieds/ad_detail_screen.dart';

class ClassifiedsHomeScreen extends StatefulWidget {
  const ClassifiedsHomeScreen({super.key});

  @override
  State<ClassifiedsHomeScreen> createState() => _ClassifiedsHomeScreenState();
}

class _ClassifiedsHomeScreenState extends State<ClassifiedsHomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<String> _categories = ['All', 'Vehicles', 'Electronics', 'Furniture', 'Others'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Kottakkal Market", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for items...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Category Selector
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.grey[100],
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.transparent)),
                  ),
                );
              },
            ),
          ),

          // Ad Grid
          Expanded(
            child: StreamBuilder<List<AdModel>>(
              stream: DbService().getAds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.storefront, size: 60, color: Colors.grey[300]),
                         SizedBox(height: 16),
                         Text("No items for sale yet.", style: TextStyle(color: Colors.grey[500])),
                       ],
                     ),
                   );
                }

                var ads = snapshot.data!;
                
                // Filter by Category
                if (_selectedCategory != 'All') {
                  ads = ads.where((ad) => ad.category == _selectedCategory).toList();
                }

                // Filter by Search Query
                if (_searchQuery.isNotEmpty) {
                  ads = ads.where((ad) => 
                      ad.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                      ad.description.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (ads.isEmpty) {
                    return Center(child: Text("No items found matching '$_searchQuery'", style: TextStyle(color: Colors.grey)));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdDetailScreen(ad: ad))),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  image: DecorationImage(image: NetworkImage(ad.imageUrl), fit: BoxFit.cover),
                                  color: Colors.grey[200]
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("₹ ${ad.price.toStringAsFixed(0)}", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
                                  SizedBox(height: 4),
                                  Text(ad.title, style: TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: 4),
                                  Text(ad.category, style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please login to sell items")));
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => PostAdScreen()));
        },
        backgroundColor: Colors.black,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Sell Item", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
