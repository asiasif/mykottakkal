import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/tourism_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/tourism/translator_screen.dart';

class TourismScreen extends StatelessWidget {
  const TourismScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Visit Kottakkal", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<List<TourismModel>>(
        stream: DbService().getPlaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.camera_alt, size: 60, color: Colors.grey[300]),
                   SizedBox(height: 16),
                   Text("No places added yet.", style: TextStyle(color: Colors.grey[500])),
                 ],
               ),
             );
          }

          final places = snapshot.data!;
          return ListView.separated(
            padding: EdgeInsets.all(20),
            itemCount: places.length,
            separatorBuilder: (c, i) => SizedBox(height: 24),
            itemBuilder: (context, index) {
              final place = places[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(place.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place.name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.teal),
                              SizedBox(width: 4),
                              Text(place.location, style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(place.description, style: TextStyle(color: Colors.grey[800], height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal[800],
        onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => TranslatorScreen()));
        },
        icon: Icon(Icons.translate, color: Colors.white),
        label: Text("Ayur-Translator", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
