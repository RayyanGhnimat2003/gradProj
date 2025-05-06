import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ShowUserBookingTab extends StatefulWidget {
  final int hotelId;

  ShowUserBookingTab({required this.hotelId});

  @override
  _ShowUserBookingTabState createState() => _ShowUserBookingTabState();
}

class _ShowUserBookingTabState extends State<ShowUserBookingTab> {
  late Future<List<Map<String, dynamic>>> bookingsFuture;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    bookingsFuture = fetchBookings();
  }

  Future<void> pickDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchBookings() async {
    final body = {
      "hotel_id": widget.hotelId,
      if (fromDate != null && toDate != null) ...{
        "from_date": fromDate!.toIso8601String().split("T")[0],
        "to_date": toDate!.toIso8601String().split("T")[0],
      }
    };

    final response = await http.post(
      Uri.parse('http://192.168.56.1/FinalProject_Graduaction/Hotels/getHotelBookings.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['bookings']);
    } else {
      throw Exception("Failed to load bookings");
    }
  }

void exportAsPdf(List<Map<String, dynamic>> bookings, double totalRevenue) async {
  final pdf = pw.Document();

  // تحميل صورة الشعار من الأصول (Asset)
  final imageLogo = pw.MemoryImage(
    (await rootBundle.load('images/p4.jpg')).buffer.asUint8List(),
  );

  final now = DateTime.now();
  final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        // شعار الفندق
        pw.Center(
          child: pw.Image(imageLogo, width: 100),
        ),
        pw.SizedBox(height: 10),

        // عنوان وتاريخ
        pw.Center(
          child: pw.Text("Hotel Booking Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Center(child: pw.Text("Date: $dateStr", style: pw.TextStyle(fontSize: 14))),
        pw.SizedBox(height: 16),

        // ملخص الأرقام
        pw.Text("Total Bookings: ${bookings.length}", style: pw.TextStyle(fontSize: 16)),
        pw.Text("Total Revenue: \$${totalRevenue.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 16)),
        pw.SizedBox(height: 16),

        // جدول الحجزات
        pw.Table.fromTextArray(
          border: pw.TableBorder.all(),
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          headers: [
            'Booking ID',
            'Name',
            'Email',
            'Phone',
            'Check-in',
            'Check-out',
            'Rooms',
            'Total Price'
          ],
          data: bookings.map((b) {
            return [
              b['booking_id'].toString(),
              '${b['firstName']} ${b['lastName']}',
              b['email'],
              b['phoneNumber'],
              b['check_in'],
              b['check_out'],
              b['quantity'].toString(),
              '\$${b['total_price']}'
            ];
          }).toList(),
        ),

        pw.SizedBox(height: 40),

        // توقيع أو ختم
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text("Approved by Admin", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 4),
              pw.Container(width: 100, height: 1, color: PdfColors.grey),
            ],
          ),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // واجهة اختيار التواريخ
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => pickDate(context, true),
                icon: Icon(Icons.date_range),
                label: Text(fromDate == null
                    ? "From Date"
                    : "From: ${fromDate!.toString().split(' ')[0]}"),
              ),
              ElevatedButton.icon(
                onPressed: () => pickDate(context, false),
                icon: Icon(Icons.date_range),
                label: Text(toDate == null
                    ? "To Date"
                    : "To: ${toDate!.toString().split(' ')[0]}"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    bookingsFuture = fetchBookings();
                  });
                },
                child: Text("Show Report"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ],
          ),
        ),

        // عرض النتائج
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: bookingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No bookings found."));
              }

              final bookings = snapshot.data!;
              final totalRevenue = bookings.fold<double>(
                0,
                (sum, b) =>
                    sum + double.tryParse(b['total_price'].toString())!,
              );

              return Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal),
                      ),
                      child: Text(
                        "Total Revenue: \$${totalRevenue.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        exportAsPdf(bookings, totalRevenue);
                      },
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text("Export as PDF"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 246, 248, 248)),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Booking #${booking['booking_id']}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 6),
                                Text("Name: ${booking['firstName']} ${booking['lastName']}"),
                                Text("Email: ${booking['email']}"),
                                Text("Phone: ${booking['phoneNumber']}"),
                                Divider(height: 20),
                                Text("Check-in: ${booking['check_in']}"),
                                Text("Check-out: ${booking['check_out']}"),
                                Text("Rooms: ${booking['quantity']}"),
                                Text("Total Price: \$${booking['total_price']}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
