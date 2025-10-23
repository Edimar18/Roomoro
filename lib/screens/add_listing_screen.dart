import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

// Assuming room_listing.dart is in lib/models/
import '../models/room_listing.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form Data
  final _formKey = GlobalKey<FormState>();
  String _listingTitle = '';
  String _roomType = 'Private Room';
  int _numberOfOccupants = 1;
  final List<XFile> _images = [];
  LatLng? _selectedLocation;
  final Set<String> _amenities = {};
  String _description = '';
  String _houseRules = '';
  double _monthlyRent = 0.0;
  bool _includeUtilities = false;

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  // Placeholder for the submit function
  Future<void> _submitListing() async {
    // Validate the form, check for images, and ensure a location is pinned.

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one photo.')),
      );
      return; // Stop if no images are selected
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pin the location of your listing on the map.')),
      );
      return; // Stop if location isn't set
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // --- START OF CLOUDINARY UPLOAD LOGIC ---
      // IMPORTANT: Replace with your Cloudinary details
      final cloudinary = CloudinaryPublic('deimnujei', 'Roomoro', cache: false);

      List<String> imageUrls = [];
      for (var imageFile in _images) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
        );
        imageUrls.add(response.secureUrl);
      }
      // --- END OF CLOUDINARY UPLOAD LOGIC ---

      final newListing = RoomListing(
        id: '', // Firestore will generate this
        title: _listingTitle,
        description: _description,
        price: _monthlyRent,
        location: GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
        // Use the real URLs from Cloudinary, padding with empty strings if needed
        thumbnailUrl1: imageUrls.isNotEmpty ? imageUrls[0] : '',
        thumbnailUrl2: imageUrls.length > 1 ? imageUrls[1] : '',
        thumbnailUrl3: imageUrls.length > 2 ? imageUrls[2] : '',
        likes: 0,
        amenities: _amenities.toList(),
        ownerId: user.uid,
        roomType: _roomType,
        occupants: _numberOfOccupants,
        houseRules: _houseRules,
        utilitiesIncluded: _includeUtilities,
        isAvailable: true,
      );

      await FirebaseFirestore.instance.collection('listings').add(newListing.toJson());

      Navigator.of(context).pop(); // Dismiss loading indicator
      Navigator.of(context).pop(); // Pop back from AddListingScreen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing published successfully!')),
      );

    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish listing: $e')),
      );
    }
  }

  // THE ADD LISTING FRONT METHOD ---
  Widget _buildBasicsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("The Basics", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // --- Listing Title ---
            Text("Listing Title", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _listingTitle,
              decoration: const InputDecoration(
                hintText: 'e.g. Cozy Room near Limketkai Center',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              onChanged: (value) => setState(() => _listingTitle = value),
            ),
            const SizedBox(height: 24),

            // --- Room Type ---
            Text("Room Type", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Private Room', label: Text('Private Room')),
                ButtonSegment(value: 'Shared Room', label: Text('Shared Room')),
                ButtonSegment(value: 'Entire Unit', label: Text('Entire Unit')),
              ],
              selected: {_roomType},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _roomType = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
            ),
            const SizedBox(height: 24),

            // --- Number of Occupants ---
            Text("Number of Occupants", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => setState(() => _numberOfOccupants > 1 ? _numberOfOccupants-- : null),
                ),
                Text('$_numberOfOccupants', style: Theme.of(context).textTheme.headlineMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _numberOfOccupants++),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Amenities ---
            Text("Amenities", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                for (var amenity in ['Wi-Fi', 'Air Conditioning', 'Private Bathroom', 'Kitchen Access', 'Hot Shower', 'Desk/Workspace'])
                  ChoiceChip(
                    label: Text(amenity),
                    selected: _amenities.contains(amenity),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _amenities.add(amenity);
                        } else {
                          _amenities.remove(amenity);
                        }
                      });
                    },
                  )
              ],
            ),
            const SizedBox(height: 24),

            // --- Description & Rules ---
            Text("Description & Rules", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your place in detail.',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
              onChanged: (value) => setState(() => _description = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _houseRules,
              decoration: const InputDecoration(
                labelText: 'House Rules',
                hintText: 'e.g. No pets, no smoking.',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _houseRules = value),
            ),
            const SizedBox(height: 24),

            // --- Pricing ---
            Text("Pricing", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _monthlyRent.toString(),
              decoration: const InputDecoration(
                labelText: 'Monthly Rent (PHP)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0 ? 'Please enter a valid price' : null,
              onChanged: (value) => setState(() => _monthlyRent = double.tryParse(value) ?? 0.0),
            ),
            SwitchListTile(
              title: const Text('Include Utilities in price'),
              value: _includeUtilities,
              onChanged: (value) => setState(() => _includeUtilities = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // --- Publish Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _nextPage();
                  }
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white
                ),
                child: const Text('Continue to Photos'),
              ),
            ),
          ],
        ),
      ),
    );
  }




// --- PICK IMAGE METHOD ---

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 3 images.')),
      );
      return;
    }
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Upload Photos", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Upload up to 3 high-quality photos of the room, bathroom, and common areas."),
          const SizedBox(height: 24),

          // --- Image Grid ---
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _images.length + 1, // +1 for the "Add" button
            itemBuilder: (context, index) {
              if (index == _images.length) {
                // This is the "Add Photo" button if images are less than 3
                return _images.length < 3
                    ? GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Add Photo"),
                      ],
                    ),
                  ),
                )
                    : const SizedBox.shrink(); // Hide button if 3 images are already added
              }
              // Display the selected image
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(_images[index].path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _images.removeAt(index);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // --- Tips Section ---
          ExpansionTile(
            title: const Text('Tips for Great Photos'),
            initiallyExpanded: true,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary),
                title: const Text('Use bright, natural lighting. Tidy up the room before shooting. Take photos from different angles. Showcase key features and amenities. Ensure photos are clear and not blurry.'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // --- Navigation Buttons ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _images.isNotEmpty ? _nextPage : null, // Disable if no images
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue to Pin Location'),
            ),
          ),
        ],
      ),
    );
  }

  // --- ADD LOCATION METHOD ---
  Widget _buildLocationStep() {
    // Default to Cagayan de Oro City if no location is selected yet
    final mapCenter = _selectedLocation ?? LatLng(8.4764, 124.6457);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 15.0,
                  onPositionChanged: (position, hasGesture) {
                    // Update the selected location as the map moves
                    if (hasGesture) {
                      setState(() {
                        _selectedLocation = position.center;
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.hackathon.roomoro', // Use your app's package name
                  ),
                ],
              ),
              // --- Center Pin Marker ---
              const Center(
                child: IgnorePointer( // The marker itself doesn't need to receive taps
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 50.0,
                  ),
                ),
              ),
              // --- Top Search Bar (UI only, no functionality for now) ---
              Positioned(
                top: 10,
                left: 15,
                right: 15,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                          hintText: "Search for an address or landmark",
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15)
                      ),
                      // We can add search functionality later
                      readOnly: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // --- Bottom Confirmation Bar ---
        Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedLocation != null)
                  Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _selectedLocation != null ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Location'),
                ),
              ],
            )
        ),
      ],
    );
  }


  // BUILD THE REVIEW STEP --
  Widget _buildReviewStep() {
    // A helper to build styled list tiles for the review screen
    Widget buildReviewTile(IconData icon, String title, String subtitle) {
      return ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Review Listing", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // --- Photo Review ---
          if (_images.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_images[index].path),
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),

          // --- Listing Details Review ---
          Text("Listing Details", style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          buildReviewTile(Icons.title, "Title", _listingTitle),
          buildReviewTile(Icons.description, "Description", _description),
          buildReviewTile(Icons.rule, "House Rules", _houseRules.isNotEmpty ? _houseRules : 'Not specified'),
          const SizedBox(height: 24),

          // --- Location Review ---
          Text("Location", style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _selectedLocation ?? LatLng(8.4764, 124.6457),
                  initialZoom: 16.0,
                  // Disable all interaction
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
                          width: 80,
                          height: 80,
                          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Pricing & Terms Review ---
          Text("Pricing & Terms", style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          buildReviewTile(Icons.money, "Monthly Rent", "PHP ${_monthlyRent.toStringAsFixed(2)}"),
          buildReviewTile(Icons.lightbulb_outline, "Utilities Included", _includeUtilities ? "Yes" : "No"),
          buildReviewTile(Icons.people, "Occupants", "$_numberOfOccupants person(s)"),
          const SizedBox(height: 24),

          // --- Amenities Review ---
          Text("Amenities", style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          if (_amenities.isEmpty)
            const Text("No amenities specified.")
          else
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _amenities.map((amenity) => Chip(label: Text(amenity))).toList(),
            ),
          const SizedBox(height: 32),

          // --- Publish Button ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitListing, // The grand finale!
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue, // Final action color
                foregroundColor: Colors.white,
              ),
              child: const Text('Publish Listing'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Room'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentPage == 0 ? () => Navigator.of(context).pop() : _previousPage,
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          _buildBasicsStep(),
          _buildPhotosStep(),
          _buildLocationStep(),
          _buildReviewStep(),
        ],
      ),
    );
  }
}
