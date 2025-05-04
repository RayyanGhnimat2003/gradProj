import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'trip_booking_page.dart';

class TripDetailsLocationsPage extends StatefulWidget {
  final int tripId;
  TripDetailsLocationsPage({required this.tripId});

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsLocationsPage> {
  Map<String, dynamic>? tripData;
  bool isLoading = true;
  List<Map<String, dynamic>> weatherList = [];
  String? weatherMessage;

  @override
  void initState() {
    super.initState();
    fetchTripDetails();
  }

  Future<void> fetchTripDetails() async {
    final url =
        'http://192.168.1.141/FinalProject_Graduaction/Trips/get_trip_details_and_locations.php?id=${widget.tripId}';
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
      note = "Forecast for trip day not available. Showing today's weather.";
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
        weatherMessage = "Failed to fetch weather data.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
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
                      _buildImageGallery(tripData!),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tripData!['title'],
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                            SizedBox(height: 8),
                            Text(
                              tripData!['description'],
                              style: TextStyle(fontSize: 16),
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
                            SizedBox(height: 12),
                            Text(
                              'Guide: ${tripData!['guide_name']}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Price per person: \$${tripData!["price"]}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            if (weatherMessage != null)
                              Text(
                                weatherMessage!,
                                style: TextStyle(color: Colors.red),
                              ),
                            if (weatherList.isNotEmpty)
                              Column(
                                children: weatherList.map((weather) {
                                  return _buildWeatherCard(
                                      weather['city'],
                                      weather['data'],
                                      weather['note']);
                                }).toList(),
                              ),
                            SizedBox(height: 24),
                            _buildBookingButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildImageGallery(Map<String, dynamic> data) {
    final List locations = data['locations'];
    return Container(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: locations.length + 1,
        separatorBuilder: (context, index) {
          return index != locations.length - 1
              ? Icon(Icons.arrow_forward, color: Colors.teal)
              : SizedBox();
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildImageCard(data['image_url'], 'Trip');
          } else {
            final location = locations[index - 1];
            return _buildImageCard(
                location['image_name'], location['location_name']);
          }
        },
      ),
    );
  }

  Widget _buildImageCard(String imageUrl, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
      ],
    );
  }

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
    );
  }

  Widget _buildWeatherCard(
      String city, Map<String, dynamic> weatherData, String? note) {
    final main = weatherData['main'];
    final weatherDesc = weatherData['weather'][0];

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.teal[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.cloud, size: 40, color: Colors.teal),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weather in $city',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal[900]),
                  ),
                  Text('${weatherDesc['description']}'),
                  if (note != null && note.isNotEmpty)
                    Text(note, style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            Text('${main['temp']}°C',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingButton() {
    DateTime tripDate = DateTime.parse(tripData!['date']);
    DateTime today = DateTime.now();
    bool isPastTrip = tripDate.isBefore(today);
    bool isFull = tripData!['registered_seats'] >= tripData!['max_seats'];
    int availableSeats = tripData!['max_seats'] - tripData!['registered_seats'];

    return ElevatedButton(
      onPressed: (isPastTrip || isFull)
          ? null
          : () {
              if (tripData != null &&
                  tripData!.containsKey("price") &&
                  tripData!["price"] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripBookingPage(
                      tripData: {
                        "tripId": widget.tripId.toString(),
                        "tripName": tripData!["title"],
                        "tripImage": tripData!["image_url"],
                        "seatPrice": double.parse(tripData!["price"]),
                        "userName": "shireen Aabed",
                        "availableSeats": availableSeats,
                      },
                    ),
                  ),
                );
              } else {
                print("Error: Missing trip price or invalid data");
              }
            },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isPastTrip || isFull ? Colors.red : Colors.teal,
        ),
      ),
      child: Text(
        isPastTrip
            ? "Trip has ended"
            : isFull
                ? "Fully booked"
                : "Book Now",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
