import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/rental_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/rentals/post_rental_screen.dart';
import 'package:mykottakkal/views/rentals/rental_detail_screen.dart';

class RentalsHomeScreen extends StatefulWidget {
  const RentalsHomeScreen({super.key});

  @override
  State<RentalsHomeScreen> createState() => _RentalsHomeScreenState();
}

class _RentalsHomeScreenState extends State<RentalsHomeScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'House', 'Shop', 'Vehicle', 'Equipment'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: Text("Rentals & Leases", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Categories Filter
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo[900] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        cat, 
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<RentalModel>>(
              stream: DbService().getRentals(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.house_siding, size: 60, color: Colors.grey[300]),
                         SizedBox(height: 16),
                         Text("No rentals available.", style: TextStyle(color: Colors.grey[500])),
                       ],
                     ),
                   );
                }

                final rentals = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: rentals.length,
                  itemBuilder: (context, index) {
                    final rental = rentals[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RentalDetailScreen(rental: rental))),
                      child: Card(
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                rental.imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(height: 180, color: Colors.grey[300], child: Icon(Icons.broken_image)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(4)),
                                        child: Text(rental.category.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                      ),
                                      Text(
                                        "₹${rental.price.toStringAsFixed(0)} / mo", // Basic assumption
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(rental.title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 14, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Expanded(child: Text(rental.location, style: TextStyle(color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
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
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostRentalScreen())),
        label: Text("Post Rental", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo[900],
      ),
    );
  }
}
