import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/PlaceUser.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({Key? key, required this.place}) : super(key: key);

  // دالة لعرض معلومات المكان فقط إذا كانت القيمة غير فارغة أو صفرية
  Widget buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty || value == '0') {
      return SizedBox.shrink(); // إذا كانت القيمة null أو فارغة أو صفرية لا نقوم بعرض السطر
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
        title: Text(place.name ?? "Unnamed Place"),
        backgroundColor: Colors.teal,
        leading: BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // صورة المكان
          place.imageUrl != null && place.imageUrl!.isNotEmpty
              ? Image.network(
                  place.imageUrl!,
                  width: 500,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 100),
                )
              : SizedBox.shrink(), // إذا كانت الصورة null أو فارغة لا نعرضها
          SizedBox(height: 16),

          // عرض الاسم فقط إذا كان موجودًا
          if (place.name?.isNotEmpty ?? false)
            Text(place.name!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),

          // عرض الوصف فقط إذا كان موجودًا
          if (place.description?.isNotEmpty ?? false)
            Text(place.description!, style: TextStyle(fontSize: 16)),
          Divider(height: 32),

          // معلومات إضافية - سيتم إخفاء الحقول الفارغة أو null أو 0
          buildInfoRow(Icons.location_on, "Location", place.location),
          buildInfoRow(Icons.category, "Category", place.category),
          buildInfoRow(Icons.people, "Population", place.population?.toString()),
          buildInfoRow(Icons.square_foot, "Area", place.area),
          buildInfoRow(Icons.map, "Latitude", place.latitude?.toString()),
          buildInfoRow(Icons.map_outlined, "Longitude", place.longitude?.toString()),

          // عرض التاريخ فقط إذا كان موجودًا
          Divider(height: 32),
          Text(
            "Historical Background",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            place.history?.isNotEmpty ?? false ? place.history! : "No historical data available.",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
