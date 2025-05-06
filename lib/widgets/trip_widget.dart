// import 'package:flutter/material.dart';


// // ودجت لعرض تفاصيل الرحلة
// class TripWidget extends StatelessWidget {
//   final String title;
//   final String imageUrl;
//   final String date;
//   final String startTime;
//   final int tripId;

//   // بناء الودجت
//   const TripWidget({
//     Key? key,
//     required this.title,
//    required this.imageUrl,
//     required this.date,
//     required this.startTime,
//     required this.tripId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
      
//       child: Card(
//         elevation: 5,
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(15),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: 200,
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "Date: $date",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     Text(
//                       "Time: $startTime",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class TripWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String date;
  final String startTime;
  final int tripId;
  final VoidCallback? onTap;

  const TripWidget({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.startTime,
    required this.tripId,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4, // Reduced elevation for a cleaner look
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with better aspect ratio
            AspectRatio(
              aspectRatio: 16 / 9, // Standard video aspect ratio - more balanced
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.teal.shade100,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.teal.shade50,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Title section with more padding and larger text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.teal.shade100, width: 1),
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Trip details section with better proportions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date and time with clear spacing
                  Expanded(
                    child: Row(
                      children: [
                        // Date section
                        Icon(Icons.calendar_today, color: Colors.teal, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Time section
                        Icon(Icons.access_time, color: Colors.teal, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          startTime,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Button with proper size and padding
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward, color: Colors.teal, size: 16),
                    label: const Text(
                      "عرض التفاصيل",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: Colors.teal.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}