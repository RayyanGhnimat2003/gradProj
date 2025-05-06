// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/pages/trip_details_locations_page.dart';
// import 'package:http/http.dart' as http;
// import 'trip_welcome_page.dart';  // استيراد الصفحة الجديدة
// import '../widgets/trip_widget.dart';
// import '../services/trip_utils.dart'; // استيراد الفنكشنات الجديدة

// class TripsPage extends StatefulWidget {
//   const TripsPage({Key? key}) : super(key: key);

//   @override
//   _TripsPageState createState() => _TripsPageState();
// }

// class _TripsPageState extends State<TripsPage> {
//   List<dynamic> trips = [];
//   List<dynamic> filteredTrips = [];
//   String searchQuery = '';
//   String filterType = 'title'; // title - city - type

//   Future<void> fetchTrips() async {
//     final response = await http.get(Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Trips/get_trips2.php'));
//     if (response.statusCode == 200) {
//       try {
//         final List<dynamic> fetchedTrips = json.decode(response.body);
//         setState(() {
//           trips = sortTripsByDate(fetchedTrips);
//           filteredTrips = trips;
//         });
//       } catch (e) {
//         print('خطأ بالتحليل: $e');
//       }
//     } else {
//       print('فشل بجلب الداتا: ${response.statusCode}');
//     }
//   }

//   void updateSearch(String query) {
//     List<dynamic> tempTrips = [];
//     if (filterType == 'title') {
//       tempTrips = filterTripsByTitle(trips, query);
//     } else if (filterType == 'city') {
//       tempTrips = filterTripsByCity(trips, query);
//     } else if (filterType == 'type') {
//       tempTrips = filterTripsByType(trips, query);
//     }
//     setState(() {
//       searchQuery = query;
//       filteredTrips = sortTripsByDate(tempTrips);
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchTrips();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Trips Page')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     onChanged: updateSearch,
//                     decoration: InputDecoration(
//                       labelText: 'Search...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 DropdownButton<String>(
//                   value: filterType,
//                   items: const [
//                     DropdownMenuItem(value: 'title', child: Text('By Title')),
//                     DropdownMenuItem(value: 'city', child: Text('By City')),
//                     DropdownMenuItem(value: 'type', child: Text('By Type')),
//                   ],
//                   onChanged: (value) {
//                     if (value != null) {
//                       setState(() {
//                         filterType = value;
//                         updateSearch(searchQuery);
//                       });
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: filteredTrips.isEmpty
//                 ? const Center(child: Text('No trips found'))
//                 : ListView.builder(
//                     itemCount: filteredTrips.length,
//                     itemBuilder: (context, index) {
//                       final trip = filteredTrips[index];
//                      return InkWell(
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TripDetailsLocationsPage(
//           tripId: trip['id'] ?? 0,
//         ),
//       ),
//     );
//   },
//   child: TripWidget(
//     title: trip['title'] ?? '',
//     imageUrl: trip['image_url'] ?? '',
//     date: trip['date'] ?? '',
//     startTime: trip['start_time'] ?? '',
//     tripId: trip['id'] ?? 0,
//   ),
// );

//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/trip_details_locations_page.dart';
import 'package:http/http.dart' as http;
import 'trip_welcome_page.dart';
import '../widgets/trip_widget.dart';
import '../services/trip_utils.dart';

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
  bool isLoading = true;

  Future<void> fetchTrips() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.get(Uri.parse('http://192.168.1.141/FinalProject_Graduaction/Trips/get_trips2.php'));
      if (response.statusCode == 200) {
        final List<dynamic> fetchedTrips = json.decode(response.body);
        setState(() {
          trips = sortTripsByDate(fetchedTrips);
          filteredTrips = trips;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('فشل بجلب الداتا: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('خطأ بالتحليل: $e');
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

  void _navigateToSuggestTrip() {
    // Replace with your actual suggest trip page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم الانتقال إلى صفحة اقتراح الرحلة قريباً'),
        backgroundColor: Colors.teal,
      ),
    );
    // Uncomment when you have the actual page
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SuggestTripPage(),
    //   ),
    // );
  }

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استكشف الرحلات', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchTrips,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.teal.shade50,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: updateSearch,
                    decoration: InputDecoration(
                      labelText: 'بحث...',
                      labelStyle: TextStyle(color: Colors.teal.shade700),
                      prefixIcon: Icon(Icons.search, color: Colors.teal),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filterType,
                      icon: Icon(Icons.filter_list, color: Colors.teal),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      items: const [
                        DropdownMenuItem(value: 'title', child: Text('العنوان')),
                        DropdownMenuItem(value: 'city', child: Text('المدينة')),
                        DropdownMenuItem(value: 'type', child: Text('النوع')),
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
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading 
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                )
              : filteredTrips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.teal.shade200),
                        const SizedBox(height: 16),
                        const Text(
                          'لم يتم العثور على رحلات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Check if the screen is wide enough for two columns
                      final isWideScreen = constraints.maxWidth > 700;
                      
                      if (isWideScreen) {
                        // Two column layout for wider screens
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: filteredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = filteredTrips[index];
                            return TripWidget(
                              title: trip['title'] ?? '',
                              imageUrl: trip['image_url'] ?? '',
                              date: trip['date'] ?? '',
                              startTime: trip['start_time'] ?? '',
                              tripId: trip['id'] ?? 0,
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
                            );
                          },
                        );
                      } else {
                        // Single column layout for narrower screens
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = filteredTrips[index];
                            return TripWidget(
                              title: trip['title'] ?? '',
                              imageUrl: trip['image_url'] ?? '',
                              date: trip['date'] ?? '',
                              startTime: trip['start_time'] ?? '',
                              tripId: trip['id'] ?? 0,
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
                            );
                          },
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToSuggestTrip,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('اقترح رحلة'),
        backgroundColor: Colors.teal,
      ),
    );
  }
}