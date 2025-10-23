// lib/screens/listings_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomoro/models/room_listing.dart';
import 'package:roomoro/screens/listing_details_screen.dart'; // Make sure this path is correct

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingScreen> {
  final Set<String> _likedListingIds = {};
  // Reference to the listings collection in Firestore
  final listingsRef = FirebaseFirestore.instance.collection('listings');

  // --- Like/Unlike Functionality ---
  // This function will be called when the heart icon is tapped
  Future<void> _toggleLike(String listingId, int currentLikes) async {
    // --- NEW: Update the local state for an instant UI change ---
    final isCurrentlyLiked = _likedListingIds.contains(listingId);
    setState(() {
      if (isCurrentlyLiked) {
        _likedListingIds.remove(listingId);
      } else {
        _likedListingIds.add(listingId);
      }
    });
    // ---

    // The database update logic remains the same
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docRef = listingsRef.doc(listingId);
        // Use the 'isCurrentlyLiked' status to determine the new count
        final newLikes = isCurrentlyLiked ? currentLikes - 1 : currentLikes + 1;
        transaction.update(docRef, {'likes': newLikes});
      });
      print("Toggled like for $listingId.");
    } catch (e) {
      print("Error toggling like: $e");
      // Optional: Revert the UI change if the database update fails
      setState(() {
        if (isCurrentlyLiked) {
          _likedListingIds.add(listingId);
        } else {
          _likedListingIds.remove(listingId);
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // A very light grey background
      appBar: _buildCustomAppBar(context),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          // This makes the filter bar scroll away with the content
          return [_buildFilterBar()];
        },
        body: _buildListingsStream(),
      ),
    );
  }

  // --- Custom AppBar Widget ---
  AppBar _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Icon(Icons.maps_home_work_outlined, color: Colors.grey[800], size: 28),
      ),
      title: Text(
        'Roomoro',
        style: TextStyle(
          color: Colors.grey[850],
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.grey[800], size: 28),
          onPressed: () {
            // TODO: Implement search functionality
            print("Search button tapped");
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // --- Filter Bar Widget ---
  SliverToBoxAdapter _buildFilterBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFilterChip("Price"),
            _buildFilterChip("Amenities"),
            _buildFilterChip("Location"),
          ],
        ),
      ),
    );
  }

  // Helper for creating a single filter chip
  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[800])),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }

  // --- Listings Stream Widget ---
  Widget _buildListingsStream() {
    return StreamBuilder<QuerySnapshot>(
      // Use a stream to listen for real-time changes in the 'listings' collection
      stream: listingsRef.where('isAvailable', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No available listings found."));
        }

        // Map the documents to RoomListing objects
        final listings = snapshot.data!.docs.map((doc) => RoomListing.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            // Here you would check if the user has liked this item before.
            // For this example, we'll just pass a dummy `false` value.
            final isLiked = _likedListingIds.contains(listing.id);
            return ListingCard(
              listing: listing,
              isLiked: isLiked, // You would get this from user's saved preferences
              onLikeToggle: () => _toggleLike(listing.id, listing.likes),
            );
          },
        );
      },
    );
  }
}

// --- Listing Card Widget ---
// This is the individual card for each room listing
class ListingCard extends StatelessWidget {
  final RoomListing listing;
  final bool isLiked;
  final VoidCallback onLikeToggle;

  const ListingCard({
    super.key,
    required this.listing,
    required this.isLiked,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the details screen when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsScreen(listing: listing),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                Image.network(
                  listing.thumbnailUrl1,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.hide_image_outlined, color: Colors.grey[400], size: 40)),
                  ),
                ),
                // Positioned heart icon
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onLikeToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.pink : Colors.black54,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Available", style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    listing.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${listing.price.toStringAsFixed(0)} / month',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const Divider(height: 24),
                  // Amenities row
                  Row(
                    children: [
                      _buildAmenityIcon(Icons.bed_outlined, "1 Bedroom"), // Placeholder
                      const SizedBox(width: 16),
                      if (listing.amenities.contains('wifi'))
                        _buildAmenityIcon(Icons.wifi, "Wi-Fi"),
                      const SizedBox(width: 16),
                      if (listing.amenities.contains('air condition'))
                        _buildAmenityIcon(Icons.ac_unit, "A/C"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for building an amenity icon with text
  Widget _buildAmenityIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}
