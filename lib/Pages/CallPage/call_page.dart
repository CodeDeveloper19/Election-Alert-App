import 'call_history.dart';
import 'sos_listing.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'make_calls.dart';

class CallSection extends StatefulWidget {
  const CallSection({super.key});

  @override
  State<CallSection> createState() => _CallSectionState();
}

class _CallSectionState extends State<CallSection> {

  final _controller = PageController(
      initialPage: 0
  );

  late int currentView = 0;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType){
        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(30, 90, 30, 10),
            child: Column(
              children: <Widget>[
                Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 50,
                          child: TextButton(
                            onPressed: () {
                              _controller.jumpToPage(0);
                              setState(() {
                                currentView = 0;
                              });
                            },
                            child: Image.asset('assets/icons/call_history.png', width: 30, height: 30,),
                          ),
                          decoration: BoxDecoration(
                              color: currentView == 0 ?  Colors.grey[300] : Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 50,
                          child: TextButton(
                            onPressed: () {
                              _controller.jumpToPage(1);
                              setState(() {
                                currentView = 1;
                              });
                            },
                            child: Image.asset('assets/icons/telephone.png', width: 30, height: 30,),
                          ),
                          decoration: BoxDecoration(
                              color: currentView == 1 ?  Colors.grey[300] : Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 50,
                          child: TextButton(
                            onPressed: () {
                              _controller.jumpToPage(2);
                              setState(() {
                                currentView = 2;
                              });
                            },
                            child: Image.asset('assets/icons/sos.png', width: 30, height: 30,),
                          ),
                          decoration: BoxDecoration(
                              color: currentView == 2 ?  Colors.grey[300] : Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                SingleChildScrollView(
                  child: Container(
                    height: 65.h,
                    child: PageView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _controller,
                      children: <Widget>[
                        CallHistory(),
                        MakeCall(),
                        SosListing()
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
