import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search by area, landmark, or street",
              prefixIcon: Icon(Icons.search, color: Colors.grey)
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.blueAccent),
            onPressed: () {
              print("Pressed action button");
            }
          )

        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(8.4632, 124.6288),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.jegr.inc'
          )
        ])
    );

  }
}