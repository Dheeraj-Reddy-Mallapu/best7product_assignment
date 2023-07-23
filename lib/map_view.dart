import 'package:best7product_assignment/db.dart';
import 'package:best7product_assignment/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMapView extends StatefulWidget {
  const MyMapView({super.key, required this.isEditMode, required this.lat, required this.lng});
  final bool isEditMode;
  final double lat;
  final double lng;

  @override
  State<MyMapView> createState() => _MyMapViewState();
}

class _MyMapViewState extends State<MyMapView> {
  late GoogleMapController mapController;

  double lat = 0;
  double lng = 0;

  LatLng _center = const LatLng(17.416330078551702, 78.47494613301858);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Map<MarkerId, Marker> markers = {};

  void getMarker(double lat, double lng) {
    MarkerId markerId = MarkerId(lat.toString() + lng.toString());
    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        snippet: 'Address',
        onTap: () => mapController.showMarkerInfoWindow(markerId),
      ),
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  int dummy = 0;

  @override
  Widget build(BuildContext context) {
    if (dummy == 0) {
      _center = LatLng(widget.lat, widget.lng);

      lat = widget.lat;
      lng = widget.lng;

      MarkerId markerId = MarkerId(widget.lat.toString() + widget.lng.toString());
      Marker marker = Marker(
        markerId: markerId,
        position: LatLng(widget.lat, widget.lng),
        infoWindow: InfoWindow(
          snippet: 'Address',
          onTap: () => mapController.showMarkerInfoWindow(markerId),
        ),
      );

      markers[markerId] = marker;

      dummy++;
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapToolbarEnabled: true,
              onTap: (argument) {
                if (widget.isEditMode) {
                  markers.clear();

                  lat = argument.latitude;
                  lng = argument.longitude;

                  getMarker(argument.latitude, argument.longitude);
                }
              },
              mapType: MapType.normal,
              compassEnabled: true,
              trafficEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: Set<Marker>.of(markers.values),
            ),
          ),
          if (markers.isNotEmpty && widget.isEditMode)
            ElevatedButton(
              onPressed: () async {
                await db.collection('users').doc(currentUser.uid).update({
                  'location': {'lat': lat, 'lng': lng},
                });
                Get.offAll(() => const HomeScreen());
              },
              child: const Text('Save'),
            ),
        ],
      ),
    );
  }
}
