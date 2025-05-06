
// import 'dart:io' as io;
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';

// class TripRecommendationUserPage extends StatelessWidget {
//   const TripRecommendationUserPage({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         textTheme: const TextTheme(
//           titleLarge: TextStyle(fontWeight: FontWeight.bold),
//           bodyMedium: TextStyle(fontSize: 16),
//         ),
//       ),
//       home: const TripFormScreen(),
//     );
//   }
// }

// class TripFormScreen extends StatefulWidget {
//   const TripFormScreen({Key? key}) : super(key: key);

//   @override
//   _TripFormScreenState createState() => _TripFormScreenState();
// }

// class _TripFormScreenState extends State<TripFormScreen> {
//   final _formKey = GlobalKey<FormBuilderState>();
//   final ImagePicker _picker = ImagePicker();
  
//   XFile? _pickedFile;
//   Uint8List? _webImage;
//   String? _fileName;
//   bool _isLoading = false;

//   // دالة لاختيار الصورة
//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 80,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _pickedFile = pickedFile;
//           _fileName = pickedFile.name;
//         });

//         // للتعامل مع الصور في بيئة الويب
//         if (kIsWeb) {
//           final bytes = await pickedFile.readAsBytes();
//           setState(() {
//             _webImage = bytes;
//           });
//         }
        
//         // عرض رسالة نجاح
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم اختيار الصورة بنجاح: $_fileName'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('حدث خطأ أثناء اختيار الصورة: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // عرض الصورة المختارة
//   Widget _buildImagePreview() {
//     if (_pickedFile == null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.add_photo_alternate,
//               size: 60,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "لم يتم اختيار صورة بعد",
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }

//     // عرض الصورة حسب نوع البيئة
//     if (kIsWeb) {
//       // عرض الصورة في بيئة الويب
//       return _webImage != null
//           ? Image.memory(
//               _webImage!,
//               fit: BoxFit.cover,
//             )
//           : const Center(child: CircularProgressIndicator());
//     } else {
//       // عرض الصورة في بيئة الجهاز المحمول
//       return Image.file(
//         io.File(_pickedFile!.path),
//         fit: BoxFit.cover,
//       );
//     }
//   }

//   Future<void> _submitTrip() async {
//     if (!_formKey.currentState!.saveAndValidate()) return;
    
//     if (_pickedFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('يرجى اختيار صورة أولاً'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // بناء الطلب ليتوافق مع XAMPP وتخزين الصور في htdocs
//       FormData formData;
      
//       if (kIsWeb) {
//         // في بيئة الويب، نحول الصورة إلى بيانات قابلة للإرسال
//         formData = FormData.fromMap({
//           "user_id": "123",
//           "cities": _formKey.currentState!.value["cities"],
//           "places": _formKey.currentState!.value["places"],
//           "notes": _formKey.currentState!.value["notes"],
//           "image": await MultipartFile.fromBytes(
//             _webImage!,
//             filename: _fileName,
//           ),
//         });
//       } else {
//         // في بيئة الجهاز المحمول
//         formData = FormData.fromMap({
//           "user_id": "123",
//           "cities": _formKey.currentState!.value["cities"],
//           "places": _formKey.currentState!.value["places"],
//           "notes": _formKey.currentState!.value["notes"],
//           "image": await MultipartFile.fromFile(
//             _pickedFile!.path,
//             filename: _fileName,
//           ),
//         });
//       }

//       // طباعة معلومات التشخيص في وحدة التحكم
//       print('إرسال البيانات إلى: http://192.168.56.1/trip_API/upload_trip_suggestion.php');
//       print('اسم الملف: $_fileName');
      
//       // إرسال البيانات باستخدام Dio
//       var response = await Dio().post(
//         "http://192.168.56.1/trip_API/upload_trip_suggestion.php",
//         data: formData,
//         options: Options(
//           headers: {
//             "Accept": "application/json",
//             "Content-Type": "multipart/form-data",
//           },
//         ),
//       );

//       print('استجابة الخادم: ${response.data}');

//       if (response.data['success'] == true) {
//         _formKey.currentState!.reset();
//         setState(() {
//           _pickedFile = null;
//           _webImage = null;
//           _fileName = null;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم إرسال اقتراح الرحلة بنجاح! شكراً لمساهمتك'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('حدث خطأ أثناء إرسال الاقتراح: ${response.data['message'] ?? "يرجى المحاولة لاحقاً"}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       print('خطأ: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('فشل الاتصال بالسيرفر: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "اقتراح رحلة",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.teal.shade50, Colors.white],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               // رسالة ترحيبية
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 margin: const EdgeInsets.only(bottom: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.teal.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 1,
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: const Text(
//                   "نشكرك على اهتمامك بمشاركة تجربتك السياحية معنا! اقتراحاتك قيّمة وستساعدنا في إثراء محتوى موقعنا وتقديم تجارب سفر أفضل للجميع. سنأخذ اقتراحك بعين الاعتبار.",
//                   style: TextStyle(fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: FormBuilder(
//                         key: _formKey,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             FormBuilderTextField(
//                               name: "cities",
//                               decoration: InputDecoration(
//                                 labelText: "المدن",
//                                 prefixIcon: const Icon(Icons.location_city),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 hintText: "مثال: الرياض، جدة، أبها",
//                               ),
//                               textDirection: TextDirection.rtl,
//                               validator: FormBuilderValidators.compose([
//                                 FormBuilderValidators.required(errorText: "يرجى إدخال المدن"),
//                               ]),
//                             ),
//                             const SizedBox(height: 16),
//                             FormBuilderTextField(
//                               name: "places",
//                               decoration: InputDecoration(
//                                 labelText: "الأماكن",
//                                 prefixIcon: const Icon(Icons.place),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 hintText: "مثال: منتزه الملك فهد، شاطئ نصف القمر",
//                               ),
//                               textDirection: TextDirection.rtl,
//                               validator: FormBuilderValidators.compose([
//                                 FormBuilderValidators.required(errorText: "يرجى إدخال الأماكن"),
//                               ]),
//                             ),
//                             const SizedBox(height: 16),
//                             FormBuilderTextField(
//                               name: "notes",
//                               maxLines: 4,
//                               decoration: InputDecoration(
//                                 labelText: "ملاحظات وتفاصيل الرحلة",
//                                 prefixIcon: const Icon(Icons.note),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 alignLabelWithHint: true,
//                                 hintText: "شارك معنا خبرتك، نصائحك، أو أي تفاصيل مفيدة عن رحلتك...",
//                               ),
//                               textDirection: TextDirection.rtl,
//                               validator: FormBuilderValidators.compose([
//                                 FormBuilderValidators.required(errorText: "يرجى إدخال ملاحظات"),
//                                 FormBuilderValidators.minLength(20,
//                                     errorText: "الرجاء إدخال ملاحظات كافية (20 حرف على الأقل)"),
//                               ]),
//                             ),
//                             const SizedBox(height: 24),
//                             const Text(
//                               "إضافة صورة من الرحلة",
//                               style: TextStyle(
//                                 fontSize: 18, 
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               height: 200,
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey.shade300),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: _buildImagePreview(),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             ElevatedButton.icon(
//                               onPressed: _pickImage,
//                               icon: const Icon(Icons.photo_library),
//                               label: const Text("اختيار صورة من المعرض"),
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                             ),
//                             if (_pickedFile != null) ...[
//                               const SizedBox(height: 8),
//                               Text(
//                                 "الملف المحدد: $_fileName",
//                                 style: const TextStyle(color: Colors.grey),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _submitTrip,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Text("جاري الإرسال...", style: TextStyle(fontSize: 18)),
//                           ],
//                         )
//                       : const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.send),
//                             SizedBox(width: 10),
//                             Text("إرسال الاقتراح", style: TextStyle(fontSize: 18)),
//                           ],
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }