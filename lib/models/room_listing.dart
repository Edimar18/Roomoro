// lib/models/room_listing.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomListing {
  final String id;
  final String title;
  final String description;
  final double price; // We'll map 'monthlyRentPhp' to this
  final GeoPoint location; // We will convert the string into a GeoPoint
  final String imageUrl; // We'll map 'thumbnailUrl' to this
  final int likes;
  final List<String> amenities;
  final String ownerId;

  RoomListing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.likes,
    required this.amenities,
    required this.ownerId,
  });

  // --- THIS IS THE KEY PART ---
  // Create a RoomListing object from a Firestore DocumentSnapshot
  factory RoomListing.fromFirestore(DocumentSnapshot doc) {
    // Cast the document data to a map
    final data = doc.data() as Map<String, dynamic>;

    final locationData = data['location'] as GeoPoint? ?? const GeoPoint(0, 0);


    // --- 2. MAP FIREBASE FIELDS TO YOUR MODEL ---
    return RoomListing(
      id: doc.id,
      // Use the field names from your Firebase screenshot
      title: data['title'] as String? ?? 'No Title',
      description: data['description'] as String? ?? 'No Description',
      price: (data['monthlyRentPhp'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['thumbnailUrl'] as String? ?? '', // Use 'thumbnailUrl'
      likes: data['likes'] as int? ?? 0,
      amenities: List<String>.from(data['amenities'] as List? ?? []),
      ownerId: data['ownerId'] as String? ?? '',
      // Assign the parsed GeoPoint
      location: locationData,
    );
  }
}
