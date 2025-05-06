import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Place.dart'; // تأكد أن هذا الكلاس معرف بشكل صحيح

class PlaceEditScreen extends StatefulWidget {
  final Place place;

  PlaceEditScreen({required this.place});

  @override
  _PlaceEditScreenState createState() => _PlaceEditScreenState();
}

class _PlaceEditScreenState extends State<PlaceEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _areaController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place.name);
    _descriptionController = TextEditingController(text: widget.place.description);
    _locationController = TextEditingController(text: widget.place.location);
    _areaController = TextEditingController(text: widget.place.area.toString());
    _categoryController = TextEditingController(text: widget.place.category);
  }

  Future<void> saveChanges() async {
    final updatedPlace = Place(
      id: widget.place.id,
      cityId: widget.place.cityId,
      name: _nameController.text,
      imageUrl: widget.place.imageUrl,
      description: _descriptionController.text,
      location: _locationController.text,
      area: _areaController.text,
      category: _categoryController.text,
      latitude: widget.place.latitude,
      longitude: widget.place.longitude,
      history: widget.place.history,
    );

    bool hasChanged =
        updatedPlace.name != widget.place.name ||
        updatedPlace.description != widget.place.description ||
        updatedPlace.location != widget.place.location ||
        updatedPlace.area != widget.place.area ||
        updatedPlace.category != widget.place.category;

    if (!hasChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No changes detected')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.149.1/FinalProject_Graduaction/City/update_place.php'),
      body: {
        'id': updatedPlace.id.toString(),
        'name': updatedPlace.name,
        'description': updatedPlace.description,
        'location': updatedPlace.location,
        'area': updatedPlace.area,
        'category': updatedPlace.category,
      },
    );

    print(response.body); // ✅ مهم لمساعدتك في معرفة السبب في حال فشل التحديث

    if (response.statusCode == 200 && response.body.contains("success")) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.teal),
              SizedBox(width: 8),
              Text("Updated"),
            ],
          ),
          content: Text("Place data has been successfully updated."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update place')),
      );
    }
  }

  Widget buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Place'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildTextField('Place Name', Icons.location_city, _nameController),
            buildTextField('Description', Icons.description, _descriptionController),
            buildTextField('Location', Icons.explore, _locationController),
            buildTextField('Area', Icons.map, _areaController, inputType: TextInputType.number),
            buildTextField('Category', Icons.category, _categoryController),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: saveChanges,
                icon: Icon(Icons.save),
                label: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
