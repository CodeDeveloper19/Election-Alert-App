import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late SharedPreferences preferences;

  void initState() {
    super.initState();
    _determinePosition();
    init();
  }

  LocationData? _locationData;
  late GoogleMapController mapController;
  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  int _selectedIndex = 1;
  bool _mapSettings = false;
  bool _traffic = false;
  bool _buildings = false;
  MapType _mapType = MapType.normal;

  double _compassRotation = 0.0;
  late LatLng _currentLatLng;

  late bool? _isAlertSave;
  late bool? _isTrendSave;


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future init() async {
    preferences = await SharedPreferences.getInstance();

    _isAlertSave = preferences.getBool('alert_notifications');
    _isTrendSave = preferences.getBool('trend_notifications');
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
      if (_locationData != null) {
        mapController.animateCamera(
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

  void _rotateMap() {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0.0,
          zoom: 17.0,
          target: _currentLatLng, // Update the rotation by 45 degrees
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List <Widget> mapTypeList = [
      Container(
        margin: EdgeInsets.only(right: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _mapType = MapType.normal;
                });
              },
              child: Image.asset('assets/icons/default_map.png', fit: BoxFit.cover,),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                fixedSize: MaterialStateProperty.all(const Size(50, 50)),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                overlayColor: MaterialStateProperty.all(Colors.grey[300]),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            Text('Default', style: TextStyle(color: _mapType == MapType.normal ? Colors.green : Colors.grey[600], fontFamily: 'OpenSans', fontSize: 10),),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(right: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _mapType = MapType.hybrid;
                });
              },
              child: Image.asset('assets/icons/hybrid_map.png', fit: BoxFit.cover,),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                fixedSize: MaterialStateProperty.all(const Size(50, 50)),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                overlayColor: MaterialStateProperty.all(Colors.grey[300]),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            Text('Hybrid', style: TextStyle(color: _mapType == MapType.hybrid ? Colors.green : Colors.grey[600], fontFamily: 'OpenSans', fontSize: 10),),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(right: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _mapType = MapType.satellite;
                });
              },
              child: Image.asset('assets/icons/satellite_map.png', fit: BoxFit.cover,),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                fixedSize: MaterialStateProperty.all(const Size(40, 40)),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                overlayColor: MaterialStateProperty.all(Colors.grey[300]),
              ),
            ),
            Text('Satellite', style: TextStyle(color: _mapType == MapType.satellite ? Colors.green : Colors.grey[600], fontFamily: 'OpenSans', fontSize: 10),),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _mapType = MapType.terrain;
                });
              },
              child: Image.asset('assets/icons/terrain_map.png', fit: BoxFit.cover,),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                fixedSize: MaterialStateProperty.all(const Size(50, 50)),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                overlayColor: MaterialStateProperty.all(Colors.grey[300]),
              ),
            ),
            Text('Terrain', style: TextStyle(color: _mapType == MapType.terrain ? Colors.green : Colors.grey[600], fontFamily: 'OpenSans', fontSize: 10),),
          ],
        ),
      ),
    ];

    List <Widget> mapDetailList = [
      Container(
        margin: EdgeInsets.only(right: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _traffic = !_traffic;
                });
              },
              child: Image.asset('assets/icons/traffic.png', fit: BoxFit.cover,),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                fixedSize: MaterialStateProperty.all(const Size(40, 40)),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                overlayColor: MaterialStateProperty.all(Colors.grey[300]),
              ),
            ),
            Text('Traffic', style: TextStyle(color: _traffic ? Colors.green : Colors.grey[600], fontFamily: 'OpenSans', fontSize: 10),),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(right: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _buildings = !_buildings;
                });
              },
              child: Image.asset('assets/icons/buildings.png', fit: BoxFit.cover,),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                fixedSize: MaterialStateProperty.all(const Size(40, 40)),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                overlayColor: MaterialStateProperty.all(Colors.grey[300]),
              ),
            ),
            Text('Buildings', style: TextStyle(color: _buildings ? Colors.green : Colors.grey[600], fontFamily: 'OpenSans', fontSize: 10),),
          ],
        ),
      ),
    ];
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
            mapType: _mapType,
            onMapCreated: _onMapCreated,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            trafficEnabled: _traffic,
            buildingsEnabled: _buildings,
            compassEnabled: false,
            onCameraMove: (CameraPosition position) {
              setState(() {
                _compassRotation = position.bearing;
                _currentLatLng = position.target;
              });
            },
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
                    ElevatedButton(
                      onPressed: () async {
                        await init();
                        if (_isAlertSave! || _isTrendSave!) {
                          context.push('/homepage/notifications_onboarding/settings');
                        } else {
                          context.push('/homepage/notifications_onboarding');
                        }
                      },
                      child: Icon(Icons.notifications, color: Colors.green),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          fixedSize: MaterialStateProperty.all(const Size(45, 45)),
                          elevation: MaterialStateProperty.all(15),
                          padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                          minimumSize: MaterialStateProperty.all(const Size(30, 35)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          overlayColor: MaterialStateProperty.all(Colors.grey[300])
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
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _mapSettings = !_mapSettings;
                });
              },
              child:
              Image.asset('assets/icons/map_settings.png', width: 40, height: 40,),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  fixedSize: MaterialStateProperty.all(const Size(45, 45)),
                  elevation: MaterialStateProperty.all(15),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  minimumSize: MaterialStateProperty.all(const Size(30, 35)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.grey[300])
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: 30,
            child: ElevatedButton(
              onPressed: () {
                _determinePosition();
              },
              child: Icon(Icons.my_location, color: Colors.green,),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  fixedSize: MaterialStateProperty.all(const Size(45, 45)),
                  elevation: MaterialStateProperty.all(15),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  minimumSize: MaterialStateProperty.all(const Size(30, 35)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.grey[300])
              ),
            )
          ),
          Positioned(
            bottom: 120,
            child: InkWell(
              onTap: () {

              },
              child: ElevatedButton(
                onPressed: () {

                },
                child: Image.asset('assets/icons/alarm.png', width: 50, height: 50,),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red[400]),
                    fixedSize: MaterialStateProperty.all(const Size(110, 110)),
                    elevation: MaterialStateProperty.all(15),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                    minimumSize: MaterialStateProperty.all(const Size(30, 35)),
                    shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(55),
                      ),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.red[300])
                  ),
                ),
            ),
          ),
          Positioned(
            top: 145,
            left: 25,
            child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _rotateMap();
                  });
                },
                splashColor: Colors.grey[300],
                backgroundColor: Colors.white,
                mini: true,
                child: Transform.rotate(
                  angle: _compassRotation,
                  child: Image.asset('assets/icons/compass.png', color: Colors.green[600], width: 30, height: 30,)
                  // Icon(Icons.arrow_upward, color: Colors.white, size: 18,),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            child: Visibility(
              visible: _mapSettings,
              child: Container(
                padding: EdgeInsets.fromLTRB(25, 15, 10, 0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))
                ),
                width:  MediaQuery.of(context).size.width - 60,
                height: 295,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Map Type', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.grey[600], fontFamily: 'OpenSans'), ),
                        CloseButton(
                          onPressed: () {
                            setState(() {
                              _mapSettings = !_mapSettings;
                            });
                          },
                        )
                      ],
                    ),
                    Container(
                      height: 70,
                      margin: EdgeInsets.only(top: 10, bottom: 25),
                      child:  ListView(
                        scrollDirection: Axis.horizontal,
                        children: mapTypeList,
                      ),
                    ),
                    Text('Map Details', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.grey[600], fontFamily: 'OpenSans'),),
                    Container(
                      height: 65,
                      margin: EdgeInsets.only(top: 10),
                      child:  ListView(
                        scrollDirection: Axis.horizontal,
                        children: mapDetailList,
                      ),
                    ),
                  ],
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
