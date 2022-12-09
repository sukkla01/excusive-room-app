import 'dart:convert';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:swroom/component/ward.dart';
import '../api_provider.dart';
import '../config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';

class RoomNext extends StatefulWidget {
  const RoomNext({Key? key, this.ward, this.name}) : super(key: key);

  final ward;
  final name;

  @override
  State<RoomNext> createState() => _RoomNextState();
}

class _RoomNextState extends State<RoomNext> {
  String endPoint = config.endPoint;
  List data = [];
  String ward_name = '';
  ApiProvider apiProvider = ApiProvider();

  Future getRoom() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? ward = prefs.getString('ward');
    // final String? _ward_name = prefs.getString('ward_name');

    try {
      var res = await apiProvider.getRoom(widget.ward);
      if (res.statusCode == 200) {
        var jsonDecode = json.decode(res.body);
        // print(jsonDecode);
        setState(() {
          data = jsonDecode;
          // ward_name = _ward_name.toString();
          // isLoadingBid = false;
        });
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  Future onSelect(String roommo) async {
    Navigator.pop(context, roommo);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getRoom();
  }

  Future onUpdatestatus(int id, String roomno) async {
    try {
      var res = await apiProvider.updateStatusRoom(id, roomno);
      if (res.statusCode == 200) {
        getRoom();
      }
    } on Exception catch (_) {
      print(_);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('เลือกห้อง'),
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Ionicons.business_outline),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'ตึก ${widget.name}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
              Container(
                height: 500,
                child: GridView.builder(
                    padding: EdgeInsets.only(top: 20),
                    shrinkWrap: true,
                    itemCount: data.length,
                    // physics: NeverScrollableScrollPhysics(), //  ไม่เลื่อน scroll
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              print(data[index]);
                              if (data[index]['status_id'] == 1) {
                                onSelect(data[index]['roomno']);
                              }
                            },
                            child: Container(
                              height: 140,
                              width: 180,
                              // color: Colors.red,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(int.parse(data[index]['color'])),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
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
                                        'ห้อง ${data[index]['roomno']}',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Image.asset(
                                        'assets/images/bed.png',
                                        height: 50,
                                        width: 50,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Text(
                                          '${data[index]['sname']}',
                                          style: TextStyle(fontSize: 13),
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
              ),
            ],
          ),
        ));
  }
}
