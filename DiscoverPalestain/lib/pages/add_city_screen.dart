import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AddCityScreen extends StatefulWidget {
  @override
  _AddCityScreenState createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _populationController = TextEditingController();
  final _areaController = TextEditingController();
  final _locationController = TextEditingController();

  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageName;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _imageName = picked.name;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      } else {
        setState(() => _imageFile = File(picked.path));
      }
    }
  }

  Future<void> uploadCity() async {
    if ((kIsWeb && _imageBytes == null) || (!kIsWeb && _imageFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image')));
      return;
    }

    if (_nameController.text.trim().isEmpty || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Name and Location are required')));
      return;
    }

    if (_populationController.text.isNotEmpty && int.tryParse(_populationController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Population must be a valid number')));
      return;
    }

    final uri = Uri.parse('http://192.168.1.141/FinalProject_Graduaction/City/add_city.php');
    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll({
        'name': _nameController.text,
        'population': _populationController.text,
        'area': _areaController.text,
        'location': _locationController.text,
      });

    final imageFile = kIsWeb
        ? http.MultipartFile.fromBytes('image', _imageBytes!, filename: _imageName ?? 'image.jpg', contentType: MediaType('image', 'jpeg'))
        : await http.MultipartFile.fromPath('image', _imageFile!.path, contentType: MediaType('image', 'jpeg'));

    request.files.add(imageFile);
    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('City added successfully!')));
      Navigator.pop(context);
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed')));
    }
  }
Widget buildTextField(String label, IconData icon, TextEditingController controller,
    {bool required = false, TextInputType inputType = TextInputType.text}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),  // تغيير لون الأيقونة هنا
        border: OutlineInputBorder(),
      ),
      validator: required ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null : null,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add City'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField('City Name', Icons.location_city, _nameController, required: true),
              buildTextField('Location', Icons.explore, _locationController, required: true),
              buildTextField('Population', Icons.people, _populationController, inputType: TextInputType.number),
              buildTextField('Area', Icons.square_foot, _areaController),
              SizedBox(height: 12),
              if (kIsWeb && _imageBytes != null)
                Image.memory(_imageBytes!, height: 150)
              else if (!kIsWeb && _imageFile != null)
                Image.file(_imageFile!, height: 150)
              else
                Text('No image selected', textAlign: TextAlign.center),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text('Choose Image'),
                onPressed: pickImage,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.add_location_alt),
                label: Text('Add City'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) uploadCity();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
