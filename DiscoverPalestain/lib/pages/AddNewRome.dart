
/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddRoomForm extends StatefulWidget {
  final int hotelId;

  const AddRoomForm({super.key, required this.hotelId});

  @override
  State<AddRoomForm> createState() => _AddRoomFormState();
}

class _AddRoomFormState extends State<AddRoomForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _roomTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availableRoomsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _addRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost/graduation/add_room.php'); 
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "hotel_id": widget.hotelId,
        "room_type": _roomTypeController.text,
        "description": _descriptionController.text,
        "guests": _guestsController.text,
        "price": double.tryParse(_priceController.text) ?? 0.0,
        "available_rooms": int.tryParse(_availableRoomsController.text) ?? 0,
      }),
    );

    final data = jsonDecode(response.body);

    setState(() => _isLoading = false);

    if (data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Room added successfully")),
      );
      _formKey.currentState!.reset();
      _roomTypeController.clear();
      _descriptionController.clear();
      _guestsController.clear();
      _priceController.clear();
      _availableRoomsController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${data['error']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add New Room"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _roomTypeController,
                decoration: InputDecoration(labelText: "Room Type"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _guestsController,
                decoration: InputDecoration(labelText: "Guests"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _availableRoomsController,
                decoration: InputDecoration(labelText: "Available Rooms"),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addRoom,
          child: _isLoading
              ? CircularProgressIndicator()
              : Text("Add Room"),
        ),
      ],
    );
  }
}
*/