// file: script/add_listings.dart

// Use a conditional import to avoid Flutter UI dependencies
// when running in a pure Dart environment.
import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORTANT: Use the package-based import. It's more reliable.
import 'package:roomoro/firebase_options.dart';

// The main function of our script
Future<void> main() async {
  // This try-finally block ensures the script closes properly.
  try {
    print("🚀 Initializing Firebase for command-line script...");

    // 1. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Initialized.");

    // Get a reference to your 'listings' collection
    final collection = FirebaseFirestore.instance.collection('listings');

    // 2. Define the data for the new listing
    final newListingData = {
      'title': 'Quiet Corner Room near Liceo',
      'description': 'A comfortable and quiet room suitable for students and reviewers. Fully furnished.',
      'monthlyRentPhp': 4200,
      'thumbnailUrl': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=2070&auto=format&fit=crop',
      'likes': 35,
      'amenities': ['wifi', 'air condition', 'desk'],
      'ownerId': 'owner_liceo_456',
      'address': 'RN Pelaez Blvd',
      'cityArea': 'Kauswagan',
      'isAvailable': true,
      'roomType': 'solo',
      'rules': 'no loud music after 10 PM',
      'updatedAt': Timestamp.now(),
      'location': const GeoPoint(8.483, 124.639), // Example: Near Liceo de Cagayan University
    };

    // 3. Add the data to the collection
    print("⏳ Adding new listing to Firestore...");
    await collection.add(newListingData);
    print("✅ SUCCESS: New listing '${newListingData['title']}' added!");

  } catch (e) {
    print("❌ ERROR: Failed to add listing. Reason: $e");
  } finally {
    // 4. IMPORTANT: Force exit the script
    // This is necessary because the Firebase connection can keep the script alive.
    print("Script finished. Exiting.");
    exit(0);
  }
}
