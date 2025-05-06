import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/PlaceDetailsScreen.dart';
import 'package:flutter_application_1/pages/PlaceUser.dart';

class PlaceCard extends StatelessWidget {
  final Place place;

  PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    // تجهيز الرابط الكامل للصورة
    String imageUrl = place.imageUrl.startsWith('http')
        ? place.imageUrl
        : 'http://192.168.149.1/FinalProject_Graduaction/City/images/${place.imageUrl.startsWith('/') ? place.imageUrl.substring(1) : place.imageUrl}';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عرض الصورة إن وجدت
          if (place.imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              height: 200,
              width: 400,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 180,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 60, color: Colors.red),
                      SizedBox(height: 8),
                      Text("❌ Failed to load image", style: TextStyle(color: Colors.red)),
                      SizedBox(height: 4),
                      Text(imageUrl, style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),

          // محتوى النصوص
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الاسم
                if (place.name.isNotEmpty)
                  Text(
                    place.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 8),

                // الموقع
                if (place.location.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 6),
                // ✅ التصنيف هنا
if (place.category.isNotEmpty)
  Row(
    children: [
      Icon(Icons.category, color: Colors.deepPurple[600], size: 18),
      SizedBox(width: 4),
      Text(
        place.category,
        style: TextStyle(color: Colors.deepPurple[700], fontSize: 14),
      ),
    ],
  ),
SizedBox(height: 6),

               

                // المساحة
                if (place.area != null)
                  Row(
                    children: [
                      Icon(Icons.straighten, color: Colors.blueGrey[700], size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Area: ${place.area} km²',
                        style: TextStyle(color: Colors.blueGrey[700], fontSize: 14),
                      ),
                    ],
                  ),
                SizedBox(height: 10),

                // زر إظهار التفاصيل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailsScreen(place: place),
                          ),
                        );
                      },
                      child: Text("Show Details"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                            textStyle: TextStyle(color: Colors.white),  // تعديل لون النص إلى الأبيض

                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
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
