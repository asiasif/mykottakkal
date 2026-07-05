import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/user/worker_booking_screen.dart';
import 'package:mykottakkal/views/ar/ar_shop_screen.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Position? _currentPosition;

  // Kottakkal Coordinates as default
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.9994, 75.9961), 
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadWorkerMarkers();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  Future<void> _loadWorkerMarkers() async {
    // Fetch all workers from DB
    // Note: In a real app with many users, you'd use GeoFlutterFire or server-side filtering.
    final workers = await DbService().getAllWorkers().first; 
    
    setState(() {
      _markers.clear();
      for (var worker in workers) {
        // If worker has no location, we skip (or put them at a default/random spot for demo)
        if (worker.latitude != null && worker.longitude != null) {
             _addMarker(worker);
        } else {
             // FOR DEMO: Simulate random locations around Kottakkal if data is missing
            //  double offsetLat = (workers.indexOf(worker) * 0.001);
            //  double offsetLng = (workers.indexOf(worker) * 0.001);
            //  _addMarker(worker, lat: 10.9994 + offsetLat, lng: 75.9961 + offsetLng);
        }
      }
    });
  }

  void _addMarker(WorkerModel worker, {double? lat, double? lng}) {
    final position = LatLng(lat ?? worker.latitude!, lng ?? worker.longitude!);
    
    _markers.add(
      Marker(
        markerId: MarkerId(worker.uid),
        position: position,
        infoWindow: InfoWindow(
          title: worker.name,
          snippet: worker.category,
          onTap: () {
            // Navigate to booking on info window tap
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => WorkerBookingScreen(worker: worker))
            );
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Workers Near Me"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.green[800]),
              onPressed: () {
                if (_currentPosition != null && _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    ),
                  );
                } else {
                  _determinePosition();
                }
              },
            ),
          ),
          Positioned(
            bottom: 90,
            right: 20, 
            child: FloatingActionButton.extended(
              heroTag: 'ar_btn',
              backgroundColor: Colors.white,
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => ArShopScreen()));
              },
              icon: Icon(Icons.view_in_ar, color: Colors.blue[800]),
              label: Text("AR View", style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
