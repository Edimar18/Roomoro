import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar is removed from here and placed inside the Stack
        body: Stack(
            children: [
              // This is the bottom layer, which is the map
              FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(8.4632, 124.6288),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.jegr.inc'
                    )
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
                                    color: Colors.black.withOpacity(0.15),
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
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15) // Adjusted padding
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
                                    color: Colors.black.withOpacity(0.15),
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
            ]
        )
    );
  }
}
