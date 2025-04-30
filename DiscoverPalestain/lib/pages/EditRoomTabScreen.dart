import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ShowUserBooking.dart';
import 'EditHoteRoom.dart'; // استدعاء الواجهة الحقيقية لتعديل الغرف

class RoomTabScreen extends StatelessWidget {
  final hotel;
   final VoidCallback onRoomUpdated;

  RoomTabScreen({required this.hotel, required this.onRoomUpdated});


  @override
  Widget build(BuildContext context) {
    int hotelId = int.parse(hotel['hotel_ID'].toString()); // استخراج ID

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(""),
          backgroundColor: Colors.teal,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 16),
            tabs: [
              Tab(text: "Show User Booking"),
              Tab(text: "Edit Room"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ShowUserBookingTab(hotelId: hotelId),
            EditRoomAdminTab(hotelId: hotelId, onRoomUpdated: onRoomUpdated),
          ],
        ),
      ),
    );
  }
}