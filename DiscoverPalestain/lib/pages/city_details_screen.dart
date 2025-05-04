import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/city_modelUser.dart';
import 'package:flutter_application_1/pages/place_list_screenUser.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CityDetailsScreen extends StatefulWidget {
  final City city;

  CityDetailsScreen({required this.city});

  @override
  _CityDetailsScreenState createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchImageUrls();
  }

  // جلب الصور من الـ API
  Future<void> _fetchImageUrls() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.141/FinalProject_Graduaction/City/get_city_images.php?city_id=${widget.city.id}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          _imageUrls = List<String>.from(data['data']);
        });
      } else {
        setState(() {
          _imageUrls = [];
        });
      }
    } else {
      throw Exception('Failed to load images');
    }
  }

  String getYouTubeThumbnail(String videoUrl) {
    final uri = Uri.parse(videoUrl);
    final videoId = uri.queryParameters['v'] ?? videoUrl.split('/').last;
    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return value.isEmpty
        ? Container() // إذا كانت القيمة فارغة، لا تعرض الصف
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: Colors.teal),
                SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black87, fontSize: 15),
                      children: [
                        TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: value),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city.name),
        backgroundColor: Colors.teal,
        leading: BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // City Image
          GestureDetector(
            onTap: () {
              // عرض معرض الصور في نافذة منبثقة إذا كانت الصور موجودة
              if (_imageUrls.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => ImageGalleryDialog(imageUrls: _imageUrls),
                );
              } 
            },
            child: Image.network(
              widget.city.imageUrl,
              width: 500, // تم تعديل عرض الصورة
              height: 250, // تم تعديل ارتفاع الصورة
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 100),
            ),
          ),
          SizedBox(height: 16),

          // City name and description
          Text(widget.city.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(widget.city.description, style: TextStyle(fontSize: 16)),
          Divider(height: 32),

          // Basic Info
          buildInfoRow(Icons.location_on, "Location", widget.city.location),
          buildInfoRow(Icons.map, "Governorate", widget.city.governorate),
          buildInfoRow(Icons.people, "Population", widget.city.population.toString()),
          buildInfoRow(Icons.square_foot, "Area", widget.city.area),
          
          // Additional Info
          Divider(height: 24),
          buildInfoRow(Icons.place, "Famous Sites", widget.city.famousSites),
          buildInfoRow(Icons.history, "Historical Facts", widget.city.historicalFacts),
          buildInfoRow(Icons.shopping_bag, "Local Products", widget.city.localProducts),

          // الفيديو
          if (widget.city.videoUrl.isNotEmpty) ...[
            Divider(height: 40),
            Text(
              "Watch an Introduction to ${widget.city.name}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () => _launchURL(widget.city.videoUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    getYouTubeThumbnail(widget.city.videoUrl),
                    width: 320,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.play_circle_fill, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Center(
  child: ElevatedButton.icon(
    onPressed: () => _launchURL(widget.city.videoUrl),
    icon: Icon(Icons.ondemand_video),
    label: Text(
      "Watch Video on YouTube",
      style: TextStyle(color: Colors.white),  // تعديل لون النص إلى الأبيض
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
),

          ],

          // عرض الأماكن المرتبطة بالمدينة
          SizedBox(height: 20),

          // زر "Show Places in {city.name}" في الأسفل وعلى اليسار
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // محاذاة الزر إلى اليسار
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // تمرير city_id إلى PlaceListScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceListScreen(cityId: widget.city.id),
                    ),
                  );
                },
                icon: Icon(Icons.location_on, color: Colors.white), // أيقونة تحديد الموقع
                label: Text(
                  "Show Places in ${widget.city.name}", // النص المخصص
                  style: TextStyle(color: Colors.white), // نص أبيض
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // اللون الأخضر للمربع
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20), // المسافات داخل الزر
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // شكل الزر المربع بحواف دائرية
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// نافذة المعرض
class ImageGalleryDialog extends StatefulWidget {
  final List<String> imageUrls;

  ImageGalleryDialog({required this.imageUrls});

  @override
  _ImageGalleryDialogState createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<ImageGalleryDialog> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 400,
        child: Stack(
          children: [
            // عرض الصورة الحالية
            Center(
              child: Image.network(
                widget.imageUrls[_currentIndex],
                fit: BoxFit.contain,
                width: 900,  // تم تعديل عرض الصورة
                height: 550, // تم تعديل ارتفاع الصورة
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, size: 50, color: Colors.red);
                },
              ),
            ),
            // زر الإغلاق
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // الأسهم في منتصف الصورة (يسار ويمين)
            Positioned(
              left: 0,
              top: MediaQuery.of(context).size.height / 2 - 20, // الأسهم في المنتصف عموديًا
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 40),
                onPressed: () {
                  setState(() {
                    if (_currentIndex > 0) {
                      _currentIndex--;
                    }
                  });
                },
              ),
            ),
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height / 2 - 20, // الأسهم في المنتصف عموديًا
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 40),
                onPressed: () {
                  setState(() {
                    if (_currentIndex < widget.imageUrls.length - 1) {
                      _currentIndex++;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
