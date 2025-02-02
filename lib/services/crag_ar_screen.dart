import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../model/carg.dart';

class CragsARScreen extends StatefulWidget {
  @override
  _CragsARScreenState createState() => _CragsARScreenState();
}

class _CragsARScreenState extends State<CragsARScreen> {
  late ArCoreController arCoreController;
  late Position userPosition;
  bool isLocationFetched = false;

  // Example JSON data for crags
  List<Crag> crags = [
    Crag(
      name: "Rock Climbing in Above and Beyond Wall, Big Cottonwood Canyon",
      area: "Big Cottonwood Canyon",
      latitude: 40.635,
      longitude: 111.717,
    ),
    Crag(
      name: "Rock Climbing in Aguaworld, Big Cottonwood Canyon",
      area: "Big Cottonwood Canyon",
      latitude: 40.622,
      longitude: 111.777,
    ),
  ];

  // Fetch user's current location.. Updated this with
  // https://pub.dev/packages/geolocator/example
  Future<void> getCurrentLocation() async {
    try {
      userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        isLocationFetched = true;
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  // Calculate the distance between two locations
  double calculateDistance(Position userPosition, double latitude, double longitude) {
    return Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      latitude,
      longitude,
    );
  }

  // Add AR nodes for each crag location
  void _addLocationToAR(ArCoreController controller, double latitude, double longitude) {
    final material = ArCoreMaterial(color: Colors.red);  // Correcting the material

    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1,  // Adjust the size
    );

    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0.0, 0.0, -1.0),  // Adjust based on your location
    );

    controller.addArCoreNode(node);
  }

  // Set up ARCore controller
  void _onARViewCreated(ArCoreController controller) {
    arCoreController = controller;

    // Display locations and distances once location is fetched
    if (isLocationFetched) {
      for (var crag in crags) {
        double distance = calculateDistance(userPosition, crag.latitude, crag.longitude);
        print('Distance to ${crag.name}: $distance meters');

        // Add the crag location to AR view
        _addLocationToAR(arCoreController, crag.latitude, crag.longitude);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crags AR'),
      ),
      body: Stack(
        children: [
          // ARCore view to render the AR scene
          ArCoreView(
            onArCoreViewCreated: _onARViewCreated,
          ),
          // A simple text overlay to display status
          if (!isLocationFetched)
            Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}

