class City {
  final int id;
  final String name; // حقل غير قابل لأن يكون null
  final String description; // قابل لأن يكون null
  final String imageUrl; // حقل غير قابل لأن يكون null
  final List<String> imageUrls; // قائمة لصور المدينة
  final String videoUrl; // قابل لأن يكون null
  final String governorate; // قابل لأن يكون null
  final int population; // حقل غير قابل لأن يكون null
  final String area; // حقل غير قابل لأن يكون null
  final String famousSites; // قابل لأن يكون null
  final String historicalFacts; // قابل لأن يكون null
  final String localProducts; // قابل لأن يكون null
  final String location; // حقل غير قابل لأن يكون null

  City({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.imageUrls, // قائمة صور
    required this.population,
    required this.area,
    required this.location,
    this.description = '', // يتم إعطاء قيمة افتراضية إذا كانت null
    this.videoUrl = '',
    this.governorate = '',
    this.famousSites = '',
    this.historicalFacts = '',
    this.localProducts = '',
  });

  factory City.fromMap(Map<String, dynamic> map) {
    String rawImageUrl = map['imageUrl'];
    String fixedImageUrl = rawImageUrl.startsWith('http')
        ? rawImageUrl
        : 'http://192.168.149.1/FinalProject_Graduaction/City/images/$rawImageUrl';

    // Parsing the imageUrls as a list
    List<String> images = [];
    if (map['imageUrls'] != null) {
      images = List<String>.from(map['imageUrls']);
    }

    return City(
      id: int.parse(map['id'].toString()),
      name: map['name'], // يجب أن يكون موجودًا دائمًا
      description: map['description'] ?? '', // إذا كانت null يتم تعيين قيمة فارغة
      imageUrl: fixedImageUrl, // يجب أن يكون موجودًا دائمًا
      imageUrls: images, // قائمة الصور
      videoUrl: map['videoUrl'] ?? '',
      governorate: map['governorate'] ?? '',
      population: int.tryParse(map['population'].toString()) ?? 0, // يجب أن يكون موجودًا دائمًا
      area: map['area'] ?? '', // يجب أن يكون موجودًا دائمًا
      famousSites: map['famousSites'] ?? '',
      historicalFacts: map['historicalFacts'] ?? '',
      localProducts: map['localProducts'] ?? '',
      location: map['location'] ?? '', // يجب أن يكون موجودًا دائمًا
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls, // إضافة قائمة الصور
      'videoUrl': videoUrl,
      'governorate': governorate,
      'population': population,
      'area': area,
      'famousSites': famousSites,
      'historicalFacts': historicalFacts,
      'localProducts': localProducts,
      'location': location, // الحقل الذي لا يمكن أن يكون null
    };
  }
}
