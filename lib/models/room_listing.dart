// lib/models/room_listing.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomListing {
  final String id;
  final String title;
  final String description;
  final double price;
  final GeoPoint location;
  // Modified to support multiple images as per the new design
  final String thumbnailUrl1;
  final String thumbnailUrl2;
  final String thumbnailUrl3;
  final int likes;
  final List<String> amenities;
  final String ownerId;
  // Added new fields based on UI
  final String roomType;
  final int occupants;
  final String houseRules;
  final bool utilitiesIncluded;
  final bool isAvailable;


  RoomListing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.thumbnailUrl1,
    required this.thumbnailUrl2,
    required this.thumbnailUrl3,
    required this.likes,
    required this.amenities,
    required this.ownerId,
    required this.roomType,
    required this.occupants,
    required this.houseRules,
    required this.utilitiesIncluded,
    required this.isAvailable,
  });

  // Factory constructor to create a RoomListing from a Firestore document
  factory RoomListing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locationData = data['location'] as GeoPoint? ?? const GeoPoint(0, 0);

    return RoomListing(
      id: doc.id,
      title: data['title'] as String? ?? 'No Title',
      description: data['description'] as String? ?? 'No Description',
      price: (data['monthlyRentPhp'] as num?)?.toDouble() ?? 0.0,
      location: locationData,
      // Map the new thumbnail fields
      thumbnailUrl1: data['thumbnailUrl1'] as String? ?? '',
      thumbnailUrl2: data['thumbnailUrl2'] as String? ?? '',
      thumbnailUrl3: data['thumbnailUrl3'] as String? ?? '',
      likes: data['likes'] as int? ?? 0,
      amenities: List<String>.from(data['amenities'] as List? ?? []),
      ownerId: data['ownerId'] as String? ?? '',
      // Map the new fields
      roomType: data['roomType'] as String? ?? 'Private Room',
      occupants: data['occupants'] as int? ?? 1,
      houseRules: data['houseRules'] as String? ?? '',
      utilitiesIncluded: data['utilitiesIncluded'] as bool? ?? false,
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  // Method to convert a RoomListing object to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'monthlyRentPhp': price,
      'location': location,
      'thumbnailUrl1': thumbnailUrl1,
      'thumbnailUrl2': thumbnailUrl2,
      'thumbnailUrl3': thumbnailUrl3,
      'likes': likes,
      'amenities': amenities,
      'ownerId': ownerId,
      'roomType': roomType,
      'occupants': occupants,
      'houseRules': houseRules,
      'utilitiesIncluded': utilitiesIncluded,
      'isAvailable': isAvailable,
      // Optional: to know when it was created'
      'createdAt': FieldValue.serverTimestamp(), // Optional: to know when it was created
    };
  }
}
