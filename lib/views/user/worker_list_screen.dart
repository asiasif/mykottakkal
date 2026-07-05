import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart'; // Import
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/user/worker_booking_screen.dart';

class WorkerListScreen extends StatefulWidget {
  final String category;

  const WorkerListScreen({super.key, required this.category});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _userPosition = position;
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<WorkerModel>>(
        stream: DbService().getWorkersByCategory(widget.category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading workers"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No workers available in this category"));
          }

            final workers = snapshot.data!;
          
          // Sort by distance if user location is available
          if (_userPosition != null) {
            workers.sort((a, b) {
              if (a.latitude == null || a.longitude == null) return 1; // Push no-location to bottom
              if (b.latitude == null || b.longitude == null) return -1;
              
              double distA = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, a.latitude!, a.longitude!);
              double distB = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, b.latitude!, b.longitude!);
              return distA.compareTo(distB);
            });
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              
              // Calculate distance string
              String distanceText = "";
              if (_userPosition != null && worker.latitude != null && worker.longitude != null) {
                double distMeters = Geolocator.distanceBetween(
                  _userPosition!.latitude, 
                  _userPosition!.longitude, 
                  worker.latitude!, 
                  worker.longitude!
                );
                if (distMeters < 1000) {
                  distanceText = "${distMeters.toStringAsFixed(0)} m away";
                } else {
                  distanceText = "${(distMeters / 1000).toStringAsFixed(1)} km away";
                }
              }

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12), leading: CircleAvatar(
                    backgroundImage: worker.profileImage != null ? NetworkImage(worker.profileImage!) : null,
                    radius: 28,
                    child: worker.profileImage == null ? Icon(Icons.person) : null,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(worker.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (distanceText.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[50], 
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!)
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: Colors.green),
                              SizedBox(width: 4),
                              Text(distanceText, style: TextStyle(fontSize: 10, color: Colors.green[800], fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(" ${worker.rating.toStringAsFixed(1)}", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          Spacer(),
                          if (worker.price != null)
                             Text("Starting from ₹${worker.price!.toStringAsFixed(0)}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkerBookingScreen(worker: worker),
                        ),
                      );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
