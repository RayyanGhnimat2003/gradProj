import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/trip_details_locations_page.dart';
import 'package:http/http.dart' as http;
import 'trip_welcome_page.dart';  // استيراد الصفحة الجديدة
import '../widgets/trip_widget.dart';
import '../services/trip_utils.dart'; // استيراد الفنكشنات الجديدة

class TripsPage extends StatefulWidget {
  const TripsPage({Key? key}) : super(key: key);

  @override
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  List<dynamic> trips = [];
  List<dynamic> filteredTrips = [];
  String searchQuery = '';
  String filterType = 'title'; // title - city - type

  Future<void> fetchTrips() async {
    final response = await http.get(Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Trips/get_trips2.php'));
    if (response.statusCode == 200) {
      try {
        final List<dynamic> fetchedTrips = json.decode(response.body);
        setState(() {
          trips = sortTripsByDate(fetchedTrips);
          filteredTrips = trips;
        });
      } catch (e) {
        print('خطأ بالتحليل: $e');
      }
    } else {
      print('فشل بجلب الداتا: ${response.statusCode}');
    }
  }

  void updateSearch(String query) {
    List<dynamic> tempTrips = [];
    if (filterType == 'title') {
      tempTrips = filterTripsByTitle(trips, query);
    } else if (filterType == 'city') {
      tempTrips = filterTripsByCity(trips, query);
    } else if (filterType == 'type') {
      tempTrips = filterTripsByType(trips, query);
    }
    setState(() {
      searchQuery = query;
      filteredTrips = sortTripsByDate(tempTrips);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trips Page')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: updateSearch,
                    decoration: InputDecoration(
                      labelText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: filterType,
                  items: const [
                    DropdownMenuItem(value: 'title', child: Text('By Title')),
                    DropdownMenuItem(value: 'city', child: Text('By City')),
                    DropdownMenuItem(value: 'type', child: Text('By Type')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        filterType = value;
                        updateSearch(searchQuery);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTrips.isEmpty
                ? const Center(child: Text('No trips found'))
                : ListView.builder(
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                     return InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsLocationsPage(
          tripId: trip['id'] ?? 0,
        ),
      ),
    );
  },
  child: TripWidget(
    title: trip['title'] ?? '',
    imageUrl: trip['image_url'] ?? '',
    date: trip['date'] ?? '',
    startTime: trip['start_time'] ?? '',
    tripId: trip['id'] ?? 0,
  ),
);

                    },
                  ),
          ),
        ],
      ),
    );
  }
}
