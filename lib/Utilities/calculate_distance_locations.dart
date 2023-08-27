import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class calculateDistance extends StatefulWidget {
  calculateDistance({super.key, required this.userLocation, required this.pollingUnitLocation});

  LatLng userLocation;
  LatLng pollingUnitLocation;

  double degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  double calculateLocationDistance() {
    const double radius = 6371.0; // Earth's radius in kilometers
    final double lat1 = degreesToRadians(userLocation.latitude);
    final double lon1 = degreesToRadians(userLocation.longitude);
    final double lat2 = degreesToRadians(pollingUnitLocation.latitude);
    final double lon2 = degreesToRadians(pollingUnitLocation.longitude);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    final double distance = radius * c; // Distance in kilometers

    return distance;
  }

  @override
  State<calculateDistance> createState() => _calculateDistanceState();
}

class _calculateDistanceState extends State<calculateDistance> {

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
