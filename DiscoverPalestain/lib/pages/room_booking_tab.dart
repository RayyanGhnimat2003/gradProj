import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RoomBookingTab extends StatefulWidget {
  final int hotelId;
  RoomBookingTab({required this.hotelId});

  @override
  _RoomBookingTabState createState() => _RoomBookingTabState();
}

class _RoomBookingTabState extends State<RoomBookingTab> {
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  List<Map<String, dynamic>> rooms = [];
  List<int> roomQuantities = [];
  int? selectedGuestCount;

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
        'http://localhost/FinalProject_Graduaction/Hotels/getAvailableRooms.php?hotel_id=${widget.hotelId}&check_in=${DateFormat('yyyy-MM-dd').format(_checkInDate)}&check_out=${DateFormat('yyyy-MM-dd').format(_checkOutDate)}',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rooms'] != null && data['rooms'].isNotEmpty) {
          setState(() {
            rooms = List<Map<String, dynamic>>.from(data['rooms'])
                .where((room) => (int.tryParse(room['available_now'].toString()) ?? 0) > 0)
                .toList();
            roomQuantities = List<int>.filled(rooms.length, 0);
          });
        } else {
          setState(() {
            rooms = [];
            roomQuantities = [];
          });
        }
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  double get totalPrice {
    double total = 0.0;
    int numberOfDays = _checkOutDate.difference(_checkInDate).inDays;
    numberOfDays = numberOfDays == 0 ? 1 : numberOfDays;
    for (int i = 0; i < rooms.length; i++) {
      total += roomQuantities[i] * double.parse(rooms[i]['price'].toString()) * numberOfDays;
    }
    return total;
  }

  bool get isRoomSelected => roomQuantities.any((q) => q > 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('🛏️ Room Booking', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
          SizedBox(height: 20),
          Text('Please select your check-in and check-out dates to see available rooms.',
              style: TextStyle(fontSize: 16, color: Colors.red.shade700, fontWeight: FontWeight.w500)),
          SizedBox(height: 10),
          buildDateRangePickerButton(),
          SizedBox(height: 10),
         Row(
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text(
      "Filter by Guests:",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.teal.shade800,
      ),
    ),
    SizedBox(width: 16),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedGuestCount,
          hint: Text("Select Guests", style: TextStyle(fontSize: 15)),
          onChanged: (value) => setState(() => selectedGuestCount = value),
          items: [
            DropdownMenuItem(value: null, child: Text("👥 All Guests")),
            DropdownMenuItem(value: 1, child: Text("👤  1 Guest")),
            DropdownMenuItem(value: 2, child: Text("👤👤  2 Guests")),
            DropdownMenuItem(value: 3, child: Text("👤👤👤  3 Guests")),
            DropdownMenuItem(value: 4, child: Text("👤👤👤👤  4 Guests")),
          ],
        ),
      ),
    ),
  ],
),

          SizedBox(height: 10),
          Divider(height: 40, thickness: 1.5),
          Expanded(
            child: rooms.isEmpty
                ? Center(child: CircularProgressIndicator(color: Colors.teal))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.teal.shade100),
                        dataRowColor: MaterialStateProperty.resolveWith((states) =>
                            states.contains(MaterialState.hovered) ? Colors.teal.shade50 : Colors.white),
                        columnSpacing: 40,
                        dataRowHeight: 80,
                        columns: const [
                          DataColumn(label: Text('Room Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                          DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                          DataColumn(label: Text('Guests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                          DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                          DataColumn(label: Text('Select Rooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                          DataColumn(label: Text('Available Rooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        ],
                        rows: List.generate(rooms.length, (index) {
                          final room = rooms[index];
                          final guestCount = '👤'.allMatches(room['guests'].toString()).length;
                          if (selectedGuestCount != null && guestCount != selectedGuestCount) return null;
                          return DataRow(cells: [
                            DataCell(Text(room['room_type'].trim(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                            DataCell(Text(room['description'].trim(), style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                            DataCell(Text(room['guests'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                            DataCell(Text('\$${room['price']}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold))),
                            DataCell(Row(children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => setState(() => roomQuantities[index] = roomQuantities[index] > 0 ? roomQuantities[index] - 1 : 0),
                              ),
                              Text('${roomQuantities[index]}', style: TextStyle(fontSize: 16)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                onPressed: () => setState(() {
                                  int available = int.tryParse(room['available_now'].toString()) ?? 0;
                                  if (roomQuantities[index] < available) roomQuantities[index]++;
                                }),
                              ),
                            ])),
                            DataCell(Row(children: [
                              Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                              SizedBox(width: 4),
                              Text('Only ${room['available_now']} rooms left!', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                            ])),
                          ]);
                        }).whereType<DataRow>().toList(),
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 20),
          if (isRoomSelected)
            Text('Total Price: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isRoomSelected ? showConfirmationDialog : null,
            child: Text('Book Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRoomSelected ? Colors.teal : Colors.teal.shade100,
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateRangePickerButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
          initialDateRange: DateTimeRange(start: _checkInDate, end: _checkOutDate),
          builder: (context, child) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600, maxHeight: 550),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  child: child,
                ),
              ),
            );
          },
        );
        if (picked != null) {
          setState(() {
            _checkInDate = picked.start;
            _checkOutDate = picked.end.isAtSameMomentAs(picked.start) ? picked.start.add(Duration(days: 1)) : picked.end;
          });
          fetchAvailableRooms();
        }
      },
      icon: Icon(Icons.date_range, color: Colors.white),
      label: Text(
        'Check-in: ${DateFormat('yyyy-MM-dd').format(_checkInDate)}  |  Check-out: ${DateFormat('yyyy-MM-dd').format(_checkOutDate)}',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  Future<void> showConfirmationDialog() async {
    List<Map<String, dynamic>> selectedRooms = [];
    for (int i = 0; i < rooms.length; i++) {
      if (roomQuantities[i] > 0) {
        selectedRooms.add({
          'room_id': rooms[i]['room_id'],
          'room_type': rooms[i]['room_type'],
          'quantity': roomQuantities[i],
          'price': rooms[i]['price'],
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Your Booking'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check-in: ${DateFormat('yyyy-MM-dd').format(_checkInDate)}'),
                Text('Check-out: ${DateFormat('yyyy-MM-dd').format(_checkOutDate)}'),
                Divider(),
                ...selectedRooms.map((room) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('${room['room_type']} - Qty: ${room['quantity']} - \$${room['price']} per night'),
                    )),
                Divider(),
                Text('Total Price: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              ],
            ),
          ),
          actions: [
            TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await submitBooking(selectedRooms);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> submitBooking(List<Map<String, dynamic>> selectedRooms) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Hotels/bookRoom.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'hotel_id': widget.hotelId,
          'user_id': 1,
          'check_in': DateFormat('yyyy-MM-dd').format(_checkInDate),
          'check_out': DateFormat('yyyy-MM-dd').format(_checkOutDate),
          'rooms': selectedRooms.map((room) => {
            'room_id': room['room_id'],
            'quantity': room['quantity'],
          }).toList(),
        }),
      );

      final result = json.decode(response.body);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking Successful!')));
        fetchAvailableRooms();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking Failed: $e')));
    }
  }
}
