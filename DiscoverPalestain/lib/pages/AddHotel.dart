import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddHotelScreen extends StatefulWidget {
  @override
  _AddHotelScreenState createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  File? selectedImage;
  Uint8List? webImage;
  List<File> selectedGalleryImages = [];
  List<Uint8List> webGalleryImages = [];

  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        var imageBytes = await picked.readAsBytes();
        setState(() {
          webImage = imageBytes;
          selectedImage = File("web_placeholder");
        });
      } else {
        setState(() {
          selectedImage = File(picked.path);
        });
      }
    }
  }

  Future<void> pickGalleryImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      if (kIsWeb) {
        List<Uint8List> imageBytes = [];
        for (var image in picked) {
          imageBytes.add(await image.readAsBytes());
        }
       setState(() {
  webGalleryImages.addAll(imageBytes);
  selectedGalleryImages.addAll(List.generate(imageBytes.length, (_) => File("web_placeholder")));
});

      } else {
        setState(() {
          selectedGalleryImages = picked.map((e) => File(e.path)).toList();
        });
      }
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage == null) return null;

    var uri = Uri.parse('http://localhost/FinalProject_Graduaction/Hotels/uploadHotelImage.php');
    var request = http.MultipartRequest('POST', uri);

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes('image', webImage!, filename: "main_${DateTime.now().millisecondsSinceEpoch}.png"));
    } else {
      request.files.add(await http.MultipartFile.fromPath('image', selectedImage!.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      var res = await http.Response.fromStream(response);
      var data = jsonDecode(res.body);
      if (data['success']) return data['filename'];
    }
    return null;
  }

  Future<bool> addHotel(String name, String location, String image, String description) async {
    var url = Uri.parse('http://localhost/FinalProject_Graduaction/Hotels/addHotel.php');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "hotel_Name": name,
        "hotel_Location": location,
        "hotel_Image": image,
        "hotel_Description": description,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  Future<int?> getLastHotelId() async {
    final response = await http.get(Uri.parse('http://localhost/FinalProject_Graduaction/Hotels/getLastHotelId.php'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return int.tryParse(data['hotel_id'].toString());
    }
    return null;
  }

  Future<void> uploadGalleryImages(int hotelId) async {
    var uri = Uri.parse('http://localhost/FinalProject_Graduaction/Hotels/uploadHotelGallery.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields['hotel_id'] = hotelId.toString();

    for (int i = 0; i < selectedGalleryImages.length && i < 10; i++) {
      final fieldName = 'photo${i + 1}';
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          fieldName,
          webGalleryImages[i],
          filename: "${fieldName}_${DateTime.now().millisecondsSinceEpoch}.jpg",
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(fieldName, selectedGalleryImages[i].path));
      }
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print("Gallery uploaded");
    } else {
      print("Gallery upload failed");
    }
  }

  void handleAddHotel() async {
    if (nameController.text.isEmpty || locationController.text.isEmpty || descriptionController.text.isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and choose an image.")));
      return;
    }

    setState(() => isLoading = true);

    final imageName = await uploadImage();
    if (imageName == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed.")));
      setState(() => isLoading = false);
      return;
    }

    final success = await addHotel(
      nameController.text,
      locationController.text,
      imageName,
      descriptionController.text,
    );

    if (success) {
      final hotelId = await getLastHotelId();
      if (hotelId != null && selectedGalleryImages.isNotEmpty) {
        await uploadGalleryImages(hotelId);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Hotel added successfully!")));

      nameController.clear();
      locationController.clear();
      descriptionController.clear();
      setState(() {
        selectedImage = null;
        webImage = null;
        selectedGalleryImages.clear();
        webGalleryImages.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to add hotel.")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Hotel"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildInputField(nameController, "Hotel Name", Icons.hotel),
            buildInputField(locationController, "Location", Icons.location_on),
            buildInputField(descriptionController, "Description", Icons.description, isMultiline: true),
            SizedBox(height: 20),
            buildImagePicker(),
            SizedBox(height: 10),
            buildGalleryPicker(),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : handleAddHotel,
              icon: Icon(Icons.add),
              label: Text("Add Hotel"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30)),
            ),
            if (isLoading) Padding(padding: EdgeInsets.only(top: 20), child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(TextEditingController controller, String label, IconData icon, {bool isMultiline = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: TextField(
          controller: controller,
          keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,
          maxLines: isMultiline ? 3 : 1,
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.teal),
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget buildImagePicker() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        children: [
          if (selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb ? Image.memory(webImage!, height: 150) : Image.file(selectedImage!, height: 150),
            ),
          TextButton.icon(
            onPressed: pickImage,
            icon: Icon(Icons.image, color: Colors.teal),
            label: Text("Choose Main Image"),
          ),
        ],
      ),
    );
  }

Widget buildGalleryPicker() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Hotel Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (selectedGalleryImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedGalleryImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.memory(webGalleryImages[index], width: 100, fit: BoxFit.cover)
                            : Image.file(selectedGalleryImages[index], width: 100, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGalleryImages.removeAt(index);
                            if (kIsWeb) webGalleryImages.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        TextButton.icon(
          onPressed: pickGalleryImages,
          icon: Icon(Icons.collections, color: Colors.teal),
          label: Text("Pick Gallery Images"),
        ),
      ],
    ),
  );
}

}
