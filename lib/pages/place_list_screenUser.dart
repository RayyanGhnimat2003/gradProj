import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;  // استيراد حزمة البحث الصوتي
import 'PlaceUser.dart';
import 'place_cardUser.dart';

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

  @override
  void initState() {
    super.initState();
    fetchPlaces();
    _speech = stt.SpeechToText();  // تهيئة البحث الصوتي
  }

  Future<void> fetchPlaces() async {
    try {
      final response = await http.get(Uri.parse(
          "http://192.168.149.1/FinalProject_Graduaction/City/getPlaces.php?city_id=${widget.cityId}"));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        if (jsonResponse.isEmpty) {
          setState(() {
            isLoading = false;
            places = [];
            filteredPlaces = [];
          });
        } else {
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
        }
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void filterPlaces(String query) {
    String lowerQuery = query.toLowerCase();
    List<Place> filteredList = places.where((place) {
      return place.name.toLowerCase().startsWith(lowerQuery) ||
          place.area.toLowerCase().startsWith(lowerQuery) ||
          place.category.toLowerCase().startsWith(lowerQuery);
    }).toList();

    applySorting(filteredList);
  }

  void applySorting(List<Place> list) {
    if (_sortOption == 'Name') {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_sortOption == 'Area') {
list.sort((a, b) {
        double areaA = double.tryParse(a.area.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        double areaB = double.tryParse(b.area.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        return areaB.compareTo(areaA);
      });    }

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
            filterPlaces(val.recognizedWords);
          });
        },
      );
    }
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: filterPlaces,
                    decoration: InputDecoration(
                      labelText: 'Search Places',
                      prefixIcon: Icon(Icons.search, color: Colors.teal),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: _isListening ? Colors.red : Colors.teal,
                        ),
                        onPressed: _startListening,  // بدء البحث الصوتي
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
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // يظهر عند تحميل البيانات
                : hasError
                    ? Center(child: Text('No data yet')) // عرض النص عند وجود خطأ
                    : places.isEmpty
                        ? Center(child: Text('No data yet')) // عرض النص عندما لا توجد بيانات
                        : filteredPlaces.isEmpty
                            ? Center(child: Text('No places found')) // عرض النص عندما لا توجد أماكن بعد البحث
                            : ListView.builder(
                                itemCount: filteredPlaces.length,
                                itemBuilder: (context, index) {
                                  return PlaceCard(place: filteredPlaces[index]);
                                },
                              ),
          ),
        ],
      ),
    );
  }
}
