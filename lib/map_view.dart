import 'package:best7product_assignment/db.dart';
import 'package:best7product_assignment/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' show Component, GoogleMapsPlaces;

import 'firebase_options.dart';

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

  String location = "Search Location";

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
            child: Stack(
              children: [
                GoogleMap(
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
                Positioned(
                  top: 10,
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Card(
                        child: Container(
                            padding: const EdgeInsets.all(0),
                            width: MediaQuery.of(context).size.width - 40,
                            child: ListTile(
                              title: Text(
                                location,
                                style: const TextStyle(fontSize: 18),
                              ),
                              trailing: const Icon(Icons.search),
                              dense: true,
                            )),
                      ),
                    ),
                    onTap: () async {
                      var place = await PlacesAutocomplete.show(
                          context: context,
                          apiKey: googleMapApiKey,
                          mode: Mode.overlay,
                          types: [],
                          strictbounds: false,
                          components: [Component(Component.country, 'in')],
                          //google_map_webservice package
                          onError: (e) {
                            Get.snackbar('Oops!', e.toString());
                          });

                      if (place != null) {
                        setState(() {
                          location = place.description.toString();
                        });

                        //form google_maps_webservice package
                        final plist = GoogleMapsPlaces(
                          apiKey: googleMapApiKey,
                          apiHeaders: await const GoogleApiHeaders().getHeaders(),
                          //from google_api_headers package
                        );
                        String placeid = place.placeId ?? '0';
                        final detail = await plist.getDetailsByPlaceId(placeid);
                        final geometry = detail.result.geometry!;
                        final lat = geometry.location.lat;
                        final lang = geometry.location.lng;
                        var newlatlang = LatLng(lat, lang);

                        //move map camera to selected place with animation
                        mapController.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(target: newlatlang, zoom: 17)));
                      }
                    },
                  ),
                ),
              ],
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
