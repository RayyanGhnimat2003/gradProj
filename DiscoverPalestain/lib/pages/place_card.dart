import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Place.dart';
import 'package:flutter_application_1/pages/PlaceEditScreen.dart';
import 'package:flutter_application_1/pages/place_list_screen.dart';

import 'package:http/http.dart' as http;

class PlaceCard extends StatelessWidget {
  final Place place;

  PlaceCard({required this.place});

  Future<void> deletePlace(BuildContext context, int id) async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this place?"),
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
        Uri.parse('http://192.168.1.141/FinalProject_Graduaction/City/delete_place.php?id=$id'),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200 ? "Place deleted." : "Failed to delete place.",
          ),
        ),
      );
      
    }
  }

  void editPlace(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceEditScreen(place: place),
      ),
    );
  }

  void showPlaces(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceListScreen(cityId: place.cityId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = place.imageUrl.startsWith('http')
        ? place.imageUrl
        : 'http://192.168.1.141/FinalProject_Graduaction/City/images/${place.imageUrl.startsWith('/') ? place.imageUrl.substring(1) : place.imageUrl}';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (place.imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              height: 200,
              width: 500,
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
                if (place.name.isNotEmpty)
                  Text(
                    place.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 8),
                if (place.location?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.teal, size: 18),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location!,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 6),
                if (place.category?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.teal, size: 18),
                      SizedBox(width: 4),
                      Text(
                        place.category!,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                SizedBox(height: 6),
               
                if (place.area?.isNotEmpty == true)
                  Row(
                    children: [
                      Icon(Icons.straighten, color: Colors.teal, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Area: ${place.area} km²',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                SizedBox(height: 6),
               
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => editPlace(context),
                      icon: Icon(Icons.edit, color: Colors.orange),
                      tooltip: "Edit Place",
                    ),
                    IconButton(
                      onPressed: () => deletePlace(context, place.id),
                      icon: Icon(Icons.delete, color: Colors.red),
                      tooltip: "Delete Place",
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
