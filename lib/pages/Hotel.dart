import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/HotelDetailsScreen.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HotelListScreen extends StatefulWidget {
  @override
  _HotelListScreenState createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  List hotels = [];
  List filteredHotels = [];
  TextEditingController searchController = TextEditingController();
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  List suggestions = [];


  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    final response = await http.get(Uri.parse('http://localhost/FinalProject_Graduaction/Hotels/getHotels.php'));

    if (response.statusCode == 200) {
      setState(() {
        hotels = json.decode(response.body);
        filteredHotels = hotels; // عرض جميع الفنادق افتراضيًا
      });
    } else {
      throw Exception('Failed to load hotels');
    }
  }

  void filterHotels(String query) {
  List filteredList = hotels.where((hotel) {
   return hotel['hotel_Name'].toLowerCase().startsWith(query.toLowerCase()) ||
           hotel['hotel_Location'].toLowerCase().startsWith(query.toLowerCase());
  }).toList();

  setState(() {
    filteredHotels = filteredList;
    suggestions = query.isEmpty ? [] : filteredList;
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
        title: Text("Find Your Hotel", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
         Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    children: [
      TextField(
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
      const SizedBox(height: 8),

      // قائمة الاقتراحات
     if (suggestions.isNotEmpty)
  ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: suggestions.length,
    itemBuilder: (context, index) {
      final suggestion = suggestions[index];
      return Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            suggestion['hotel_Name'],
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(suggestion['hotel_Location']),
            ],
          ),
          onTap: () {
            searchController.text = suggestion['hotel_Name'];
            filterHotels(suggestion['hotel_Name']);
            setState(() {
              suggestions = [];
            });
          },
        ),
      );
    },
  ),
    ],
  ),
),

          Expanded(
            child: filteredHotels.isEmpty
    ? Center(child: Text('No hotels found matching your search.'))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredHotels.length,
                    itemBuilder: (context, index) {
                      return HotelCard(hotel: filteredHotels[index]);
                    },
                  ),
          ),
        ],
      ),
      backgroundColor: Colors.teal.shade50,
    );
  }
}

class HotelCard extends StatelessWidget {
  final hotel;
  HotelCard({required this.hotel});

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
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16), // تباعد من الأعلى والجوانب
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // زوايا مستديرة للصورة
            child: Image.network(
              "http://192.168.56.1/FinalProject_Graduaction/Hotels/hotel_Image/${hotel['hotel_Image']}",
              height: 200,
              width:300,
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

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelDetailsScreen(
                            hotelName: hotel['hotel_Name'],
                            location: hotel['hotel_Location'],
                            description: hotel['hotel_Description'],
                            imageUrl: "http://192.168.56.1/FinalProject_Graduaction/Hotels/hotel_Image/${hotel['hotel_Image']}",
                            hotelId: int.parse(hotel['hotel_ID']),  // تحويل إلى int هنا

                            
                          ),
                        ),
                      );
                    },
                    child: Text("Show", style: TextStyle(color: Colors.white)),
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