import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Set<Marker> markers = {};
  int Counter=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gps"),
      ),
      body: GoogleMap(
        onLongPress: (latlong) {
          Marker marker = Marker(markerId:
          MarkerId("marker1$Counter"),
                  position: latlong);
          markers.add(marker);
          setState(() {
            Counter++;
          });
        },
        mapType: MapType.hybrid,
        markers: markers,
        initialCameraPosition:
            MyCurrentLoction == null ? _kGooglePlex : MyCurrentLoction!,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(MyCurrentLoction!));
  }

  Location location = Location();

  PermissionStatus? permissionStatus;

  bool serviceEnabled = false;

  LocationData? locationData;
  CameraPosition? MyCurrentLoction;

  void getCurrentLocation() async {
    var permission = await isPermissionGranted();
    if (!permission) return;
    var service = await isServiceEnabled();
    if (!service) return;
    locationData = await location.getLocation();
    location.onLocationChanged.listen((event) {
      locationData = event;
      print("My Locatin: lat:${locationData?.latitude} long${locationData?.longitude}");
      updateUserLocation();
    });
    Marker userMarker = Marker(
        markerId: MarkerId("userLocation"),
        position: LatLng(locationData!.latitude!, locationData!.longitude!));
    markers.add(userMarker);
    MyCurrentLoction = CameraPosition(
        bearing: 190.8334901395799,
        target: LatLng(locationData!.latitude!, locationData!.longitude!),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(MyCurrentLoction!));
    setState(() {});
  }

  void updateUserLocation() async {

    Marker userMarker = Marker(
        markerId: MarkerId("userLocation"),
        position: LatLng(locationData!.latitude!, locationData!.longitude!));
    markers.add(userMarker);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(MyCurrentLoction!));
    setState(() {});
  }

  Future<bool> isServiceEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == false) {
      serviceEnabled = await location.requestService();
      return serviceEnabled;
    }
    return serviceEnabled;
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    } else {
      return permissionStatus == PermissionStatus.granted;
    }
  }
}
