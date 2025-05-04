// lib/directions_service.dart
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteInfo {
  final List<LatLng> points;
  final String distanceText;
  final String durationText;

  RouteInfo({
    required this.points,
    required this.distanceText,
    required this.durationText,
  });
}

class DirectionsService {
  static Future<RouteInfo?> getRouteCoordinates({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      'http://192.168.56.1/FinalProject_Graduaction/Map/directions_proxy.php'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final leg = data['routes'][0]['legs'][0];
        final steps = leg['steps'] as List;

        List<LatLng> routePoints = [];

        for (var step in steps) {
          final encoded = step['polyline']['points'];
          final decodedStep = _decodePolyline(encoded);
          routePoints.addAll(decodedStep);
        }

        print('📍 أول نقطة: ${routePoints.first}');
        print('📍 آخر نقطة: ${routePoints.last}');

        return RouteInfo(
          points: routePoints,
          distanceText: leg['distance']['text'],
          durationText: leg['duration']['text'],
        );
      } else {
        throw Exception('Failed to fetch route');
      }
    } catch (e) {
      print('❌ Route error: $e');
      return null;
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double finalLat = lat / 1e5;
      double finalLng = lng / 1e5;

      if (finalLat.abs() <= 90 && finalLng.abs() <= 180) {
        polyline.add(LatLng(finalLat, finalLng));
      } else {
        print('⚠️ نقطة غير صالحة تم تجاهلها: $finalLat, $finalLng');
      }
    }

    return polyline;
  }
}
