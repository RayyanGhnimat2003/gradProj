import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'city_model.dart';

class CityEditScreen extends StatefulWidget {
  final City city;

  CityEditScreen({required this.city});

  @override
  _CityEditScreenState createState() => _CityEditScreenState();
}

class _CityEditScreenState extends State<CityEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _governorateController;
  late TextEditingController _populationController;
  late TextEditingController _famousSitesController;
  late TextEditingController _localProductsController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.city.name);
    _descriptionController = TextEditingController(text: widget.city.description);
    _governorateController = TextEditingController(text: widget.city.governorate);
    _populationController = TextEditingController(text: widget.city.population.toString());
    _famousSitesController = TextEditingController(text: widget.city.famousSites);
    _localProductsController = TextEditingController(text: widget.city.localProducts);
    _locationController = TextEditingController(text: widget.city.location);
  }

  Future<void> saveChanges() async {
    final updatedCity = City(
      id: widget.city.id,
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: widget.city.imageUrl,
      videoUrl: widget.city.videoUrl,
      governorate: _governorateController.text,
      population: int.tryParse(_populationController.text) ?? 0,
      area: widget.city.area,
      famousSites: _famousSitesController.text,
      historicalFacts: widget.city.historicalFacts,
      localProducts: _localProductsController.text,
      location: _locationController.text,
    );

    bool hasChanged =
        updatedCity.name != widget.city.name ||
        updatedCity.description != widget.city.description ||
        updatedCity.governorate != widget.city.governorate ||
        updatedCity.population != widget.city.population ||
        updatedCity.famousSites != widget.city.famousSites ||
        updatedCity.localProducts != widget.city.localProducts ||
        updatedCity.location != widget.city.location;

    if (!hasChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No changes detected')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.149.1/FinalProject_Graduaction/City/update_city.php'),
      body: {
        'id': updatedCity.id.toString(),
        'name': updatedCity.name,
        'description': updatedCity.description,
        'governorate': updatedCity.governorate,
        'population': updatedCity.population.toString(),
        'famousSites': updatedCity.famousSites,
        'localProducts': updatedCity.localProducts,
        'location': updatedCity.location,
      },
    );

    if (response.statusCode == 200) {
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
          content: Text("City data has been successfully updated."),
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
        SnackBar(content: Text('Failed to update city')),
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
      appBar: AppBar(title: Text('Edit City'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildTextField('City Name', Icons.location_city, _nameController),
            buildTextField('Description', Icons.description, _descriptionController),
            buildTextField('Governorate', Icons.map, _governorateController),
            buildTextField('Population', Icons.people, _populationController, inputType: TextInputType.number),
            buildTextField('Famous Sites', Icons.place, _famousSitesController),
            buildTextField('Local Products', Icons.shopping_cart, _localProductsController),
            buildTextField('Location', Icons.explore, _locationController),
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
