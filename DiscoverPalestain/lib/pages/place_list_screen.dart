import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/AddPlaceScreen.dart';
import 'package:flutter_application_1/pages/Place.dart';
import 'package:flutter_application_1/pages/place_card.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PlaceListScreen extends StatefulWidget {
  final int cityId;

  PlaceListScreen({required this.cityId});

  @override
  _PlaceListScreenState createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  List<Place> places = [];
  List<Place> filteredPlaces = [];
  bool isLoading = true;
  bool hasError = false;
  String _sortOption = 'Name';
  TextEditingController searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchPlaces();
    _speech = stt.SpeechToText();
  }

  Future<void> fetchPlaces() async {
    try {
      final response = await http.get(Uri.parse(
          "http://192.168.1.141/FinalProject_Graduaction/City/getPlaces.php?city_id=${widget.cityId}"));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        if (jsonResponse.isEmpty) {
          setState(() {
            isLoading = false;
            places = [];
            filteredPlaces = [];
          });
          return;
        }

        List<Place> placeList = jsonResponse.map<Place>((data) {
          double latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
          double longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;
          return Place.fromMap({
            ...data,
            'latitude': latitude,
            'longitude': longitude,
          });
        }).toList();

        setState(() {
          places = placeList;
          filteredPlaces = placeList;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load places");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // تعديل الفلترة بحيث تتم بناءً على الاسم أو الصنف فقط (بدون عرض قائمة)
  void filterPlaces(String query) {
    String lowerQuery = query.toLowerCase();

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () {
      List<Place> filteredList = places.where((place) {
        return place.name.toLowerCase().startsWith(lowerQuery) ||
               place.category.toLowerCase().startsWith(lowerQuery); // فلترة بناءً على أول حرف
      }).toList();

      setState(() {
        filteredPlaces = filteredList;
      });
    });
  }

  void applySorting(List<Place> list) {
    if (_sortOption == 'Name') {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_sortOption == 'Area') {
      list.sort((a, b) => a.area.toLowerCase().compareTo(b.area.toLowerCase()));
    }

    setState(() => filteredPlaces = list);
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            searchController.text = val.recognizedWords;
            filterPlaces(val.recognizedWords);  // فلترة بناءً على ما يتم التعرف عليه صوتيًا
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places in City'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: filterPlaces,
                        decoration: InputDecoration(
                          labelText: 'Search Places (by name or category)',
                          prefixIcon: Icon(Icons.search, color: Colors.teal),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic_off : Icons.mic,
                              color: _isListening ? Colors.red : Colors.teal,
                            ),
                            onPressed: _startListening,
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _sortOption,
                      underline: SizedBox(),
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.black),
                      iconEnabledColor: Colors.teal,
                      items: ['Name', 'Area'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            'Sort by $value',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: _sortOption == value ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortOption = newValue;
                            applySorting(filteredPlaces);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : hasError
                    ? Center(child: Text('no data yet.'))
                    : places.isEmpty
                        ? Center(child: Text('no data yet'))
                        : filteredPlaces.isEmpty
                            ? Center(child: Text('No places found'))
                            : ListView.builder(
                                itemCount: filteredPlaces.length,
                                itemBuilder: (context, index) {
                                  return PlaceCard(place: filteredPlaces[index]);
                                },
                              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPlaceScreen(cityId: widget.cityId),
            ),
          );
          await fetchPlaces();
        },
        label: Text("Add Place", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add_location_alt, color: Colors.white),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
