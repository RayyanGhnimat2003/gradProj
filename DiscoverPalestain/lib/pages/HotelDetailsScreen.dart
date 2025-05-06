import 'dart:convert';
import 'package:flutter/material.dart';
import 'room_booking_tab.dart';
import 'HotelReviews.dart';

import 'package:http/http.dart' as http;

class HotelDetailsScreen extends StatefulWidget {
  final String hotelName;
  final String location;
  final String description;
  final String imageUrl;
  final int hotelId;

  HotelDetailsScreen({
    required this.hotelName,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.hotelId,
  });

  @override
  _HotelDetailsScreenState createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    fetchHotelImages();
    _tabController = TabController(length: 3, vsync: this);
  }

Widget _buildFacility(IconData icon, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.teal, size: 24),
      SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 14)),
    ],
  );
}

  Future<void> fetchHotelImages() async {
    final response = await http.get(
      Uri.parse('http://localhost/FinalProject_Graduaction/Hotels/getHotelImages.php?hotel_ID=${widget.hotelId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        images = List<String>.from(data['images']);
      });
    } else {
      throw Exception('Failed to load hotel images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelName),
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Material(
            color: Colors.teal.shade100,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color.fromARGB(255, 0, 0, 0),
              unselectedLabelColor: Colors.teal.shade700,
              indicatorColor: const Color.fromARGB(255, 9, 9, 9),
              indicatorWeight: 4.0,
              tabs: [
                Tab(text: 'Hotel Details'),
                Tab(text: 'Room Reservation Sechedule'),
                Tab(text: 'Hotel Rating and Review'),
              ],
            ),
          ),
        ),
      ),
body: TabBarView(
  controller: _tabController,
  children: [
    // Hotel Details Tab
   // داخل TabBarView -> التبويب الأول "Hotel Details"
SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      SizedBox(height: 20),
      images.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _openImageViewer(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            "http://192.168.56.1/FinalProject_Graduaction/Hotels/hotelDetils_Images/${images[index]}",
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hotelName,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.teal, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.location,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal.shade700),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.description,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 30),

            //  مرافق الفندق كلهم ستاتيك 
            Text(
              "Most popular facilities",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 20,
              runSpacing: 15,
              children: [
                _buildFacility(Icons.local_parking, "Free parking"),
                _buildFacility(Icons.smoke_free, "Non-smoking rooms"),
                _buildFacility(Icons.family_restroom, "Family rooms"),
                _buildFacility(Icons.wifi, "Free WiFi"),
                _buildFacility(Icons.room_service, "Room service"),
                _buildFacility(Icons.fitness_center, "Fitness centre"),
                _buildFacility(Icons.restaurant, "Restaurant"),
                _buildFacility(Icons.spa, "Spa and wellness"),
                _buildFacility(Icons.local_bar, "Bar"),
                _buildFacility(Icons.free_breakfast, "Breakfast"),
              ],
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    ],
  ),
),

    
    // Room Reservation Tab (Call the RoomBookingTab widget)
    RoomBookingTab(hotelId: widget.hotelId, ),
    
    // Hotel Reviews Tab (Call the HotelReviews widget)
    HotelReviews(hotelId: widget.hotelId),
  ],
),

    );
  }

  // فتح المعرض
  void _openImageViewer(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black54,
          insetPadding: EdgeInsets.all(10),
          child: ImageViewer(imageUrls: images, initialIndex: index),
        );
      },
    );
  }
}

// معرض الصور الكامل
class ImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  ImageViewer({required this.imageUrls, required this.initialIndex});

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _nextImage() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Center(
              child: Image.network(
                "http://192.168.56.1/FinalProject_Graduaction/Hotels/hotelDetils_Images/${widget.imageUrls[index]}",
                fit: BoxFit.contain,
              ),
            );
          },
        ),
        // زر إغلاق المعرض
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        // زر السابق
        if (_currentIndex > 0)
          Positioned(
            left: 10,
            top: MediaQuery.of(context).size.height / 2 - 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
              onPressed: _previousImage,
            ),
          ),
        // زر التالي
        if (_currentIndex < widget.imageUrls.length - 1)
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height / 2 - 20,
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
              onPressed: _nextImage,
            ),
          ),
      ],
    );
  }
}
