import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart' as geoCode;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController googleMapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Position position;

  String address;
  String postalCode;
  String country;
  String addre;
  String lattitude;
  String longgitude;

  void getMarkers(double lat, double long) {
    MarkerId markerId = MarkerId(lat.toString() + long.toString());
    Marker marker = Marker(
        markerId: markerId,
        position: LatLng(lat, long),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(snippet: 'Address'));
    setState(() {
      markers[markerId] = marker;
    });
  }

  void getCurrentLocation() async {
    Position currentPosition =
        await GeolocatorPlatform.instance.getCurrentPosition();
    setState(() {
      position = currentPosition;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 600.0,
              child: GoogleMap(
                onTap: (tapped) async {
                  final coordinated = new geoCode.Coordinates(
                      tapped.latitude, tapped.longitude);
                  var address = await geoCode.Geocoder.local
                      .findAddressesFromCoordinates(coordinated);
                  var firstAddress = address.first;

                  getMarkers(tapped.latitude, tapped.longitude);
                  await FirebaseFirestore.instance.collection('location').add({
                    'latitude': tapped.latitude,
                    'longitude': tapped.longitude,
                    'Address': firstAddress.addressLine,
                    'Country': firstAddress.countryName,
                    'PostalCode': firstAddress.postalCode
                  });
                  setState(() {
                    country = firstAddress.countryName;
                    postalCode = firstAddress.postalCode;
                    addre = firstAddress.addressLine;
                  });
                },
                mapType: MapType.normal,
                compassEnabled: true,
                trafficEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    googleMapController = controller;
                  });
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 15.0),
                markers: Set<Marker>.of(markers.values),
              ),
            ),
            Text("Address: $addre"),
            Text("PostalCode: $postalCode"),
            Text("Country: $country"),
            // Text("Latitude: $lat"),
            // Text("Longitude: $long")
          ],
        ),
      ),
    );
  }
}
