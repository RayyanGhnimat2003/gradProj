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
  List favoriteHotels = [];
  int userId = 61; // معرّف المستخدم (يمكن تغييره ديناميكياً)

 



  @override
void initState() {
  super.initState();
  fetchHotels();
  fetchFavorites();
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

Future<void> fetchFavorites() async {
  final response = await http.get(
    Uri.parse('http://localhost/FinalProject_Graduaction/Hotels/get_favorites.php?user_id=$userId'),
  );

  if (response.statusCode == 200) {
    setState(() {
      favoriteHotels = List<int>.from(json.decode(response.body));
    });
  } else {
    print('Failed to load favorites');
  }
}

void toggleFavorite(int hotelId) async {
  bool isFav = isFavorite(hotelId);

  final response = await http.post(
    Uri.parse(isFav
        ? 'http://localhost/FinalProject_Graduaction/Hotels/remove_favorite.php'
        : 'http://localhost/FinalProject_Graduaction/Hotels/add_favorite.php'),
    body: {'user_id': userId.toString(), 'hotel_id': hotelId.toString()},
  );

  if (response.statusCode == 200) {
    setState(() {
      if (isFav) {
        favoriteHotels.remove(hotelId);
      } else {
        favoriteHotels.add(hotelId);
      }
    });
  } else {
    print('Error toggling favorite');
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

 bool isFavorite(int hotelId) {
  return favoriteHotels.contains(hotelId);
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
      : LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;

            // ضبط عدد الأعمدة بناءً على عرض الشاشة
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 3; // الشاشات العريضة
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 2; // الشاشات المتوسطة
            } else {
              crossAxisCount = 1; // الشاشات الصغيرة
            }

            return GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
childAspectRatio: 0.90, // لتقليل المساحة البيضاء
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: filteredHotels.length,
              itemBuilder: (context, index) {
                return HotelCard(
                  hotel: filteredHotels[index],
                  isFavorite: isFavorite(int.parse(filteredHotels[index]['hotel_ID'])),
                  onFavoriteToggle: () => toggleFavorite(int.parse(filteredHotels[index]['hotel_ID'])),
                );
              },
            );
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
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  HotelCard({required this.hotel, required this.isFavorite, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8), // تقليل المسافة داخل البطاقة
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(
                aspectRatio: 16 / 10, // تعديل نسبة العرض إلى الارتفاع
                child: Image.network(
                  "http://192.168.56.1/FinalProject_Graduaction/Hotels/hotel_Image/${hotel['hotel_Image']}",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // زر المفضلة أسفل الصورة
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              hotel['hotel_Name'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Location: ${hotel['hotel_Location']}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hotel['starting_price'] == null
                      ? 'No rooms available'
                      : "From \$${hotel['starting_price']}/night",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HotelDetailsScreen(
                          hotelName: hotel['hotel_Name'],
                          location: hotel['hotel_Location'],
                          description: hotel['hotel_Description'],
                          imageUrl:
                              "http://192.168.56.1/FinalProject_Graduaction/Hotels/hotel_Image/${hotel['hotel_Image']}",
                          hotelId: int.parse(hotel['hotel_ID']),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Show", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
