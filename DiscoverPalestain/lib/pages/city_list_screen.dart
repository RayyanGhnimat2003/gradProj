import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'city_model.dart';
import 'city_card.dart';
import 'add_city_screen.dart';

class CityListScreen extends StatefulWidget {
  @override
  _CityListScreenState createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  List<City> cities = [];
  List<City> filteredCities = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String _sortOption = 'Name'; // Default sorting option

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
      final response = await http.get(Uri.parse('http://localhost/FinalProject_Graduaction/City/get_cities.php'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          cities = jsonResponse.map((data) => City.fromMap(data)).toList();
          filteredCities = cities;
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

  // تعديل الفلترة بحيث لا تظهر قائمة الاقتراحات
  void filterCities(String query) {
    String lowerQuery = query.toLowerCase();
    List<City> filteredList = cities.where((city) {
      return city.name.toLowerCase().startsWith(lowerQuery);  // فلترة المدن حسب الحروف الأولى من الاسم
    }).toList();

    setState(() {
      filteredCities = filteredList;
    });

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
            filterCities(val.recognizedWords);  // فلترة بناءً على ما يتم التعرف عليه صوتيًا
          });
        },
      );
    }
  }

  Future<void> onDelete(int cityId) async {
    setState(() {
      filteredCities.removeWhere((city) => city.id == cityId);  // حذف المدينة من filteredCities
      cities.removeWhere((city) => city.id == cityId);  // حذف المدينة من cities أيضًا
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('City deleted successfully')));
  }

  Future<void> onUpdate(City updatedCity) async {
    setState(() {
      int index = filteredCities.indexWhere((city) => city.id == updatedCity.id);
      if (index != -1) {
        filteredCities[index] = updatedCity;
      }

      index = cities.indexWhere((city) => city.id == updatedCity.id);
      if (index != -1) {
        cities[index] = updatedCity;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث المدينة بنجاح')),
    );
  }

  Future<void> onAdd(City newCity) async {
    setState(() {
      cities.add(newCity);  // إضافة المدينة إلى cities
      filteredCities.add(newCity);  // إضافة المدينة إلى filteredCities أيضًا
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('City added successfully')));

    fetchCities(); // ✅ لأنك الآن داخل State
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
                  underline: SizedBox(),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.black),
                  iconEnabledColor: Colors.teal,
                  items: ['Name', 'Population', 'Area'].map((String value) {
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
                        applySorting(filteredCities);
                      });
                    }
                  },
                ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCityScreen()),
          );
        },
        label: Text(
          "Add City",
          style: TextStyle(color: Colors.white),  // تغيير لون النص إلى الأبيض
        ),
        icon: Icon(Icons.add_location_alt),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
