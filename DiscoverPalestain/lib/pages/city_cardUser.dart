import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/city_details_screen.dart';
import 'package:http/http.dart' as http;
import 'city_modelUser.dart';

class CityCard extends StatelessWidget {
  final City city;
  final Function onDelete;
  final Function onUpdate;

  CityCard({
    required this.city,
    required this.onDelete,
    required this.onUpdate,
  });
  void showDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailsScreen(city: city),
      ),
    );
  }
  Future<void> deleteCity(BuildContext context) async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this city?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete) {
      final response = await http.get(
        Uri.parse('http://192.168.1.141/FinalProject_Graduaction/City/delete_city.php?id=${city.id}'),
      );

      if (response.statusCode == 200) {
        onDelete(city.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("City deleted.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete city.")));
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    // Ensure no null value is passed to imageUrl.
    String imageUrl = city.imageUrl?.startsWith('http') == true
        ? city.imageUrl!
        : 'http://192.168.1.141/FinalProject_Graduaction/City/images/${city.imageUrl?.startsWith('/') == true ? city.imageUrl!.substring(1) : city.imageUrl}';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show image if imageUrl is not null and not empty
          if (city.imageUrl != null && city.imageUrl!.isNotEmpty)
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Only show city name if not null and not empty
                if (city.name?.isNotEmpty == true)
                  Text(
                    city.name!,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 8),

                // Only show location if not null and not empty
                if (city.location?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          city.location!,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 6),

                // Only show population if not null
                if (city.population != null)
                  Row(
                    children: [
                      Icon(Icons.groups, color: Colors.blueGrey[600], size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Population: ${city.population}',
                        style: TextStyle(color: Colors.blueGrey[700], fontSize: 14),
                      ),
                    ],
                  ),
                SizedBox(height: 6),

                // Only show area if not null
                if (city.area != null)
                  Row(
                    children: [
                      Icon(Icons.straighten, color: Colors.blueGrey[700], size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Area: ${city.area}',
                        style: TextStyle(color: Colors.blueGrey[700], fontSize: 14),
                      ),
                    ],
                  ),
                SizedBox(height: 10),

                // Edit and delete buttons
              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    ElevatedButton(
      onPressed: () => showDetails(context),
      child: Text(
        "Show Details",
        style: TextStyle(color: Colors.white),  // تعديل لون النص إلى الأبيض
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
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
