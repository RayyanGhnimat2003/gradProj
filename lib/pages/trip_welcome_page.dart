// lib/pages/trip_welcome_page.dart
import 'package:flutter/material.dart';

class TripWelcomePage extends StatelessWidget {
  final int tripId;

  // الحصول على tripId من خلال الموجه
  const TripWelcomePage({Key? key, required this.tripId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Welcome')),
      body: Center(
        child: Text(
          'أهلاً بالرحلة رقم: $tripId', // طباعة رقم الرحلة
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
