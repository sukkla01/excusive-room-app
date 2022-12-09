import 'dart:convert';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:swroom/component/room_next.dart';
import '../api_provider.dart';
import '../config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';

class WardNext extends StatefulWidget {
  const WardNext({Key? key}) : super(key: key);

  @override
  State<WardNext> createState() => _WardNextState();
}

class _WardNextState extends State<WardNext> {
  String endPoint = config.endPoint;
  List data = [];
  int color_active = config.color_active;
  ApiProvider apiProvider = ApiProvider();

  Future getWard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? ward = prefs.getString('ward');

    try {
      var res = await apiProvider.getWard();
      if (res.statusCode == 200) {
        var jsonDecode = json.decode(res.body);
        // print(jsonDecode);
        setState(() {
          data = jsonDecode;
          // isLoadingBid = false;
        });
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  Future onSelect(String ward, ward_name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ward', ward);
    await prefs.setString('ward_name', ward_name);
    Navigator.pop(context, {'ward': '64', 'roomno': '6401'});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('เลือกตึก'),
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: GridView.builder(
              padding: EdgeInsets.only(top: 10),
              shrinkWrap: true,
              itemCount: data.length,
              // physics: NeverScrollableScrollPhysics(), //  ไม่เลื่อน scroll
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (BuildContext context, int index) {
                var percent = ((int.parse(data[index]['count']) -
                            int.parse(data[index]['notblank'])) /
                        int.parse(data[index]['count'])) *
                    100;
                var color_percent = 0;
                if (percent == 0) {
                  color_percent = 0xFFD03E40;
                } else if (percent < 21) {
                  color_percent = 0xFFD67135;
                } else if (percent < 50) {
                  color_percent = 0xFFF6D353;
                } else {
                  color_percent = 0xFF2CCCAD;
                }
                print(percent);
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        var value = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomNext(
                                  ward: data[index]['ward'],
                                  name: data[index]['name']),
                            ));
                        Navigator.pop(context, {
                          'ward': data[index]['ward'],
                          'ward_name': data[index]['name'],
                          'roomno': value
                        });
                      },
                      child: Container(
                        height: 140,
                        width: 180,
                        // color: Colors.red,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_percent),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${data[index]['name']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'จำนวนทั้งหมด ',
                                  style: TextStyle(fontSize: 11),
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(color_active)),
                                  child: Center(
                                    child: Text(
                                      '${data[index]['count']} ',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                Text(
                                  ' ห้อง',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Icon(
                                    Ionicons.business_outline,
                                    size: 50,
                                    color: Color(0xFF0E473C),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Text(
                                    '           ${data[index]['notblank']}/${data[index]['count']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ));
  }
}
