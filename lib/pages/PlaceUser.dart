class Place {
  final int id;
  final int cityId;
  final String name;
  final String imageUrl;
  final String description;
  final String location;
  final String area;
  final String category;
  final double latitude;
  final double longitude;
  final String history;  // إضافة تاريخ المكان

  Place({
    required this.id,
    required this.cityId,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.location,
    required this.area,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.history,  // إضافة التاريخ هنا
  });

  factory Place.fromMap(Map<String, dynamic> map) {
    String rawImageUrl = map['image_url'];
    String fixedImageUrl = rawImageUrl.startsWith('http')
        ? rawImageUrl
        : 'http://192.168.149.1/FinalProject_Graduaction/City/images/$rawImageUrl';

    return Place(
      id: map['id'],
      cityId: map['city_id'],
      name: map['name'],
      imageUrl: fixedImageUrl,
      description: map['description'],
      location: map['location'],
      area: map['area'].toString(),
     category: map['category'],
      latitude: map['latitude'].toDouble(),
      longitude: map['longitude'].toDouble(),
      history: map['history'] ,  // إضافة التاريخ من الـ API
    );
  }
}
