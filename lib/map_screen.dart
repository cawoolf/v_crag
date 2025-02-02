import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final markerList = await _fetchMarkersFromAssets('assets/crag_data.json');
    print('Markers fetched: ${markerList.length}');

    // Print the marker details
    for (var marker in markerList) {
      print('Marker ID: ${marker.markerId.value}');
      print('Position: ${marker.position.latitude}, ${marker.position.longitude}');
      print('Title: ${marker.infoWindow.title}');
      print('Snippet: ${marker.infoWindow.snippet}');
    }


    if (mounted) {
      setState(() => _markers = markerList);
    }
  }

  Future<Set<Marker>> _fetchMarkersFromAssets(String assetPath) async {
    try {
      // Load the JSON data from the assets using rootBundle
      final data = await rootBundle.loadString(assetPath);
      final jsonData = jsonDecode(data);

      // Check if the JSON data contains the 'crags' key
      if (jsonData is! Map || !jsonData.containsKey('crags')) {
        debugPrint('Invalid JSON format');
        return {};
      }

      // Parse the markers from the JSON
      return {
        for (var crag in jsonData['crags'] ?? [])
          if (crag['coordinates'] != null)
            Marker(
              markerId: MarkerId(crag['name']),
              position: LatLng(
                crag['coordinates']['latitude'],
                crag['coordinates']['longitude'] < 0 ? crag['coordinates']['longitude'] : -crag['coordinates']['longitude'], // Ensure longitude is negative for West
              ),
              infoWindow: InfoWindow(
                title: crag['name'],
                snippet: crag['area'],
              ),
            )
      };
    } catch (e) {
      debugPrint('Error loading markers: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map with Markers')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(40.578293, -111.738662), // Default location
          zoom: 12,
        ),
        markers: _markers,
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }
}