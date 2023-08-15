import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late SharedPreferences preferences;

  final _controller = PageController(
    initialPage: 0
  );

  void initState() {
    super.initState();
    init();
  }

  late int _pageNumber = 1;
  bool _isAlert = false;
  bool _isTrend = false;
  bool _isPush = false;

  late bool? _isAlertSave;
  late bool? _isTrendSave;
  late bool? _isPushSave;


  Future init() async {
    preferences = await SharedPreferences.getInstance();

    _isAlertSave = preferences.getBool('alert_notifications');
    _isTrendSave = preferences.getBool('trend_notifications');
    _isPushSave = preferences.getBool('push_notifications');

    setState(() {
      _isAlert = _isAlertSave!;
      _isTrend = _isTrendSave!;
      _isPush = _isPushSave!;
    });
  }

  Future<void> savingNotifications () async {
    await preferences.setBool('alert_notifications', _isAlert);
    await preferences.setBool('trend_notifications', _isTrend);
    await preferences.setBool('push_notifications', _isPush);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 70),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 120,
              margin: EdgeInsets.only(bottom: 15),
              child: TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(Icons.arrow_back_rounded),
                    Text('Back to Map', style: TextStyle(fontFamily: 'OpenSans', fontSize: 12, fontWeight: FontWeight.w500,), )
                  ],
                ),
              ),
            ),
            Text('Notifications', style: TextStyle(fontFamily: 'OpenSans', fontSize: 25, fontWeight: FontWeight.w500,),),
            Container(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: Text('We may send you important notifications on alert levels and trends concerning electoral violence outside of your notifications settings', style: TextStyle(fontFamily: 'OpenSans', fontSize: 12, color: Colors.black45),),
            ),
            Container(
              margin: EdgeInsets.only(top: 50, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      _controller.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut
                      );
                    },
                    child: Text('Activity', style: TextStyle(color: Colors.black45, fontSize: 15),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(_pageNumber == 1 ?  Colors.green[600] : Colors.transparent),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 25, vertical: 10)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut
                      );
                    },
                    child: Text('Settings', style: TextStyle(color: Colors.black45, fontSize: 15),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(_pageNumber == 2 ?  Colors.green[600] : Colors.transparent,),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 25, vertical: 10)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 380,
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _pageNumber = index + 1;
                  });
                },
                children: <Widget>[
                  Container(
                    child: SingleChildScrollView(
                      child: Column(

                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Alert Notifications', style: TextStyle(fontFamily: 'OpenSans', fontSize: 13, fontWeight: FontWeight.w200,)),
                              Switch(
                                value: _isAlert,
                                onChanged: (value) {
                                  setState(() {
                                    _isAlert = value;
                                  });
                                }
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Trend Notifications', style: TextStyle(fontFamily: 'OpenSans', fontSize: 13, fontWeight: FontWeight.w200,)),
                              Switch(
                                  value: _isTrend,
                                  onChanged: (value) {
                                    setState(() {
                                      _isTrend = value;
                                    });
                                  }
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Push Notifications', style: TextStyle(fontFamily: 'OpenSans', fontSize: 13, fontWeight: FontWeight.w200,)),
                              Switch(
                                  value: _isPush,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPush = value;
                                    });
                                  }
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              savingNotifications();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                            ),
                            child: Center(
                              child: Text(
                                'Save Changes',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat'
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
