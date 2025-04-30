
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'trip_booking_page.dart';

class TripDetailsLocationsPage extends StatefulWidget {
  final int tripId;

  TripDetailsLocationsPage({required this.tripId});

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsLocationsPage> {
  Map<String, dynamic>? tripData;
  bool isLoading = true;

  List<Map<String, dynamic>> weatherList = []; // ✅ طقس لكل مدينة
  String? weatherMessage;

  @override
  void initState() {
    super.initState();
    fetchTripDetails();
  }

  Future<void> fetchTripDetails() async {
    final url =
        'http://192.168.56.1/FinalProject_Graduaction/Trips/get_trip_details_and_locations.php?id=${widget.tripId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        tripData = decoded;
        isLoading = false;
      });

      final cityField = decoded['city'];
      final cities = cityField.split(',').map((c) => c.trim()).toList();

      DateTime tripDate = DateTime.parse(decoded['date']);

      for (String city in cities) {
        await fetchWeather(city, tripDate);
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchWeather(String city, DateTime tripDate) async {
    final apiKey = '7689f4540bf5d2294262276d807a0765';
    final today = DateTime.now();
    final difference = tripDate.difference(today).inDays;

    DateTime dateToUse = tripDate;
    String note = "";

    if (difference > 7) {
      dateToUse = today;
      note = "الطقس ليوم الرحلة غير متوفر حالياً، يتم عرض طقس اليوم.";
    }

    final dateString =
        "${dateToUse.year}-${dateToUse.month.toString().padLeft(2, '0')}-${dateToUse.day.toString().padLeft(2, '0')}";
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List forecasts = data['list'];
      final forecastForDate = forecasts.firstWhere(
        (item) => item['dt_txt'].startsWith(dateString),
        orElse: () => forecasts[0],
      );

      setState(() {
        weatherList.add({
          'city': city,
          'data': forecastForDate,
          'note': note,
        });
      });
    } else {
      setState(() {
        weatherMessage = "فشل في جلب حالة الطقس.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tripData == null
              ? Center(child: Text('No trip data found.'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        tripData!['image_url'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tripData!['title'],
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              tripData!['description'],
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[800]),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoColumn("Date", tripData!['date']),
                                _buildInfoColumn("Start", tripData!['start_time']),
                                _buildInfoColumn("End", tripData!['end_time']),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Guide: ${tripData!['guide_name']}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 24),
                            if (weatherMessage != null) ...[
                              Text(
                                weatherMessage!,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                              SizedBox(height: 8),
                            ],
                            if (weatherList.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: weatherList.map((weather) {
                                  return _buildWeatherCard(
                                    weather['city'],
                                    weather['data'],
                                    weather['note'],
                                  );
                                }).toList(),
                              ),
                            SizedBox(height: 24),
                            Text(
                              'Locations',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: (tripData!['locations'] as List).length,
                              itemBuilder: (context, index) {
                                final location =
                                    tripData!['locations'][index];
                                return Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: Image.network(
                                      location['image_name'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(location['location_name']),
                                    subtitle: Text(
                                        'Order: ${location['order_number']}'),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24),
                            // _buildBookingButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWeatherCard(String city, Map<String, dynamic> weatherData, String? note) {
    final main = weatherData['main'];
    final weatherDesc = weatherData['weather'][0];

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          'الطقس في $city',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${weatherDesc['description']}'),
            if (note != null && note.isNotEmpty)
              Text(
                note,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
        trailing: Text('${main['temp']}°C'),
      ),
    );
  }
// Widget _buildBookingButton() {
//   DateTime tripDate = DateTime.parse(tripData!['date']);
//   DateTime today = DateTime.now();
//   bool isPastTrip = tripDate.isBefore(today);
//   bool isFull = tripData!['registered_seats'] >= tripData!['max_seats'];
//   int availableSeats = tripData!['max_seats'] - tripData!['registered_seats'];

//   // طباعة القيم للتأكد من أنها صحيحة
//   // print("Trip Date: $tripDate");
//   // print("Available Seats: $availableSeats");
//   // print("Price: ${tripData!["price"]}");

//   return ElevatedButton(
//     onPressed: (isPastTrip || isFull)
//         ? null
//         : () {
//             // التأكد من صحة البيانات قبل التوجيه
//             if (tripData != null &&
//                 tripData!.containsKey("price") &&
//                 tripData!["price"] != null) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => TripBookingPage(
//                     tripData: {
//                       "tripId": widget.tripId.toString(),
//                       "tripName": tripData!["title"],
//                       "tripImage": tripData!["image_url"],
//                       "seatPrice": double.parse(tripData!["price"]),
//                       "userName": "shireen Aabed",
//                       "availableSeats": availableSeats,
//                     },
//                   ),
//                 ),
//               );
//             } else {
//               // طباعة الخطأ في حال كانت البيانات مفقودة أو غير صحيحة
//               print("Error: Missing trip price or invalid data");
//             }
//           },
//     style: ButtonStyle(
//       backgroundColor: MaterialStateProperty.all(
//         isPastTrip || isFull ? Colors.red : Colors.blue,
//       ),
//     ),
//     child: Text(
//       isPastTrip
//           ? "Trip has ended"
//           : isFull
//               ? "Fully booked"
//               : "Book Now",
//       style: TextStyle(color: Colors.white),
//     ),
//   );
// }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );  }
 }