import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


class CallHistory extends StatefulWidget {
  const CallHistory({super.key});

  @override
  State<CallHistory> createState() => _CallHistoryState();
}

class _CallHistoryState extends State<CallHistory> {
  void initState() {
    super.initState();
    init();
  }

  List<CallLogEntry> callLogs = [];

  Future<void> init () async {
    try {
      Iterable<CallLogEntry> entries = await CallLog.get();
      var now = DateTime.now();
      int from = now.subtract(Duration(days: 60)).millisecondsSinceEpoch;
      int to = now.subtract(Duration(days: 30)).millisecondsSinceEpoch;
      entries = await CallLog.query(
        dateFrom: from,
        dateTo: to,
      );
      setState(() {
        callLogs = entries.toList();
      });
    } catch (e) {
      print('Error fetching call logs: $e');
    }
  }

  void launchPhoneNumber(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  String formatCallDate(int? timestamp) {
    if (timestamp != null) {
      // Convert the timestamp (milliseconds) to a DateTime object
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      // Format the DateTime to show date and time
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } else {
      return 'Unknown';
    }
  }

  Widget callTypeImage(CallType? callType) {
    String imagePath = 'assets/icons/incomingCall.png';

    if (callType == CallType.incoming) {
      imagePath = 'assets/icons/incomingCall.png'; // Replace with your actual asset path
    } else if (callType == CallType.outgoing) {
      imagePath = 'assets/icons/outgoingCall.png'; // Replace with your actual asset path
    } else if (callType == CallType.missed) {
      imagePath = 'assets/icons/missedCall.png'; // Replace with your actual asset path
    }

    return Image.asset(
      imagePath,
      width: 20, // Adjust the width and height as needed
      height: 20,
    );
  }



  @override
  Widget build(BuildContext context) {
    List<Widget> callLogWidgets = callLogs.map((entry) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage: Image.network('https://firebasestorage.googleapis.com/v0/b/election-alert-app-fa31b.appspot.com/o/default_image%2F10.png?alt=media&token=74eba9ef-b70c-44f5-9069-eede7a72e8d1').image// Image radius
            ),
            SizedBox(
              width: 30,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${entry.number}'),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined, size: 15,),
                      SizedBox(width: 5,),
                      Text('${formatCallDate(entry.timestamp)}', style: TextStyle(fontSize: 10),)
                    ]
                  )
                ],
              ),
            ),
            callTypeImage(entry.callType),
            SizedBox(
              width: 10,
            ),
            IconButton(
                  onPressed: (){
                    launchPhoneNumber('${entry.number}');
                  },
                  icon: Icon(Icons.phone, color: Colors.green[600],)
            ),
            SizedBox(
              height: 70,
            ),
          ],
        ),
      );
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: callLogWidgets,
      ),
    );
  }
}
