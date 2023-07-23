import 'package:best7product_assignment/db.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AllUsersMapView extends StatefulWidget {
  const AllUsersMapView({super.key});
  // final Map<MarkerId, Marker> markers;

  @override
  State<AllUsersMapView> createState() => _AllUsersMapViewState();
}

class _AllUsersMapViewState extends State<AllUsersMapView> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(17.416330078551702, 78.47494613301858);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Map<MarkerId, Marker> markers = {};

  void addMarker(double lat, double lng) {
    MarkerId markerId = MarkerId(lat.toString() + lng.toString());
    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        snippet: 'Address',
        onTap: () => mapController.showMarkerInfoWindow(markerId),
      ),
    );

    markers[markerId] = marker;
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < allUsers.length; i++) {
      final user = allUsers[i];

      addMarker(user['location']['lat'], user['location']['lng']);
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapToolbarEnabled: true,
              mapType: MapType.normal,
              compassEnabled: true,
              trafficEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 8.0,
              ),
              markers: Set<Marker>.of(markers.values),
            ),
          ),
        ],
      ),
    );
  }
}
