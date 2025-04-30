import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/EditeHotelInfo.dart';
import 'AddHotel.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AdminHotelListScreen extends StatefulWidget {
  @override
  _AdminHotelListScreenState createState() => _AdminHotelListScreenState();
}

class _AdminHotelListScreenState extends State<AdminHotelListScreen> {
  List hotels = [];
  List filteredHotels = [];
  TextEditingController searchController = TextEditingController();
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    final response = await http.get(Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Hotels/getHotels.php'));

    if (response.statusCode == 200) {
      setState(() {
        hotels = json.decode(response.body);
        filteredHotels = hotels;
      });
    } else {
      throw Exception('Failed to load hotels');
    }
  }

 Future<void> deleteHotel(int hotelId) async {
  print("deleteHotel() called with ID: $hotelId");

  final url = Uri.parse("http://192.168.56.1/FinalProject_Graduaction/Hotels/deleteHotel.php");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"hotel_id": hotelId}),
  );

  print("API Response: ${response.body}");

  final data = jsonDecode(response.body);

  if (data['success'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text("Hotel deleted successfully.")),
      ],
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: Duration(seconds: 3),
  ),
);

    setState(() {
      // نحذف الفندق من القائمة مباشرة
      hotels.removeWhere((hotel) => hotel['hotel_ID'].toString() == hotelId.toString());
      filteredHotels.removeWhere((hotel) => hotel['hotel_ID'].toString() == hotelId.toString());
    });

  } else if (data['error'] == "Cannot delete hotel with existing bookings.") {
   ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text("Cannot delete hotel with active bookings.")),
      ],
    ),
    backgroundColor: Colors.red.shade700,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: Duration(seconds: 4),
  ),
);

  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Failed to delete hotel."))
    );
  }
}



  void filterHotels(String query) {
    List filteredList = hotels.where((hotel) {
      return hotel['hotel_Name'].toLowerCase().contains(query.toLowerCase()) ||
          hotel['hotel_Location'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredHotels = filteredList;
    });
  }

  void startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        print('Speech Status: $status');
      },
      onError: (error) {
        print('Speech Error: $error');
      },
    );

    if (available) {
      setState(() {
        isListening = true;
      });

      speech.listen(
        onResult: (result) {
          setState(() {
            searchController.text = result.recognizedWords;
            filterHotels(result.recognizedWords);
          });
        },
      );
    }
  }

  void stopListening() {
    setState(() {
      isListening = false;
    });
    speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin: Manage Hotels", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterHotels(value);
              },
              decoration: InputDecoration(
                labelText: 'Search Hotels',
                hintText: 'Search by name or location',
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                suffixIcon: IconButton(
                  icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: Colors.teal),
                  onPressed: isListening ? stopListening : startListening,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredHotels.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredHotels.length,
                   itemBuilder: (context, index) {
  return HotelCardAdmin(
    hotel: filteredHotels[index],
    onDelete: () {
      var hotelId = int.tryParse(filteredHotels[index]['hotel_ID'].toString()) ?? -1;
      if (hotelId != -1) deleteHotel(hotelId);
    },
    onEditDone: () async {
      await fetchHotels();
      setState(() {}); 
    },
  );
},
                  ),
          ),
        ],
      ),
      backgroundColor: Colors.teal.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddHotelScreen()),
          );
          if (result == true) {
            fetchHotels();
          }
        },
        icon: Icon(Icons.add, size: 28),
        label: Text("Add Hotel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
    );
  }
}

class HotelCardAdmin extends StatelessWidget {
  final hotel;
  final VoidCallback onDelete;
    final VoidCallback onEditDone; // ← أضف هذا


  HotelCardAdmin({required this.hotel, required this.onDelete ,required this.onEditDone});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                "http://192.168.56.1/FinalProject_Graduaction/Hotels/hotel_Image/${hotel['hotel_Image']}",
                height: 200,
                width: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel['hotel_Name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Location: ${hotel['hotel_Location']}", style: TextStyle(color: Colors.grey.shade700)),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Text(
  hotel['starting_price'] == null
      ? 'No rooms available'
      : "Starting from \$${hotel['starting_price']} / night",
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
),
                    Row(
                      children: [
                      IconButton(
  icon: Icon(Icons.edit, color: Colors.teal),
  onPressed: () async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHotelScreen(hotel: hotel),
      ),
    );

    if (updated == true) {
      onEditDone(); // ← استدعِ الدالة من الشاشة الرئيسية
    }
  },
),


                        IconButton(
  icon: Icon(Icons.delete, color: Colors.red, size: 30),
  onPressed: () {
    print("Hotel ID from card: ${hotel['hotel_ID']}"); // اطبع ID هون للتأكد
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this hotel?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              onDelete(); // هذا ينفذ الدالة من الشاشة الرئيسية
            },
          ),
        ],
      ),
    );
  },
),

                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
