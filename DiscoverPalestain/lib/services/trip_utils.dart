// trip_utils.dart
import 'package:intl/intl.dart'; // لفرز الرحلات حسب التاريخ

// دالة لتجهير النص للمقارنة (تشيل فراغات + تحوله lowercase)
String normalize(String? text) {
  return text?.trim().toLowerCase() ?? '';
}

// فلترة حسب عنوان الرحلة
List<dynamic> filterTripsByTitle(List<dynamic> trips, String query) {
  final normalizedQuery = normalize(query);
  return trips.where((trip) {
    final title = normalize(trip['title']);
    return title.contains(normalizedQuery);
  }).toList();
}

// فلترة حسب المدينة
List<dynamic> filterTripsByCity(List<dynamic> trips, String query) {
  final normalizedQuery = normalize(query);
  return trips.where((trip) {
    final city = normalize(trip['city']);
    return city.contains(normalizedQuery);
  }).toList();
}

// فلترة حسب نوع الرحلة
List<dynamic> filterTripsByType(List<dynamic> trips, String query) {
  final normalizedQuery = normalize(query);
  return trips.where((trip) {
    final type = normalize(trip['type']);
    return type.contains(normalizedQuery);
  }).toList();
}

// ترتيب الرحلات حسب اقرب موعد
List<dynamic> sortTripsByDate(List<dynamic> trips) {
  trips.sort((a, b) {
    final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2100);
    final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2100);
    return dateA.compareTo(dateB);
  });
  return trips;
}
