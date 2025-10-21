// lib/screens/listing_details_screen.dart
import 'package:flutter/material.dart';
import '../models/room_listing.dart';

class ListingDetailsScreen extends StatelessWidget {
  final RoomListing listing;

  const ListingDetailsScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for the image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  listing.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                listing.title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '₱${listing.price.toStringAsFixed(2)} / month',
                style: TextStyle(fontSize: 20, color: Colors.teal[700], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.pink, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${listing.likes} likes',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Divider(height: 40),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                listing.description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
              ),
              // You can add more details here, like amenities
            ],
          ),
        ),
      ),
    );
  }
}
