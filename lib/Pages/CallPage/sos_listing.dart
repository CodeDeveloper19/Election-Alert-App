import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class SosListing extends StatefulWidget {
  const SosListing({super.key});

  @override
  State<SosListing> createState() => _SosListingState();
}

class _SosListingState extends State<SosListing> {
  final jsonPoliceLinesData = '''
  {
    "ABIA": [
        "08079210003",
        "08079210004", 
        "08079210005"
    ],
    "ADAMAWA": [
        "08089671313"
    ],
    "AKWA IBOM": [
        "08039213071",
        "08020913810"
    ],
    "ANAMBRA": [
        "07039194332",
        "08024922772",
        "08075390511",
        "08182951257"
    ],
    "BAUCHI": [
        "08151849417",
        "08127162434",
        "08084763669",
        "08073794920"
    ],
    "BENUE": [
        "08066006475",
        "08053039936",
        "07075390977"
    ],
    "BAYELSA": [
        "07034578208"
    ],
    "BORNO": [
        "08068075581",
        "08036071667",
        "08123823322"
    ],
    "CROSS RIVERS": [
        "08133568456",
        "07053355415"
    ],
    "DELTA": [
        "08036684974"
    ],
    "EBONYI": [
        "07064515001",
        "08125273721",
        "08084704673"
    ],
    "EDO": [
        "08037646272",
        "08077773721",
        "08067551618"
    ],
    "EKITI": [
        "08062335577",
        "07089310359,"
    ],
    "ENUGU": [
        "08032003702",
        "08075390883",
        "08086671202"
    ],
    "GOMBE": [
        "08150567771",
        "08151855014"
    ],
    "IMO": [
        "08034773600",
        "08037037283"
    ],
    "JIGAWA": [
        "08075391069",
        "07089846285",
        "08123821598"
    ],
    "KADUNA": [
        "08123822284"
    ],
    "KANO": [
        "08032419754",
        "08123821575",
        "064977004",
        "064977005"
    ],
    "KATSINA": [
        "08075391255",
        "08075391250"
    ],
    "KEBBI": [
        "08038797644",
        "08075391307"
    ],
    "KOGI": [
        "08075391335",
        "07038329084"
    ],
    "KWARA": [
        "07032069501",
        "08125275046"
    ],
    "LAGOS": [
        "07055462708",
        "08035963919"
    ],
    "NASSARAWA": [
        "08123821571",
        "07075391560"
    ],
    "NIGER": [
        "08081777498",
        "08127185198"
    ],
    "OGUN": [
        "08032136765",
        "08081770416"
    ],
    "ONDO": [
        "07034313903",
        "08075391808"
    ],
    "OSUN": [
        "08075872433",
        "08039537995",
        "08123823981"
    ],
    "OYO": [
        "08081768614",
        "08150777888"
    ],
    "PLATEAU": [
        "08126375938",
        "08075391844",
        "08038907662"
    ],
    "RIVERS": [
        "08032003514",
        "08073777717"
    ],
    "SOKOTO": [
        "07068848035",
        "08075391943"
    ],
    "TARABA": [
        "08140089863",
        "08073260267"
    ],
    "YOBE": [
        "07039301585",
        "08035067570"
    ],
    "ZAMFARA": [
        "08106580123"
    ],
    "ABUJA (F.C.T)": [
        "07057337653",
        "08061581938",
        "08032003913"
    ]
  }
  ''';

  Map<String, List<String>> parseJson(String jsonStr) {
    final jsonData = json.decode(jsonStr);
    Map<String, List<String>> statePhoneData = {};

    jsonData.forEach((state, phones) {
      statePhoneData[state] = List<String>.from(phones);
    });

    return statePhoneData;
  }

  void launchPhoneNumber(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }



  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> statePhoneData = parseJson(jsonPoliceLinesData);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Toll Free Lines', style: TextStyle(color: Colors.grey[600], fontSize: 12),),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Text('Nigerian Police Emergency Number'),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 1,
                    child: Text('112'),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                        onPressed: () {
                         launchPhoneNumber('112');
                        },
                        icon: Icon(Icons.phone, color: Colors.green[600],)
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Text('Nigerian Police Emergency Number'),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 1,
                    child: Text('199'),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                        onPressed: (){
                          launchPhoneNumber('199');
                        },
                        icon: Icon(Icons.phone, color: Colors.green[600],)
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: statePhoneData.entries.map((entry) {
              String state = entry.key;
              List<String> phoneNumbers = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state, style: TextStyle(color: Colors.grey[600], fontSize: 12),),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: phoneNumbers.asMap().entries.map((entry) {
                      int index = entry.key;
                      String phoneNumber = entry.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text('State Command Line ${index + 1}'),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            flex: 2,
                            child: Text(phoneNumber),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                onPressed: (){
                                  launchPhoneNumber(phoneNumber);
                                },
                                icon: Icon(Icons.phone, color: Colors.green[600],)
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ), //Map to display phone numbers in rows
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
          ),
        ],
      )
    );
  }
  }
