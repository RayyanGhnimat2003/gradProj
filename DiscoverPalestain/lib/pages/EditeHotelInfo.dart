import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/EditRoomTabScreen.dart';
import 'package:http/http.dart' as http;

class EditHotelScreen extends StatefulWidget {
  final Map hotel;

  EditHotelScreen({required this.hotel});

  @override
  _EditHotelScreenState createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;

    bool _roomsEdited = false;

  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    nameController = TextEditingController(text: widget.hotel['hotel_Name']);
    locationController = TextEditingController(text: widget.hotel['hotel_Location']);
    descriptionController = TextEditingController(text: widget.hotel['hotel_Description']);
  }

  Future<void> updateHotel() async {
    final url = Uri.parse("http://192.168.56.1/FinalProject_Graduaction/Hotels/editHotel.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "hotel_ID": widget.hotel['hotel_ID'],
        "hotel_Name": nameController.text,
        "hotel_Location": locationController.text,
        "hotel_Description": descriptionController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text("Hotel updated successfully.")),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['error'] ?? "Update failed."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildHotelInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Hotel Name",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: locationController,
            decoration: InputDecoration(
              labelText: "Location",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: updateHotel,
            icon: Icon(Icons.save, size: 26, color: Colors.white),
            label: Text(
              "Save Changes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: Size(double.infinity, 50),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildRoomsTab() {
  return RoomTabScreen(
    hotel: widget.hotel,
    onRoomUpdated: () {
      setState(() {
         _roomsEdited = true; // ← صار تعديل على الغرف
      });
    },
  );
}



  Widget buildReviewsTab() {
    return Center(child: Text("\u2b50 View Reviews (Coming soon)", style: TextStyle(fontSize: 18)));
  }

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      Navigator.pop(context, _roomsEdited); // ← يرجّع true إذا تم تعديل الغرف
      return false; // يمنع الرجوع التلقائي لأننا رجعنا يدوي
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text("Edit Hotel"),
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Material(
            color: Colors.teal.shade100,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color.fromARGB(255, 0, 0, 0),
              unselectedLabelColor: Colors.teal.shade700,
              indicatorColor: const Color.fromARGB(255, 9, 9, 9),
              indicatorWeight: 4.0,
              tabs: [
                Tab(text: 'Edit Hotel Details'),
                Tab(text: 'Show and Edit Rooms'),
                Tab(text: 'Show and Edit Hotel Rating and Review'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildHotelInfoTab(),
          buildRoomsTab(),
          buildReviewsTab(),
        ],
      ),
    ),
  );
}

}
