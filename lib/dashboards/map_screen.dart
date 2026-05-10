import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // The Engine
import 'package:latlong2/latlong.dart'; // Coordinates
import 'theme.dart';
import 'package:geocoding/geocoding.dart'; // To find cities

class MapScreen extends StatefulWidget {
  final String cityName;
  final LatLng? location; // Optional specific location

  const MapScreen({super.key, required this.cityName, this.location});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(20.5937, 78.9629); // Default India
  List<Marker> _markers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      // 1. Find the City Coordinates
      List<Location> locations = await locationFromAddress(widget.cityName);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _center = LatLng(loc.latitude, loc.longitude);
        
        // 2. Generate Smart Markers (Simulated for Demo)
        // In a real app, Gemini would give us exact lat/lng for these spots
        _markers = [
          _buildMarker(_center, Icons.star, Colors.amber, "City Center"),
          _buildMarker(LatLng(_center.latitude + 0.01, _center.longitude + 0.01), Icons.hotel, Colors.blue, "Your Hotel"),
          _buildMarker(LatLng(_center.latitude - 0.015, _center.longitude - 0.005), Icons.local_dining, Colors.red, "Top Restaurant"),
          _buildMarker(LatLng(_center.latitude + 0.005, _center.longitude - 0.01), Icons.camera_alt, Colors.purple, "Photo Spot"),
        ];
      }
    } catch (e) {
      debugPrint("Map Error: $e");
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Marker _buildMarker(LatLng point, IconData icon, Color color, String label) {
    return Marker(
      point: point,
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. THE MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.0,
            ),
            children: [
              // Dark Mode Tiles (Sci-Fi Look)
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.example.travel_ai',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // 2. HEADER
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                child: Text("Exploring ${widget.cityName}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          // 3. LOADING INDICATOR
          if (_isLoading)
            Container(
              color: Colors.black87,
              child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            ),

          // 4. BOTTOM CONTROLS
          Positioned(
            bottom: 40,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom_in",
                  backgroundColor: AppColors.surface,
                  onPressed: () => _mapController.move(_center, _mapController.camera.zoom + 1),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "zoom_out",
                  backgroundColor: AppColors.surface,
                  onPressed: () => _mapController.move(_center, _mapController.camera.zoom - 1),
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "center",
                  backgroundColor: AppColors.accent,
                  onPressed: () => _mapController.move(_center, 13.0),
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}