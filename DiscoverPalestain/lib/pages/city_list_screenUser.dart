import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'city_modelUser.dart';
import 'city_cardUser.dart';

class CityListScreen extends StatefulWidget {
  @override
  _CityListScreenState createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  List<City> cities = [];
  List<City> filteredCities = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String _sortOption = 'Name';

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    fetchCities();
  }

  Future<void> fetchCities() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.141/FinalProject_Graduaction/City/get_cities.php'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        List<City> cityList = jsonResponse.map((data) => City.fromMap(data)).toList();
        cityList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        setState(() {
          cities = cityList;
          filteredCities = cityList;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading cities: $error')));
    }
  }

  void filterCities(String query) {
    String lowerQuery = query.toLowerCase();
    List<City> filteredList = cities.where((city) {
      return city.name.toLowerCase().startsWith(lowerQuery);
    }).toList();

    applySorting(filteredList);
  }

  void applySorting(List<City> list) {
    if (_sortOption == 'Name') {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_sortOption == 'Population') {
      list.sort((a, b) => b.population.compareTo(a.population));
    } else if (_sortOption == 'Area') {
      list.sort((a, b) {
        double areaA = double.tryParse(a.area.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        double areaB = double.tryParse(b.area.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        return areaB.compareTo(areaA);
      });
    }
    setState(() => filteredCities = list);
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            searchController.text = val.recognizedWords;
            filterCities(val.recognizedWords);
          });
        },
      );
    }
  }

  void onDelete(int cityId) {
    setState(() {
      filteredCities.removeWhere((city) => city.id == cityId);
    });
  }

  void onUpdate(City updatedCity) {
    setState(() {
      int index = filteredCities.indexWhere((city) => city.id == updatedCity.id);
      if (index != -1) {
        filteredCities[index] = updatedCity;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: Row(
          children: [
            Icon(Icons.location_city, color: const Color.fromARGB(255, 0, 0, 0)),
            SizedBox(width: 8),
            Text("Cities"),
          ],
        ),
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
                    onChanged: (value) => filterCities(value),
                    decoration: InputDecoration(
                      labelText: 'Search Cities',
                      prefixIcon: Icon(Icons.search, color: Colors.teal),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.mic, color: _isListening ? Colors.red : Colors.grey),
                        onPressed: _startListening,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
    DropdownButton<String>(
  value: _sortOption,
  underline: SizedBox(), // إزالة الخط السفلي
  dropdownColor: Colors.white, // خلفية القائمة المنسدلة
  style: TextStyle(color: Colors.black), // لون النص المختار
  iconEnabledColor: Colors.teal, // لون سهم القائمة
  items: ['Name', 'Population', 'Area'].map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        'Sort by $value',
        style: TextStyle(
          color: Colors.black, // لون نص العنصر
          fontWeight: _sortOption == value ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }).toList(),
  onChanged: (newValue) {
    if (newValue != null) {
      setState(() {
        _sortOption = newValue;
        applySorting(filteredCities);
      });
    }
  },
)



              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredCities.isEmpty
                    ? Center(child: Text('No cities found'))
                    : ListView.builder(
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          return CityCard(
                            city: filteredCities[index],
                            onDelete: onDelete,
                            onUpdate: onUpdate,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
