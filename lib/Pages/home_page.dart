import 'dart:math';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:election_alert_app/Pages/CallPage/call_page.dart';
import 'package:election_alert_app/Pages/profile.dart';
import 'package:election_alert_app/Utilities/report_violence.dart';
import 'package:election_alert_app/Utilities/send_notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Utilities/calculate_distance_locations.dart'; // Import the image package


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late SharedPreferences preferences;

  void initState() {
    super.initState();
    init();
  }

  Future<BitmapDescriptor> createCustomMarkerImageFromAsset(
      BuildContext context, String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();
    final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;

    final BitmapDescriptor customMarker = BitmapDescriptor.fromBytes(
      Uint8List.fromList(img.encodePng(image)),
    );

    return customMarker;
  }

  Future<void> loadCustomMarkers() async {
    customMarker1 = await createCustomMarkerImageFromAsset(
        context, 'assets/icons/user_location.png');
    customMarker2 = await createCustomMarkerImageFromAsset(
        context, 'assets/icons/polling_place.png');
    customMarker3 = await createCustomMarkerImageFromAsset(
        context, 'assets/icons/low_polling_place.png');
    customMarker4 = await createCustomMarkerImageFromAsset(
        context, 'assets/icons/moderate_polling_place.png');
    customMarker5 = await createCustomMarkerImageFromAsset(
        context, 'assets/icons/high_polling_place.png');
    customMarker6 = await createCustomMarkerImageFromAsset(
        context, 'assets/icons/critical_polling_place.png');
    setState(() {}); // Trigger a rebuild with the loaded markers
  }

  final firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  String _profileImageURL = 'https://firebasestorage.googleapis.com/v0/b/election-alert-app-fa31b.appspot.com/o/default_image%2F10.png?alt=media&token=74eba9ef-b70c-44f5-9069-eede7a72e8d1';

  LocationData? _locationData;
  late GoogleMapController mapController;
  Location location = new Location();

  late BitmapDescriptor customMarker1;
  late BitmapDescriptor customMarker2;
  late BitmapDescriptor customMarker3;
  late BitmapDescriptor customMarker4;
  late BitmapDescriptor customMarker5;
  late BitmapDescriptor customMarker6;

  Set<Marker> markers = {};

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  int _selectedIndex = 1;
  bool _mapSettings = false;
  bool _reportProblem = false;
  bool _traffic = false;
  bool _buildings = false;
  MapType _mapType = MapType.normal;

  double _compassRotation = 0.0;
  late LatLng _currentLatLng;

  late bool? _isAlertSave;
  late bool? _isTrendSave;

  bool _phoneNumberVerified = false;
  bool _emailAddressVerified = false;

  double _pollingAddressLatitude = 0.0;
  double _pollingAddressLongitude = 0.0;

  String _pollingAddress = '';

  bool _progressVisible = true;

  String selectedOption = 'Low'; // Initial selected option

  List <String> chosenTypeofViolence = [];

  void updateProgress () {
    setState(() {
      _progressVisible = !_progressVisible;
    });
  }

  final _controller = PageController(
      initialPage: 1
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  IO.Socket socket = IO.io('http://10.0.2.2:3000', IO.OptionBuilder().setTransports(['websocket']).build());

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future init() async {
    await loadCustomMarkers();
    await getUserData(false);
    await getPollingUnitData();
    await _addMarker(LatLng(_pollingAddressLatitude, _pollingAddressLongitude), 'Your Polling Unit', '', []);
    await _determinePosition();
    await socketConnection();
    requestNotificationPermission();
  }

  requestNotificationPermission () {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();
  }

  socketConnection () {
    socket.onConnect((_) {
      print('connect');
    });
    socket.onDisconnect((_) => print('disconnect'));
    socket.onConnectError((_) => print('Connect Error: $_'));
    socket.on('received_alert', (data) {
      print(data);
    });
  }

  Future<void> getMapSettings () async {
    preferences = await SharedPreferences.getInstance();
    preferences = await SharedPreferences.getInstance();

    _isAlertSave = preferences.getBool('alert_notifications');
    _isTrendSave = preferences.getBool('trend_notifications');

    if (_isTrendSave == null && _isAlertSave == null){
      setState(() {
        _isAlertSave = false;
        _isTrendSave = false;
      });
    }
  }

  Future getUserData (bool result) async {
    imageCache.clear();
    if (result == false){
      updateProgress();
    }
    try {
      DocumentSnapshot documentSnapshot = await firestore.collection('users').doc(user!.uid).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
        String link = userData['imageLink'];
        bool phoneNumberVerified = userData['phoneNumberVerified'];
        bool emailAddressVerified = userData['emailAddressVerified'];
        double pollingAddressLatitude = userData['pollingAddressLatitude'];
        double pollingAddressLongitude = userData['pollingAddressLongitude'];
        String pollingAddress = userData['pollingAddress'];
        setState(() {
          _profileImageURL = link;
          _phoneNumberVerified = phoneNumberVerified;
          _emailAddressVerified = emailAddressVerified;
          _pollingAddressLatitude = pollingAddressLatitude;
          _pollingAddressLongitude = pollingAddressLongitude;
          _pollingAddress = pollingAddress;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  Future getPollingUnitData () async {
    List<DocumentSnapshot> documents;
    try {
      QuerySnapshot documentSnapshot = await firestore.collection('polling_units').get();
      documents = documentSnapshot.docs;
      for (DocumentSnapshot document in documents) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        print(data);
        String distressLevel = data['distressLevel'];
        double pollingAddressLatitude = data['latitude'];
        double pollingAddressLongitude = data['longitude'];
        String address = data['pollingAddress'];
        List violenceTypes = data['typeOfViolence'];
        _addMarker(LatLng(pollingAddressLatitude, pollingAddressLongitude), address, distressLevel, violenceTypes);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }


  Future<void> _determinePosition () async {
    if (!_progressVisible){
      updateProgress();
    }
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
        await mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_locationData!.latitude!, _locationData!.longitude!),
            17.0, // You can adjust the zoom level as needed.
          ),
        );
      }
    } catch (e) {
      print("Error getting location: $e");
    }

    await _addMarker(LatLng(_locationData!.latitude!, _locationData!.longitude!), 'Your Location', '', []);
    if (_progressVisible){
      updateProgress();
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

  bool markerExists(String markerId) {
    return markers.any((marker) => marker.markerId.value == markerId);
  }

  Future<void> deleteMarker(String markerId) async {
    markers.removeWhere((marker) => marker.markerId.value == markerId);
  }

  void updateMap() {
    setState(() {
      // Trigger a rebuild of the map widget
    });
  }

  Future<void> _addMarker(LatLng position, String markerName, String distressLevel, List violenceTypes) async {
    bool _isMarker = markerExists('Your Location');
    BitmapDescriptor customMarker;
    InfoWindow customInfoWindow;
    customMarker = await generateCustomMarker(markerName, distressLevel);
    customInfoWindow = await generateCustomCustomInfoWindow(markerName, distressLevel, violenceTypes);

    if (_isMarker){
      await deleteMarker('Your Location');
      updateMap();
    }

    markers.add(
      Marker(
        markerId: MarkerId(markerName),
        position: position,
        icon: customMarker, // Customize the marker icon
        infoWindow: customInfoWindow
      ),
    );
  }

  Future<BitmapDescriptor> generateCustomMarker(String markerName, String distressLevel) async {
    if (markerName == 'Your Location'){
      return customMarker1;
    } else if (markerName == 'Your Polling Unit'){
      return customMarker2;
    } else if (distressLevel == 'Low'){
      return customMarker3;
    } else if (distressLevel == 'Moderate'){
      return customMarker4;
    } else if (distressLevel == 'High'){
      return customMarker5;
    } else {
      return customMarker6;
    }
  }

  Future<InfoWindow> generateCustomCustomInfoWindow(String markerName, String distressLevel, List violenceTypes) async {
    String violenceTypeText = violenceTypes.join(', ');
    if (markerName == 'Your Location' || markerName == 'Your Polling Unit'){
      return InfoWindow(title: markerName);
    } else {
      return InfoWindow(title: markerName, snippet: "Distress Level: $distressLevel, Violence Detected: $violenceTypeText", onTap: () {
        _showSnackbar("Violence Detected: $violenceTypeText at $markerName", ContentType.warning, 'Violence Report');
      });
    }
  }

  Future<void> navigateToProfile(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => const ProfileSettings()),
    );
    getUserData(result);
  }

  void _showSnackbar(message, contentType, title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 280,
          left: 10,
          right: 10,
        ),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        content: AwesomeSnackbarContent(
          title: title,
          titleFontSize: 18,
          message: message,
          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: contentType,
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
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

    List <Widget> violenceTypeList = [];
    List <String> imageUrlViolenceTypeList = ["hate_speech", "intimidation", "disruption", "property_damage", "bribery", "physical_violence", "armed_violence", "ballot_stealing"];
    List <String> namesViolenceTypeList = ["Hate Speech", "Voter Intimidation", "Disruption of Electoral Process", "Damage of Property", "Bribery, Rigging and Corruption", "Physical Violence", "Armed Violence", "Ballot Stealing"];
    for (int i = 0; i < imageUrlViolenceTypeList.length; i++) {
      violenceTypeList.add(
        Container(
          margin: (imageUrlViolenceTypeList[i] == 'ballot_stealing') ? EdgeInsets.only(right: 20) : EdgeInsets.only(right: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    if(chosenTypeofViolence.contains(namesViolenceTypeList[i])){
                      chosenTypeofViolence.remove(namesViolenceTypeList[i]);
                    } else {
                      chosenTypeofViolence.add(namesViolenceTypeList[i]);
                    }
                  });
                },
                child: Image.asset('assets/violence_types/${imageUrlViolenceTypeList[i]}.png', fit: BoxFit.cover,),
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
              Text('${namesViolenceTypeList[i]}', style: TextStyle(color: chosenTypeofViolence.contains(namesViolenceTypeList[i]) ? Colors.green : Colors.grey[600], fontFamily: 'OpenSans', fontSize: 10),),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      // backgroundColor: Colors.blue,
      body: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: [
          CallSection(),
          Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(9.0765, 7.3986),
                  zoom: 10.0,
                ),
                mapType: _mapType,
                onMapCreated: _onMapCreated,
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                trafficEnabled: _traffic,
                buildingsEnabled: _buildings,
                compassEnabled: false,
                markers: markers,
                onCameraMove: (CameraPosition position) {
                  setState(() {
                    _compassRotation = position.bearing;
                    _currentLatLng = position.target;
                  });
                },
              ),
              Positioned(
                bottom: 120,
                child: InkWell(
                  onTap: () {},
                  child: ElevatedButton(
                    onPressed: () async {
                      // socket.emit('alert_sent', _pollingAddress);
                      localNotification(notificationTitle: 'Violence Reported', notificationBody: 'Violence was noticed at',).showNotification();
                      // updateProgress();
                      // if (_emailAddressVerified || _phoneNumberVerified){
                      //   final double distance = await calculateDistance(userLocation: _currentLatLng, pollingUnitLocation: LatLng(_pollingAddressLatitude, _pollingAddressLongitude),).calculateLocationDistance();
                      //   if (distance <= 0.2){
                      //     updateProgress();
                      //     setState(() {
                      //       _reportProblem = !_reportProblem;
                      //     });
                      //   } else {
                      //     updateProgress();
                      //     _showSnackbar('You are not within 200 metres of your polling unit.', ContentType.failure, "Can't send alert!");
                      //   }
                      // } else {
                      //   updateProgress();
                      //   _showSnackbar('Please verify your phone number or email to use this feature.', ContentType.warning, 'Action Denied!');
                      // }
                    },
                    child: (_emailAddressVerified || _phoneNumberVerified) ? Image.asset('assets/icons/alarm.png', width: 50, height: 50) :  ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.grey[300]!,
                        BlendMode.saturation,
                      ),
                      child: Image.asset('assets/icons/alarm.png', width: 50, height: 50),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all((_emailAddressVerified || _phoneNumberVerified) ? Colors.red[400] : Colors.grey[300]),
                      fixedSize: MaterialStateProperty.all(const Size(110, 110)),
                      elevation: MaterialStateProperty.all(15),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                      minimumSize: MaterialStateProperty.all(const Size(30, 35)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(55),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all((_emailAddressVerified || _phoneNumberVerified) ? Colors.red[400] : Colors.grey[300]),
                    ),
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
                bottom: 100,
                child: Visibility(
                  visible: _reportProblem,
                  child: Container(
                      padding: EdgeInsets.fromLTRB(25, 15, 10, 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      width:  MediaQuery.of(context).size.width - 50,
                      height: 350,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Report a violent occurrence', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[600], fontFamily: 'OpenSans'), ),
                                CloseButton(
                                  onPressed: () {
                                    setState(() {
                                      _reportProblem = !_reportProblem;
                                    });
                                  },
                                )
                              ],
                            ),
                            SizedBox(height: 10,),
                            Text('What is the level of distress/violence?', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Colors.grey[600], fontFamily: 'OpenSans'),),
                            SizedBox(height: 10,),
                            Container(
                              padding: EdgeInsets.only(right: 25,),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Radio<String>(
                                          value: 'Low',
                                          visualDensity: VisualDensity(
                                            horizontal: -3, // Adjust the value for size
                                            vertical: -3,   // Adjust the value for size
                                          ),
                                          groupValue: selectedOption,
                                          onChanged: (value){
                                            setState(() {
                                              selectedOption = value!;
                                            });
                                          }
                                      ),
                                      Text('Low', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 8, color: Colors.green[300], fontFamily: 'OpenSans'),),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Radio<String>(
                                          value: 'Moderate',
                                          visualDensity: VisualDensity(
                                            horizontal: -3, // Adjust the value for size
                                            vertical: -3,   // Adjust the value for size
                                          ),
                                          groupValue: selectedOption,
                                          onChanged: (value){
                                            setState(() {
                                              selectedOption = value!;
                                            });
                                          }
                                      ),
                                      Text('Moderate', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 8, color: Colors.yellow, fontFamily: 'OpenSans'),),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Radio<String>(
                                          value: 'High',
                                          visualDensity: VisualDensity(
                                            horizontal: -3, // Adjust the value for size
                                            vertical: -3,   // Adjust the value for size
                                          ),
                                          groupValue: selectedOption,
                                          onChanged: (value){
                                            setState(() {
                                              selectedOption = value!;
                                            });
                                          }
                                      ),
                                      Text('High', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 8, color: Colors.orange, fontFamily: 'OpenSans'),),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Radio<String>(
                                          value: 'Critical',
                                          visualDensity: VisualDensity(
                                            horizontal: -3, // Adjust the value for size
                                            vertical: -3,   // Adjust the value for size
                                          ),
                                          groupValue: selectedOption,
                                          onChanged: (value){
                                            setState(() {
                                              selectedOption = value!;
                                            });
                                          }
                                      ),
                                      Text('Critical', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 8, color: Colors.red, fontFamily: 'OpenSans'),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20,),
                            Text('Type(s) of violence occurring', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Colors.grey[600], fontFamily: 'OpenSans'),),
                            Container(
                              height: 80,
                              margin: EdgeInsets.only(top: 20),
                              child:  ListView(
                                scrollDirection: Axis.horizontal,
                                children: violenceTypeList,
                              ),
                            ),
                            SizedBox(height: 20,),
                            Container(
                              padding: EdgeInsets.only(right: 45, left: 30),
                              child: ElevatedButton(
                                onPressed: () async {
                                  updateProgress();
                                  if (chosenTypeofViolence.isEmpty){
                                    updateProgress();
                                    _showSnackbar('Please pick a type of violence and level of violence', ContentType.failure, 'Error!');
                                  } else {
                                    String reportResponse = await reportViolence(distressLevel: selectedOption, typeOfViolence: chosenTypeofViolence,
                                      latitude: _pollingAddressLatitude, longitude: _pollingAddressLongitude, pollingAddress: _pollingAddress,).uploadViolenceReport();
                                    updateProgress();
                                    if (reportResponse == 'Success!'){
                                      _showSnackbar('Report has been submitted successfully', ContentType.success, reportResponse);
                                    } else {
                                      _showSnackbar('There was an error submitting your response', ContentType.failure, reportResponse);
                                    }
                                  }
                                  setState(() {
                                    _reportProblem = !_reportProblem;
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.red[600]),
                                ),
                                child: Center(
                                  child: Text(
                                    'Report',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                ),
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
                            navigateToProfile(context);
                            // final result = context.go('/auth/homepage/profile');
                          },
                          child: Builder(
                              builder: (BuildContext context){
                                return CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: Image.network(_profileImageURL, key: ValueKey(new Random().nextInt(300))).image// Image radius
                                );
                              }
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await getMapSettings();
                            if (_isAlertSave! || _isTrendSave!) {
                              context.push('/auth/homepage/notifications_onboarding/settings');
                            } else {
                              context.push('/auth/homepage/notifications_onboarding');
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
                      if (_reportProblem) {
                        _reportProblem = !_reportProblem;
                      }
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
                            Text('Map Type', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey[600], fontFamily: 'OpenSans'), ),
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
                        Text('Map Details', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey[600], fontFamily: 'OpenSans'),),
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
              Visibility(
                visible: _progressVisible,
                child: Container(
                  color: Colors.black54,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              Visibility(
                  visible: _progressVisible,
                  child: CircularProgressIndicator()
              ),
            ],
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
          color: Colors.green[600],
          activeColor: Colors.green[600],
          tabBackgroundColor: (_selectedIndex == 0 && _phoneNumberVerified == false) ? Colors.transparent : Colors.black.withOpacity(0.1),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          tabMargin: EdgeInsets.all(10),
          iconSize: 24,
          style: GnavStyle.google,
          gap: 8,
          tabs: [
            GButton(
              icon: Icons.phone_in_talk,
              text: (_phoneNumberVerified == false) ? '' : 'Call',
              onPressed: () {
                if (_phoneNumberVerified == false) {
                  _showSnackbar('Please verify your phone number to use this feature', ContentType.warning, 'Action Denied!');
                }
              },
            ),
            GButton(
              icon: Icons.location_on_outlined,
              text: 'Maps',
              onPressed: () {
                _determinePosition();
              },
            ),
            GButton(
              icon: Icons.trending_up_sharp,
              text: 'Trends',
            )
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            if (index == 0 && _phoneNumberVerified == false) {
              return;
            } else {
              setState(() {
                _selectedIndex = index;
              });
              _controller.animateToPage(_selectedIndex, duration: Duration(milliseconds: 200), curve:Curves.easeInOut);
            }
          },
        ),
      ),
    );
  }
}
