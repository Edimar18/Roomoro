import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import your new model
import '../models/room_listing.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  final List<Marker> _userMarkers = []; // Renamed to be specific

  // --- NEW STATE FOR LISTINGS ---
  List<RoomListing> _roomListings = [];
  RoomListing? _selectedListing; // Track which listing is selected

  // dummy location sa user but will update later for real location
  final LatLng _userLocation = LatLng(8.4632, 124.6288);

  @override
  void initState() {
    print('hello');
    super.initState();
    _mapController = MapController();
    // Fetch room data when the widget is first created
    _fetchRoomListings();
  }

  // --- NEW: FUNCTION TO FETCH DATA FROM FIRESTORE ---
  Future<void> _fetchRoomListings() async {
    print('00');
    // Assuming you have a collection named 'room_listings'
    final snapshot = await FirebaseFirestore.instance.collection('listings').get();

    final listings = snapshot.docs.map((doc) => RoomListing.fromFirestore(doc)).toList();

    setState(() {
      _roomListings = listings;
    });
    print("Fetched ${_roomListings.length} room listings.");
  }


  //function for animating the map to the user's location
  void _animateToUserLocation()  {
    _mapController.move(_userLocation, 13.0);
    setState(() {
      // When centering on user, hide the listing info card
      _selectedListing = null;
      _userMarkers.clear();
      _userMarkers.add(
          Marker(
              width: 80.0,
              height: 80.0,
              point: _userLocation,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40.0,
              )
          )
      );
    });
  }


  // --- NEW: Build the list of markers from fetched data ---
  List<Marker> _buildRoomMarkers() {
    return _roomListings.map((listing) {
      return Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(listing.location.latitude, listing.location.longitude),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedListing = listing;
              // Clear the user's red pin when viewing a listing
              _userMarkers.clear();
            });
            print("Tapped on: ${listing.title}");
          },
          child: Icon(
            Icons.home_max_rounded, // A different icon for rooms
            color: _selectedListing?.id == listing.id ? Colors.purple : Colors.blue, // Highlight selected
            size: 40.0,
          ),
        ),
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    // Combine user markers and room markers
    final allMarkers = _buildRoomMarkers() + _userMarkers;

    return Scaffold(
        body: Stack(
            alignment: Alignment.bottomCenter, // Changed alignment for the info card
            children: [
              FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                      initialCenter: LatLng(8.4632, 124.6288),
                      initialZoom: 13.0,
                      onTap: (_, __) {
                        // Tapping on the map hides the info card
                        setState(() {
                          _selectedListing = null;
                        });
                      },
                      onMapReady: () {
                        print("Map is ready");
                      }
                  ),
                  children: [
                    TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.jegr.inc'
                    ),
                    // Use the combined list of all markers
                    MarkerLayer(markers: allMarkers)
                  ]
              ),
              // Search bar and filter button at the top
              _buildTopSearchBar(),

              // --- NEW: Floating "My Location" Button (Repositioned) ---
              Positioned(
                bottom: 24.0,
                right: 16.0,
                child: FloatingActionButton(
                  onPressed: _animateToUserLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.orangeAccent),
                ),
              ),

              // --- NEW: Listing Info Card (shows when a listing is selected) ---
              if (_selectedListing != null)
                _buildListingInfoCard(_selectedListing!),
            ]
        )
    );
  }

  // --- NEW: Extracted Search Bar to a separate method for cleanliness ---
  Widget _buildTopSearchBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            // ... (Your existing search bar Row code)
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: Offset(0, 3))
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                        hintText: "Search by area, landmark, or street",
                        prefixIcon: Icon(Icons.search, color: Colors.blue),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric( vertical: 12, horizontal: 20)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: Offset(0, 3))
                    ]),
                child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.blueAccent),
                    onPressed: () => print("Pressed action button")),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW: WIDGET FOR THE LISTING INFO CARD ---
  Widget _buildListingInfoCard(RoomListing listing) {
    return GestureDetector(
      onTap: () {
        // Optional: Navigate to a full details page
        print("Tapped on card for ${listing.title}");
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  listing.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  // Simple loading and error widgets
                  loadingBuilder: (context, child, progress) => progress == null ? child : Center(child: CircularProgressIndicator()),
                  errorBuilder: (context, error, stack) => Icon(Icons.broken_image, size: 50),
                ),
              ),
              const SizedBox(width: 10),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '₱${listing.price.toStringAsFixed(2)} / month',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ],
                ),
              ),
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedListing = null;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
