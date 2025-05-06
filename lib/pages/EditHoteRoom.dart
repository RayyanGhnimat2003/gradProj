import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EditRoomAdminTab extends StatefulWidget {
  final int hotelId;
 final VoidCallback onRoomUpdated;

  EditRoomAdminTab({required this.hotelId, required this.onRoomUpdated});

  @override
  _EditRoomAdminTabState createState() => _EditRoomAdminTabState();
}

class _EditRoomAdminTabState extends State<EditRoomAdminTab> {
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now().add(Duration(days: 1));
    fetchAvailableRooms();
  }

  Future<void> fetchAvailableRooms() async {
    try {
      final response = await http.get(Uri.parse(
        'http://192.168.56.1/FinalProject_Graduaction/Hotels/getAvailableRooms.php?hotel_id=${widget.hotelId}&check_in=${DateFormat('yyyy-MM-dd').format(_checkInDate)}&check_out=${DateFormat('yyyy-MM-dd').format(_checkOutDate)}',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rooms = List<Map<String, dynamic>>.from(data['rooms'] ?? []);
        });
      }
    } catch (e) {
      print("Error fetching rooms: $e");
    }
  }

  Widget _buildDateButton(String label, DateTime date, bool isCheckIn) {
    return ElevatedButton.icon(
      onPressed: () async {
        final DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (selectedDate != null) {
          setState(() {
            if (isCheckIn) {
              _checkInDate = selectedDate;
              if (_checkOutDate.isBefore(_checkInDate)) {
                _checkOutDate = _checkInDate;
              }
            } else {
              _checkOutDate = selectedDate;
            }
          });
          fetchAvailableRooms();
        }
      },
      icon: Icon(Icons.date_range, color: Colors.white),
      label: Text(
        '$label: ${DateFormat('yyyy-MM-dd').format(date)}',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'Edit Hotel Rooms',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDateButton("Check-in", _checkInDate, true),
            _buildDateButton("Check-out", _checkOutDate, false),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: rooms.isEmpty
              ? Center(child: Text("No rooms available"))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.teal.shade100),
                      columns: const [
                        DataColumn(label: Text('Room Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text("Guests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text("Price", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text("Available", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      ],
                      rows: List.generate(rooms.length, (index) {
                        final room = rooms[index];
                        return DataRow(cells: [
                          DataCell(Text(room['room_type'] ?? '')),
                          DataCell(Text(room['description'] ?? '')),
                          DataCell(Text(room['guests'].toString())),
                          DataCell(Text("\$${room['price']}")),
                          DataCell(Text("${room['available_now']}")),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_red_eye, color: Colors.blue),
onPressed: () async {
  try {
    final response = await http.post(
      Uri.parse("http://192.168.56.1/FinalProject_Graduaction/Hotels/getBookingsByRoom.php"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"room_id": room['room_id']}), // ← تأكد أن room فيها room_id
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      final bookings = List<Map<String, dynamic>>.from(data['bookings']);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Room Bookings"),
            content: bookings.isEmpty
                ? Text("No bookings found for this room.")
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, index) {
                        final b = bookings[index];
                        return ListTile(
                          leading: Icon(Icons.event, color: Colors.teal),
                          title: Text("Booking #${b['booking_id']}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("User ID: ${b['user_id']}"),
                              Text("Check-in: ${b['check_in']}"),
                              Text("Check-out: ${b['check_out']}"),
                              Text("Rooms: ${b['quantity']}"),
                              Text("Total Price: \$${b['total_price']}"),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch bookings")),
      );
    }
  } catch (e) {
    print("Error fetching bookings: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error loading bookings.")),
    );
  }
}
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
onPressed: () async {
  final roomId = room['room_id'];

  final statsResponse = await http.post(
    Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Hotels/getRoomStats.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"room_id": roomId}),
  );

  final statsData = jsonDecode(statsResponse.body);
  int activeBookings = statsData['active_bookings'] ?? 0;

  // كنترولرز للحقول
  final roomTypeController = TextEditingController(text: room['room_type']);
  final descController = TextEditingController(text: room['description']);
  final guestsController = TextEditingController(text: room['guests']);
  final priceController = TextEditingController(text: room['price'].toString());
  final availableController = TextEditingController(text: room['available_now'].toString());

  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Edit Room"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activeBookings == 0) ...[
                  TextFormField(
                    controller: roomTypeController,
                    decoration: InputDecoration(labelText: "Room Type"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: InputDecoration(labelText: "Description"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: guestsController,
                    decoration: InputDecoration(labelText: "Guests"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Price"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ],
                TextFormField(
                  controller: availableController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Available Rooms"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
  child: Text("Save"),
  onPressed: () async {
    if (!_formKey.currentState!.validate()) return;

    final newAvailable = int.tryParse(availableController.text) ?? 0;
    final activeBookings = statsData['active_bookings'] ?? 0;

    if (newAvailable < activeBookings) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Available rooms can't be less than active bookings ($activeBookings)."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Hotels/updateRoomDetails.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "room_id": roomId,
        "room_type": roomTypeController.text,
        "description": descController.text,
        "guests": guestsController.text,
        "price": double.tryParse(priceController.text) ?? 0,
        "available_rooms": newAvailable,
      }),
    );

    final result = jsonDecode(response.body);
  Navigator.pop(context);
                      widget.onRoomUpdated(); // ← هذا يُعلم EditHotelScreen أن هناك تعديل
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );

    if (result['success'] == true) {
      fetchAvailableRooms();
    }
  },
),

        ],
      );
    },
  );
}
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
onPressed: () async {
  final roomId = room['room_id'];

  int deleteCount = 1;
  int maxDeletable = 0;

  // 1. جلب بيانات الغرفة قبل الحذف
  final statsResponse = await http.post(
    Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Hotels/getRoomStats.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"room_id": roomId}),
  );

  final statsData = jsonDecode(statsResponse.body);
  if (statsData['max_deletable'] == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No deletable rooms available right now.")),
    );
    return;
  }

  // تخزين البيانات
  int available = statsData['available_rooms'];
  int booked = statsData['active_bookings'];
  maxDeletable = statsData['max_deletable'];
  deleteCount = 1;

  // 2. عرض نافذة الحذف
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Delete Room Quantity"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Available Rooms: $available"),
                Text("Active Bookings: $booked"),
                Text("Maximum Deletable: $maxDeletable"),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: deleteCount > 1
                          ? () => setState(() => deleteCount--)
                          : null,
                    ),
                    Text(
                      "$deleteCount",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.green),
                      onPressed: deleteCount < maxDeletable
                          ? () => setState(() => deleteCount++)
                          : null,
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text("Delete"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final deleteResponse = await http.post(
                    Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Hotels/deleteRoomQuantity.php'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      "room_id": roomId,
                      "delete_count": deleteCount,
                    }),
                  );

                  final deleteData = jsonDecode(deleteResponse.body);
                    Navigator.pop(context, true);
 
                  if (deleteData['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(deleteData['message']),
                        backgroundColor: Colors.green,
                      ),
                    );
                    fetchAvailableRooms(); // تحديث القائمة
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(deleteData['message']),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
                              ),
                            ],
                          )),
                        ]);
                      }),
                    ),
                  ),
                ),
        ),
        SizedBox(height: 16),
   ElevatedButton.icon(
  onPressed: () {
    final _formKey = GlobalKey<FormState>();
    final roomTypeController = TextEditingController();
    final descriptionController = TextEditingController();
    final guestsController = TextEditingController(); // صار نص
    final priceController = TextEditingController();
    final availableRoomsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Room"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: roomTypeController,
                    decoration: InputDecoration(labelText: "Room Type"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter room type" : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: "Description"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter description" : null,
                  ),
                  TextFormField(
                    controller: guestsController,
                    decoration: InputDecoration(labelText: "Guests (e.g. 2 Adults)"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter guests info" : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Price"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter price" : null,
                  ),
                  TextFormField(
                    controller: availableRoomsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Available Rooms"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter availability" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final price = double.tryParse(priceController.text);
                  final available = int.tryParse(availableRoomsController.text);

                  if (price == null || available == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(child: Text("Please enter valid numeric values for price and availability.")),
                          ],
                        ),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  try {
                    final response = await http.post(
                      Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Hotels/addNewRoom.php'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        "hotel_id": widget.hotelId,
                        "room_type": roomTypeController.text,
                        "description": descriptionController.text,
                        "guests": guestsController.text, // نص
                        "price": price,
                        "available_rooms": available,
                      }),
                    );

                    final data = jsonDecode(response.body);
                    if (data['success'] == true) {
                     Navigator.pop(context);
                      widget.onRoomUpdated(); // ← هذا يُعلم EditHotelScreen أن هناك تعديل
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 12),
                              Expanded(child: Text("Room added successfully!")),
                            ],
                          ),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      fetchAvailableRooms();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to add room.")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  },
  icon: Icon(Icons.add),
  label: Text("Add New Room"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.teal,
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),

        SizedBox(height: 20),
      ],
    );
  }
}
