import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  //map controller to control the map HAHAHA
  late final MapController _mapController;
  final List<Marker> _markers = [];

  // dummy location sa user but will update later for real location
  final LatLng _userLocation = LatLng(8.4632, 124.6288);

  //initialize the map controller
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  //function for animating the map to the user's location
  void _animateToUserLocation()  {
    _mapController.move(_userLocation, 13.0);
    print("centered");
    setState(() {
      _markers.clear();
      _markers.add(
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar is removed from here and placed inside the Stack
        body: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // This is the bottom layer, which is the map
              FlutterMap(
                mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(8.4632, 124.6288),
                    initialZoom: 13.0,
                    onMapReady: () {
                      print("Map is ready");
                    }
                  ),
                  children: [
                    TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.jegr.inc'
                    ),
                    MarkerLayer(markers: _markers)
                  ]
              ),
              // This is the top layer, containing your search bar and button
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea( // Ensures content is not obscured by system UI
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50, // Increased height for better padding
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25), // Adjusted for new height
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: Offset(0, 3)
                                )
                              ],
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                  hintText: "Search by area, landmark, or street",
                                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric( vertical: 12) // Adjusted padding
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // Spacing between search bar and button
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: Offset(0, 3)
                                )
                              ]
                          ),
                          child: IconButton(
                              icon: const Icon(Icons.filter_list, color: Colors.blueAccent),
                              onPressed: () {
                                print("Pressed action button");
                              }
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // current location floating button
              Padding(padding: const EdgeInsets.only(bottom: 24.0, right: 16.0),
                child: FloatingActionButton(
                  onPressed: _animateToUserLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.orangeAccent),

                ),
              )
            ]
        )
    );
  }

}
