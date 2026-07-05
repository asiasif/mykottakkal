import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/shop_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ArShopScreen extends StatefulWidget {
  const ArShopScreen({super.key});

  @override
  State<ArShopScreen> createState() => _ArShopScreenState();
}

class _ArShopScreenState extends State<ArShopScreen> {
  CameraController? _cameraController;
  List<ShopModel> _nearbyShops = [];
  Position? _currentPosition;
  double _heading = 0.0;
  bool _isLoading = true;
  String _statusMessage = "Initializing AR...";

  @override
  void initState() {
    super.initState();
    _initializeAR();
  }

  Future<void> _initializeAR() async {
    // 1. Permissions
    await [Permission.camera, Permission.location].request();

    // 2. Camera Setup
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
        await _cameraController!.initialize();
      }
    } catch (e) {
      setState(() => _statusMessage = "Camera Error: $e");
    }

    // 3. Location & Compass
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      
      // Listen to compass
      FlutterCompass.events?.listen((event) {
        if (mounted) {
          setState(() {
            _heading = event.heading ?? 0.0;
          });
        }
      });
      
      // 4. Fetch Shops
      await _fetchNearbyShops();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _statusMessage = "Sensor Error: $e");
    }
  }

  Future<void> _fetchNearbyShops() async {
    if (_currentPosition == null) return;
    
    // In a real app, use GeoFlutterFire. Here we filter locally for demo.
    final shops = await DbService().getApprovedShops().first;
    List<ShopModel> near = [];
    
    for (var shop in shops) {
       // Mock logic if lat/lng missing, assigning random nearby spots for demo
       double lat = 10.9994; // Kottakkal Center
       double lng = 75.9961;
       
       // Calc distance
       double dist = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, lat, lng);
       
       // If < 2km, add to AR
       if (dist < 2000) { 
         near.add(shop);
       }
    }
    setState(() => _nearbyShops = shops); // Showing ALL for demo purposes so user sees something
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(backgroundColor: Colors.black, body: Center(child: Text(_statusMessage, style: TextStyle(color: Colors.white))));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Feed
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!)
          else
            Container(color: Colors.black, child: Center(child: Text("Camera Failed"))),

          // 2. AR Overlay
          ..._nearbyShops.map((shop) => _buildArMarker(shop)).toList(),

          // 3. HUD
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Spacer(),
                _buildCompass(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildArMarker(ShopModel shop) {
    if (_currentPosition == null) return SizedBox();

    // Mock Location for each shop to spread them out
    double shopLat = 10.9994 + (shop.shopName.length * 0.0001); 
    double shopLng = 75.9961 + (shop.shopName.length * 0.0001);

    // Calculate Bearing
    double bearing = Geolocator.bearingBetween(
      _currentPosition!.latitude, _currentPosition!.longitude, 
      shopLat, shopLng
    );
    
    double dist = Geolocator.distanceBetween(
      _currentPosition!.latitude, _currentPosition!.longitude, 
      shopLat, shopLng
    );

    // Calculate Angle Difference relative to Phone Heading
    // Normalizing to -180 to 180
    double diff = bearing - _heading;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    // Field of View (FOV) ~60 degrees (approx 30 left, 30 right)
    if (diff.abs() > 40) return SizedBox(); // Out of view

    // Map Angle to Screen X Coordinate
    // 0 deg = Center (Width/2)
    // -30 deg = Left (0)
    // +30 deg = Right (Width)
    double screenWidth = MediaQuery.of(context).size.width;
    double xPos = (screenWidth / 2) + (diff * (screenWidth / 60));

    return Positioned(
      top: 250, // Fixed vertical line for now (horizon)
      left: xPos - 60, // Center widget
      child: GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Navigating to ${shop.shopName}"))),
        child: Column(
          children: [
            Container(
              width: 120,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2)
              ),
              child: Column(
                children: [
                  Text(shop.shopName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${dist.toInt()}m away", style: TextStyle(fontSize: 10, color: Colors.grey[800])),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.star, size: 12, color: Colors.amber), Text("4.5")])
                ],
              ),
            ),
            Container(height: 30, width: 2, color: Colors.green),
            CircleAvatar(radius: 5, backgroundColor: Colors.green)
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
     return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.black45,
        child: Row(
          children: [
            BackButton(color: Colors.white),
            Text("Real AR View", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Spacer(),
            Text("${_heading.toInt()}° N", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)) 
          ],
        ),
     );
  }

  Widget _buildCompass() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      height: 50,
      width: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white)),
      child: Transform.rotate(
        angle: ((_heading ?? 0) * (pi / 180) * -1),
        child: Icon(Icons.navigation, color: Colors.redAccent),
      ),
    );
  }
}
