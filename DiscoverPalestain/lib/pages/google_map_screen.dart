import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/directions_service.dart';
import 'package:flutter_application_1/pages/places_search_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:location/location.dart';



class PlacesMapScreen extends StatefulWidget {
  @override
  _PlacesMapScreenState createState() => _PlacesMapScreenState();
}

class _PlacesMapScreenState extends State<PlacesMapScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  TextEditingController _searchController = TextEditingController();
  final LatLng _initialCenter = const LatLng(31.9029, 35.1959);
  List<dynamic> _suggestions = [];
  bool _isSearching = false;
  String? _routeDistance;
  String? _routeDuration;
  String _selectedType = 'restaurant'; 


  String get currentLang => ui.window.locale.languageCode;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) return;
    }

    if (await location.hasPermission() == PermissionStatus.denied) {
      if (await location.requestPermission() != PermissionStatus.granted) return;
    }

    final current = await location.getLocation();
    final userMarker = Marker(
      markerId: MarkerId('user_location'),
      position: LatLng(current.latitude!, current.longitude!),
      infoWindow: InfoWindow(title: 'My Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      _markers.add(userMarker);
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(current.latitude!, current.longitude!), 14),
    );
  }

  Future<void> _searchFromGooglePlaces() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final url = Uri.parse('http://localhost/FinalProject_Graduaction/Map/search_google_place.php?query=${Uri.encodeComponent(query)}&lang=$currentLang');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] != 'OK') return;

      final result = data['results'].first;
      final lat = result['geometry']['location']['lat'];
      final lng = result['geometry']['location']['lng'];
      final name = result['name'];
      final address = result['formatted_address'];
      final types = result['types'];

      final marker = _buildMarkerWithRoute(lat, lng, name, address, types);

      setState(() {
        _polylines.clear();
        _markers.removeWhere((m) => m.markerId.value != 'user_location');

        _markers.add(marker);
      });

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
      );
    } catch (e) {
      print('❌ Exception during Google Places search: $e');
    }
  }

  Marker _buildMarkerWithRoute(double lat, double lng, String name, String address, List types) {
    return Marker(
      markerId: MarkerId('search_result_${DateTime.now().millisecondsSinceEpoch}'),
      position: LatLng(lat, lng),
    infoWindow: InfoWindow(
  title: _buildTitleWithEmoji(name, types),
  snippet: '🔴Click here to view the route from your location,',
  onTap: () {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListTile(
        title: Text(name),
        subtitle: Text('view the route from your location'),
        trailing: Icon(Icons.directions),
        onTap: () async {
          Navigator.pop(context);
                try {
                  Location location = Location();
                  final current = await location.getLocation();
                  final origin = LatLng(current.latitude!, current.longitude!);
                  final destination = LatLng(lat, lng);

                  final routeInfo = await DirectionsService.getRouteCoordinates(
  origin: origin,
  destination: destination,
);

if (routeInfo != null && routeInfo.points.isNotEmpty) {
  setState(() {
    _polylines = {
      Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: routeInfo.points,
      ),
    };
    _routeDistance = routeInfo.distanceText;
    _routeDuration = routeInfo.durationText;
  });

  mapController.animateCamera(
    CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(
          origin.latitude < destination.latitude ? origin.latitude : destination.latitude,
          origin.longitude < destination.longitude ? origin.longitude : destination.longitude,
        ),
        northeast: LatLng(
          origin.latitude > destination.latitude ? origin.latitude : destination.latitude,
          origin.longitude > destination.longitude ? origin.longitude : destination.longitude,
        ),
      ),
      80,
    ),
  );
}

                } catch (e) {
                  print('❌ Error drawing route: $e');
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _getAutocompleteSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final url = Uri.parse('http://localhost/FinalProject_Graduaction/Map/google_autocomplete.php?query=${Uri.encodeComponent(input)}&lang=$currentLang');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        setState(() {
          _suggestions = data['predictions'];
        });
      }
    } catch (e) {
      print('❌ Error in autocomplete: $e');
    }
  }

  Future<void> _handleSuggestionTap(String placeId) async {
    setState(() {
      _isSearching = false;
      _suggestions = [];
    });

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&language=$currentLang&key=AIzaSyB0GYavMZwz5pTgE50M8tpW8C_qguDALTA',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final result = data['result'];
        final lat = result['geometry']['location']['lat'];
        final lng = result['geometry']['location']['lng'];
        final name = result['name'];
        final address = result['formatted_address'];
        final types = result['types'];

        final marker = _buildMarkerWithRoute(lat, lng, name, address, types);

        setState(() {
          _markers.removeWhere((m) => m.markerId.value != 'user_location');

          _polylines.clear();
          _markers.add(marker);
        });

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
        );
      }
    } catch (e) {
      print('❌ Error fetching details: $e');
    }
  }

  String _buildTitleWithEmoji(String name, List types) {
    String emoji = '📍';
    if (types.contains('restaurant')) emoji = '🍽️';
    else if (types.contains('lodging')) emoji = '🏨';
    else if (types.contains('locality')) emoji = '🏙️';
    else if (types.contains('mosque')) emoji = '🕌';
    else if (types.contains('university')) emoji = '🎓';
    else if (types.contains('hospital')) emoji = '🏥';
    return '$emoji $name';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places in Palestine'),
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _getAutocompleteSuggestions,
                    onTap: () => setState(() => _isSearching = true),
                    decoration: InputDecoration(
                      hintText: 'Search For Place...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchFromGooglePlaces,
                  child: Icon(Icons.search),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
body: Stack(
  children: [
    GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(target: _initialCenter, zoom: 10.5),
      markers: _markers,
      polylines: _polylines,
    ),
    // زر تحديد الموقع
    Positioned(
      top: 16,
      right: 16,
      child: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    ),
    // ✅ زر إلغاء المسار
      if (_routeDistance != null && _routeDuration != null)
  Positioned(
    top: 140,
    left: 16,
    right: 16,
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.teal),
              SizedBox(width: 4),
              Text(_routeDuration!),
            ],
          ),
          Row(
            children: [
              Icon(Icons.route, color: Colors.teal),
              SizedBox(width: 4),
              Text(_routeDistance!),
            ],
          ),
        ],
      ),
    ),
  ),
  Positioned(
  top: 60,
  left: 16,
  child: Row(
    children: [
      _buildFilterButton('restaurant', '🍽️ Restaurant'),
      SizedBox(width: 8),
      _buildFilterButton('lodging', '🛏️ Hotel'),
    ],
  ),
),


    // الاقتراحات
    if (_isSearching && _suggestions.isNotEmpty)
      Positioned(
        top: 110,
        left: 10,
        right: 10,
        child: Card(
          elevation: 4,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return ListTile(
                title: Text(suggestion['description']),
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  _searchController.text = suggestion['description'];
                  await _handleSuggestionTap(suggestion['place_id']);
                },
              );
            },
          ),
        ),
      ),
      Positioned(
  top: 80,
  right: 16,
  child: Column(
    children: [
      if (_markers.length > 1)
        FloatingActionButton(
          mini: true,
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          onPressed: () {
            setState(() {
              _markers.removeWhere((m) => m.markerId.value != 'user_location');
              _polylines.clear();
              _routeDistance = null;
              _routeDuration = null;
            });
          },
          child: Icon(Icons.close),
          tooltip: 'إلغاء نتائج الفلترة',
        ),
      SizedBox(height: 8),
      if (_polylines.isNotEmpty)
        FloatingActionButton(
          mini: true,
          backgroundColor: Colors.red,
          onPressed: () {
            setState(() {
              _polylines.clear();
              _routeDistance = null;
              _routeDuration = null;
            });
          },
          child: Icon(Icons.close),
          tooltip: 'إلغاء المسار',
        ),
    ],
  ),
),

  ],
)
,
    );
  }
  
Widget _buildFilterButton(String type, String label) {
  final isSelected = _selectedType == type;

  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: isSelected ? Colors.teal : Colors.white,
      foregroundColor: isSelected ? Colors.white : Colors.black,
      shape: StadiumBorder(),
      elevation: 3,
    ),
    onPressed: () async {
      setState(() {
        _selectedType = type;
      });

      final query = _searchController.text.trim();
      if (query.isEmpty) return;

      final places = await PlacesSearchService.searchPlacesByType(
        query: query,
        type: _selectedType,
        lang: currentLang,
      );

      Set<Marker> newMarkers = {};

      //  أضف ماركرات الأماكن المفلترة
      for (var place in places) {
        newMarkers.add(Marker(
  markerId: MarkerId(place.name),
  position: LatLng(place.lat, place.lng),
  infoWindow: InfoWindow(
    title: _buildTitleWithEmoji(place.name, [type]),
    snippet: '🔴Click here to view the route from your location',
    onTap: () {
      showModalBottomSheet(
        context: context,
        builder: (_) => ListTile(
          title: Text(place.name),
          subtitle: Text('view the route from your location'),
          trailing: Icon(Icons.directions),
          onTap: () async {
            Navigator.pop(context);
            try {
              Location location = Location();
              final current = await location.getLocation();
              final origin = LatLng(current.latitude!, current.longitude!);
              final destination = LatLng(place.lat, place.lng);

              final routeInfo = await DirectionsService.getRouteCoordinates(
                origin: origin,
                destination: destination,
              );

              if (routeInfo != null && routeInfo.points.isNotEmpty) {
                setState(() {
                  _polylines = {
                    Polyline(
                      polylineId: PolylineId('route'),
                      color: Colors.blue,
                      width: 5,
                      points: routeInfo.points,
                    ),
                  };
                  _routeDistance = routeInfo.distanceText;
                  _routeDuration = routeInfo.durationText;
                });

                mapController.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: LatLng(
                        origin.latitude < destination.latitude ? origin.latitude : destination.latitude,
                        origin.longitude < destination.longitude ? origin.longitude : destination.longitude,
                      ),
                      northeast: LatLng(
                        origin.latitude > destination.latitude ? origin.latitude : destination.latitude,
                        origin.longitude > destination.longitude ? origin.longitude : destination.longitude,
                      ),
                    ),
                    80,
                  ),
                );
              }
            } catch (e) {
              print('❌ Error drawing route (filtered): $e');
            }
          },
        ),
      );
    },
  ),
));

      }

      // ✅ أضف ماركر المستخدم
      Location location = Location();
      final current = await location.getLocation();
      final userMarker = Marker(
        markerId: MarkerId('user_location'),
        position: LatLng(current.latitude!, current.longitude!),
        infoWindow: InfoWindow(title: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      newMarkers.add(userMarker);

      // ✅ عدل الحالة
      setState(() {
        _markers = newMarkers;
        _polylines.clear();
        _routeDistance = null;
        _routeDuration = null;
      });

      if (places.isNotEmpty) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(places[0].lat, places[0].lng), 13),
        );
      }
    },
    child: Text(label),
  );
}

}
