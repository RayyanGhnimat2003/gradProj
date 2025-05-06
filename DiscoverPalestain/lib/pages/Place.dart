class Place {
  final int id;
  final int cityId;
  final String name; // حقل غير قابل لأن يكون null
  final String imageUrl; // حقل غير قابل لأن يكون null
  final String description; // قابل لأن يكون null
  final String location; // حقل غير قابل لأن يكون null
  final String area; // حقل غير قابل لأن يكون null
  final String category; // حقل غير قابل لأن يكون null
  final double latitude; // حقل غير قابل لأن يكون null
  final double longitude; // حقل غير قابل لأن يكون null
  final String history; // قابل لأن يكون null

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
    this.history = '', // يتم إعطاء قيمة افتراضية إذا كانت null
  });
factory Place.fromMap(Map<String, dynamic> map) {
  String rawImageUrl = map['image_url'] ?? '';
  String fixedImageUrl = rawImageUrl.startsWith('http')
      ? rawImageUrl
      : 'http://192.168.1.141/FinalProject_Graduaction/City/images/$rawImageUrl';

  return Place(
    id: map['id'] ?? 0,
    cityId: map['city_id'] ?? 0,
    name: map['name'] ?? 'Unnamed Place', // إلزامي
    description: map['description'] ?? '',
    imageUrl: fixedImageUrl.isNotEmpty ? fixedImageUrl : 'http://192.168.1.141/FinalProject_Graduaction/Resturants/images/default.jpg', // إلزامي
    location: map['location'] ?? 'Unknown Location', // إلزامي
    area: map['area'] ?? '',
    category: map['category'] ?? '',
    latitude: double.tryParse(map['latitude'].toString()) ?? 0.0,
    longitude: double.tryParse(map['longitude'].toString()) ?? 0.0,
    history: map['history'] ?? '',
  );
}


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'city_id': cityId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'location': location,
      'area': area,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'history': history, // يمكن أن يكون null
    };
  }
}
