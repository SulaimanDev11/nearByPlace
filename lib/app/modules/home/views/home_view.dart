import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

import '../controllers/home_controller.dart';

// class HomeView extends GetView<HomeController> {
//   final CameraPosition _initialPosition =
//       CameraPosition(target: LatLng(34.0009704, 71.5425703), zoom: 14);
//   GoogleMapController? _controller;
//   List restaurantList = [];

//   Future<void> nearByPlaces() async {
//     var googlePlace = GooglePlace("AIzaSyBiOSS6zTd7Cfkvrulmi66PPUM0xxBr0g8");
//     var result = await googlePlace.search.getNearBySearch(
//         Location(lat: 34.0009704, lng: 71.5425703), 1500,
//         type: "restaurant", keyword: "");
//     if (result != null) {
//       for (int i = 0; i < result.results!.length; i++) {}
//       // print(restaurantList[1]);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         mapType: MapType.hybrid,
//         initialCameraPosition: _initialPosition,
//         zoomControlsEnabled: true,
//         myLocationButtonEnabled: true,
//         myLocationEnabled: true,
//         onMapCreated: (controller) {
//           _controller = controller;
//         },
//         onTap: (coordinated) {
//           _controller!.animateCamera(CameraUpdate.newLatLng(coordinated));
//           nearByPlaces();
//         },
//       ),
//     );
//   }
// }
class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? _controller;

  List restaurantList = [];
  late Position position;
  RxBool isLoading = false.obs;
  late LatLng setUserPosition;
  CameraPosition? cameraPosition;
  Position? _currentPosition;

  Future<void> getNearbyRestaurants() async {
    var googlePlace = GooglePlace("AIzaSyBiOSS6zTd7Cfkvrulmi66PPUM0xxBr0g8");
    var result = await googlePlace.search.getNearBySearch(
        Location(lat: position.latitude, lng: position.longitude), 1500,
        type: "restaurant", keyword: "");
    log('${result!.results}');
    if (result != null) {
      for (int i = 0; i < result.results!.length; i++) {
        restaurantList.add(result.results![i].name);
      }
    }
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<Position> getCurrentPosition() async {
    isLoading.value = true;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('5');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    this.position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    log(position.latitude.toString());

    await getNearbyRestaurants();

    isLoading.value = false;
    return this.position;
  }

  Future<void> setCameraPostion() async {
    isLoading.value = true;
    final position = await getCurrentPosition();
    setUserPosition = LatLng(position.latitude, position.longitude);
    cameraPosition = CameraPosition(target: setUserPosition, zoom: 18.0);
    log('${position.latitude}, ${position.longitude}');
    // initialCameraPosition = cameraPosition;
    isLoading.value = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    setCameraPostion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          Obx(
            () => !isLoading.value
                ? GoogleMap(
                    mapType: MapType.hybrid,
                    initialCameraPosition: cameraPosition!,
                    zoomControlsEnabled: true,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    onMapCreated: (controller) {
                      _controller = controller;
                    },
                    onTap: (coordinated) {
                      _controller!
                          .animateCamera(CameraUpdate.newLatLng(coordinated));
                      print(restaurantList);
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          Text(
            'restaurantList[0]',
          )
        ],
      ),
    ));
  }
}
