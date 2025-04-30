// شغال بدون دفع 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // لتحويل البيانات إلى JSON

class TripBookingPage extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const TripBookingPage({super.key, required this.tripData});

  @override
  _TripBookingPageState createState() => _TripBookingPageState();
}

class _TripBookingPageState extends State<TripBookingPage> {
  int numberOfSeats = 1;
  String errorMessage = "";  // متغير لتخزين الرسالة عند الوصول للعدد الأقصى للمقاعد

  // دالة لزيادة عدد المقاعد
  void increaseSeats() {
    if (numberOfSeats < widget.tripData["availableSeats"]) {
      setState(() {
        numberOfSeats++;
        errorMessage = ""; // مسح الرسالة عند زيادة المقاعد بشكل طبيعي
      });
    } else {
      // في حال الوصول للعدد الأقصى للمقاعد المتاحة
      setState(() {
        errorMessage = "عذرًا، المتاح فقط ${widget.tripData["availableSeats"]} مقعد.";
      });
    }
  }

  // دالة لإرسال البيانات إلى الـ API
  Future<void> _bookTrip() async {
    final String url = 'http://192.168.56.1/trip_API/book_trip.php'; 

    // تحويل seatPrice إلى double
    double seatPrice = double.parse(widget.tripData["seatPrice"].toString());
    // حساب totalPrice
    num totalPrice = numberOfSeats * seatPrice;

    print("Sending booking data...");
    print("User: ${widget.tripData['userName']}");
    print("Trip ID: ${widget.tripData['tripId']}");
    print("Seats: $numberOfSeats");
    print("Total Price: $totalPrice");

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id':"3",
        'trip_id': widget.tripData["tripId"],
        'number_of_seats': numberOfSeats,
        'total_price': totalPrice,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم حجز الرحلة بنجاح!")),
      );
      print("Booking successful");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الحجز، حاول مرة أخرى.")),
      );
      print("Booking failed with status code: ${response.statusCode}");
    }
  }

  // دالة لعرض مربع الحوار لتأكيد الحجز
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تأكيد الحجز"),
          content: Text("هل أنت متأكد أنك تريد حجز $numberOfSeats مقاعد؟"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // إغلاق مربع الحوار
              },
              child: Text("لا"),
            ),
            TextButton(
              onPressed: () {
                // إغلاق مربع الحوار
                Navigator.of(context).pop();

                // إرسال البيانات إلى الـ API بعد التأكيد
                _bookTrip();
              },
              child: Text("نعم"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.tripData["userName"];
    String tripName = widget.tripData["tripName"];
    String tripImage = widget.tripData["tripImage"];
    double seatPrice = double.parse(widget.tripData["seatPrice"].toString());
    String tripId = widget.tripData["tripId"];
    int availableSeats = int.parse(widget.tripData["availableSeats"].toString());
    double totalPrice = numberOfSeats * seatPrice;

    print("Trip Data:");
    print("User Name: $userName");
    print("Trip Name: $tripName");
    print("Trip Image: $tripImage");
    print("Seat Price: $seatPrice");
    print("Available Seats: $availableSeats");
    print("Total Price: $totalPrice");

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الحجز')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.network(tripImage, width: double.infinity, height: 250, fit: BoxFit.cover),
                Container(width: double.infinity, height: 250, color: Colors.black.withOpacity(0.4)),
                Column(
                  children: [
                    Text("أهلاً بك يا $userName!", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("يشرفنا أن تحجز معنا في: ", style: TextStyle(fontSize: 18, color: Colors.white)),
                    Text(tripName, style: TextStyle(fontSize: 26, color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("عدد المقاعد:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: numberOfSeats > 1 ? () => setState(() => numberOfSeats--) : null,
                          ),
                          Text(numberOfSeats.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.green),
                            onPressed: numberOfSeats < availableSeats ? increaseSeats : null,
                          ),
                          SizedBox(width: 10),
                          Text("المقاعد المتاحة: $availableSeats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ],
                      ),
                      // إضافة النص الذي يظهر عندما يتجاوز عدد المقاعد المتاحة
                      if (errorMessage.isNotEmpty) 
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            errorMessage,
                            style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "السعر الإجمالي: ${totalPrice.toStringAsFixed(2)} \$",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _showConfirmationDialog();  // عرض مربع الحوار لتأكيد الحجز
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            backgroundColor: Colors.teal,
                          ),
                          child: Text("إتمام الحجز", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';

// class TripBookingPage extends StatefulWidget {
//   final Map<String, dynamic> tripData;

//   const TripBookingPage({super.key, required this.tripData});

//   @override
//   _TripBookingPageState createState() => _TripBookingPageState();
// }

// class _TripBookingPageState extends State<TripBookingPage> {
//   int numberOfSeats = 1;
//   String errorMessage = "";

//   void increaseSeats() {
//     if (numberOfSeats < widget.tripData["availableSeats"]) {
//       setState(() {
//         numberOfSeats++;
//         errorMessage = "";
//       });
//     } else {
//       setState(() {
//         errorMessage = "عذرًا، المتاح فقط ${widget.tripData["availableSeats"]} مقعد.";
//       });
//     }
//   }

//   Future<void> _bookTrip() async {
//     final String url = 'http://192.168.56.1/trip_API/book_trip.php';
//     double seatPrice = double.parse(widget.tripData["seatPrice"].toString());
//     num totalPrice = numberOfSeats * seatPrice;

//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'user_id': "3",
//         'trip_id': widget.tripData["tripId"],
//         'number_of_seats': numberOfSeats,
//         'total_price': totalPrice,
//       }),
//     );

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("تم حجز الرحلة بنجاح!")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("فشل الحجز، حاول مرة أخرى.")),
//       );
//     }
//   }

//   void handlePayment(BuildContext context, double totalPrice, int numberOfSeats, Map<String, dynamic> tripData) async {
//     final String? clientSecret = await getClientSecretFromBackend(totalPrice);

//     if (clientSecret == null) {
//       print("❌ لم يتم العثور على Client Secret");
//       return;
//     }

//     if (kIsWeb) {
//       final Uri paymentUrl = Uri.parse(
//         "http://192.168.56.1/trip_API/payment_web.html"
//       ).replace(queryParameters: {
//         'amount': totalPrice.toStringAsFixed(2),
//         'clientSecret': clientSecret,
//       });

//       print("✅ فتح صفحة الدفع على الويب مع الكلاينت سيكرت: $paymentUrl");

//       if (await canLaunchUrl(paymentUrl)) {
//         await launchUrl(paymentUrl, mode: LaunchMode.externalApplication);
//       } else {
//         print('❌ لا يمكن فتح الرابط');
//       }
//     } else {
//       Navigator.pushNamed(
//         context,
//         '/payment',
//         arguments: {
//           'amount': totalPrice,
//           'seats': numberOfSeats,
//           'tripId': tripData["tripId"],
//           'clientSecret': clientSecret,
//         },
//       );
//     }
//   }

//   Future<String?> getClientSecretFromBackend(double totalPrice) async {
//     final url = Uri.parse('http://192.168.56.1/trip_API/create-payment-intent.php');

//     try {
//       final Map<String, dynamic> body = {
//         'amount': (totalPrice * 100).toInt(),
//         'currency': 'usd',
//       };

//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['clientSecret'];
//       } else {
//         print("❌ حدث خطأ أثناء طلب الـ clientSecret: ${response.statusCode}");
//         print("الرد من السيرفر: ${response.body}");
//         return null;
//       }
//     } catch (e) {
//       print("❌ خطأ أثناء الاتصال بالسيرفر: $e");
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String userName = widget.tripData["userName"];
//     String tripName = widget.tripData["tripName"];
//     String tripImage = widget.tripData["tripImage"];
//     double seatPrice = double.parse(widget.tripData["seatPrice"].toString());
//     int availableSeats = int.parse(widget.tripData["availableSeats"].toString());
//     double totalPrice = numberOfSeats * seatPrice;

//     return Scaffold(
//       appBar: AppBar(title: const Text('إتمام الحجز')),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Image.network(tripImage, width: double.infinity, height: 250, fit: BoxFit.cover),
//                 Container(width: double.infinity, height: 250, color: Colors.black.withOpacity(0.4)),
//                 Column(
//                   children: [
//                     Text("أهلاً بك يا $userName!", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
//                     Text("يشرفنا أن تحجز معنا في: ", style: TextStyle(fontSize: 18, color: Colors.white)),
//                     Text(tripName, style: TextStyle(fontSize: 26, color: Colors.orange, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Card(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 elevation: 5,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("عدد المقاعد:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                       SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.remove_circle, color: Colors.red),
//                             onPressed: numberOfSeats > 1 ? () => setState(() => numberOfSeats--) : null,
//                           ),
//                           Text(numberOfSeats.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                           IconButton(
//                             icon: Icon(Icons.add_circle, color: Colors.green),
//                             onPressed: numberOfSeats < availableSeats ? increaseSeats : null,
//                           ),
//                           SizedBox(width: 10),
//                           Text("المقاعد المتاحة: $availableSeats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
//                         ],
//                       ),
//                       if (errorMessage.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 10),
//                           child: Text(
//                             errorMessage,
//                             style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       SizedBox(height: 20),
//                       Center(
//                         child: Text(
//                           "السعر الإجمالي: ${totalPrice.toStringAsFixed(2)} \$",
//                           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Center(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             handlePayment(context, totalPrice, numberOfSeats, widget.tripData); // ✅ هنا صححت الاستدعاء
//                           },
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                             backgroundColor: Colors.teal,
//                           ),
//                           child: Text("إتمام الحجز", style: TextStyle(fontSize: 18, color: Colors.white)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
