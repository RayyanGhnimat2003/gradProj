import 'dart:convert';
import 'package:http/http.dart' as http;

class Place {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final List types;

  Place({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.types,
  });
}

class PlacesSearchService {
  static Future<List<Place>> searchPlacesByType({
    required String query,
    required String type,
    required String lang,
  }) async {
    final url = Uri.parse(
      'http://localhost/FinalProject_Graduaction/Map/search_google_place.php?query=${Uri.encodeComponent(query)}&type=$type&lang=$lang',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] != 'OK') return [];

      final results = data['results'] as List;

      return results.map((place) {
        final location = place['geometry']['location'];
        return Place(
          name: place['name'],
          address: place['formatted_address'] ?? '',
          lat: location['lat'],
          lng: location['lng'],
          types: place['types'] ?? [],
        );
      }).toList();
    } catch (e) {
      print('❌ Error searching places: $e');
      return [];
    }
  }
}
