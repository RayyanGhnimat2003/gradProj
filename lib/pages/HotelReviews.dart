import 'package:flutter/material.dart';



class HotelReviews extends StatelessWidget {
  final int hotelId;

  HotelReviews({required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Reviews and Ratings for Hotel ID: $hotelId"));
  }

}
