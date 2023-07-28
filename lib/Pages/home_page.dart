import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  void initState() {
    super.initState();
    _determinePosition();
  }

  LocationData? _locationData;
  late GoogleMapController mapController;
  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  int _selectedIndex = 1;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _determinePosition () async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      print('service not enabled');
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      print('permission denied');
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('permission granted');
        return;
      }
    }

    try {
      _locationData = await location.getLocation();
      if (_locationData != null && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_locationData!.latitude!, _locationData!.longitude!),
            17.0, // You can adjust the zoom level as needed.
          ),
        );
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // void _currentLocation() async {
  //   // final GoogleMapController controller = await _controller.future;
  //   LocationData? currentLocation;
  //   var location = new Location();
  //   try {
  //     currentLocation = await location.getLocation();
  //   } on Exception {
  //     currentLocation = null;
  //   }
  //
  //   mapController.animateCamera(CameraUpdate.newCameraPosition(
  //     CameraPosition(
  //       bearing: 0,
  //       target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
  //       zoom: 17.0,
  //     ),
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // backgroundColor: Colors.blue,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(0.0, 0.0),
              zoom: 6.0,
            ),
            mapType: MapType.hybrid,
            onMapCreated: _onMapCreated,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 70),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        context.push('/homepage/profile');
                      },
                      child:  CircleAvatar(
                        radius: 20, // Image radius
                        backgroundImage: AssetImage('assets/login/profile.jpg'),
                      ),
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: IconButton(
                        onPressed: () async {

                        },
                        icon: Icon(Icons.notifications),
                        color: Colors.green[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 150,
            right: 30,
            child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: TextButton(
                    onPressed: () {
                      
                    }, 
                    child: Image.asset('assets/icons/map_settings.png'),
                )
                // IconButton(
                //   onPressed: () async {
                //
                //   },
                //   icon: Icon(Icons.map_outlined),
                //   color: Colors.green[600],
                // ),
              ),
          ),
          Positioned(
            bottom: 120,
            right: 30,
            child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: IconButton(
                  onPressed: () {
                    _determinePosition();
                  },
                  icon: Icon(Icons.my_location),
                  color: Colors.green[600],
                )
              // IconButton(
              //   onPressed: () async {
              //
              //   },
              //   icon: Icon(Icons.map_outlined),
              //   color: Colors.green[600],
              // ),
            ),
          ),
          Positioned(
            bottom: 120,
            child: InkWell(
              onTap: () {
                context.push('/homepage/profile');
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_alert,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: GNav(
          tabBorderRadius: 20,
          activeColor: Colors.green[600],
          tabBackgroundColor: Colors.black.withOpacity(0.1),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          tabMargin: EdgeInsets.all(10),
          iconSize: 24,
          style: GnavStyle.google,
          gap: 8,
          tabs: [
            GButton(
              icon: Icons.phone_in_talk,
              text: 'Call',
            ),
            GButton(
              icon: Icons.location_on_outlined,
              text: 'Maps',
            ),
            GButton(
              icon: Icons.trending_up_sharp,
              text: 'Trends',
            )
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
