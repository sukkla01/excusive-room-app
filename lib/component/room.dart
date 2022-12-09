import 'dart:convert';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:swroom/component/ward.dart';
import '../api_provider.dart';
import '../config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:cool_alert/cool_alert.dart';

class Room extends StatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  String endPoint = config.endPoint;
  List data = [];
  String ward_name = '';
  String _ward = '';
  ApiProvider apiProvider = ApiProvider();
  int alertCount = 0;

  IO.Socket socket = IO.io(config.endPoint, <String, dynamic>{
    "transports": ["websocket"],
    "autoConnect": true,
  });
  void initializeSocket() {
    socket.connect(); //connect the Socket.IO Client to the Server
    print('ccc');
    //SOCKET EVENTS
    // --> listening for connection
    socket.on('connect', (data) {
      print(socket.connected);
    });

    //listen for incoming messages from the Server.
    socket.on('select_room', (data) async {
      //   SharedPreferences prefs = await SharedPreferences.getInstance();
      // final String? ward = prefs.getString('ward');
      print(data['ward'].toString() + '----------'); //
      print('-----'); //
      print(_ward + '######'); //
      if (data['ward'].toString() == _ward.toString()) {
        getRoom('');
        AlertReserve();
      }
    });

    socket.on('app_cancel', (data) async {
      getRoom('');
    });

    //listens when the client is disconnected from the Server
    socket.on('disconnect', (data) {
      print('disconnect');
    });
  }

  Future getRoom(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    value == '' ? '' : prefs.setString('ward', value.toString());
    final String? ward = value == '' ? prefs.getString('ward') : value;
    final String? _ward_name = prefs.getString('ward_name');
    var countWait = 0;
    print(ward);
    try {
      var res = await apiProvider.getRoom(ward);
      // print(res.body);
      if (res.statusCode == 200) {
        var jsonDecode = json.decode(res.body);
        getCount(jsonDecode);
        // print(json.encode(jsonDecode));
        for (var data in jsonDecode) {
          // print(data['status_id']);
          countWait = data['status_id'] == 5 ? countWait + 1 : countWait;
        }

        setState(() {
          data = jsonDecode;
          ward_name = _ward_name.toString();
          _ward = ward.toString();
          alertCount = countWait;
          // isLoadingBid = false;
        });
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  Future getCount(_data) async {
    var count = 0;
    // print(_data.length);
    _data.forEach((v) {
      // count = v['status_id'] == 5 ? 1 : 0;
      if (v['status_id'] == 5) {
        count = count + 1;
      } else {
        print(0);
      }
    });
    // setState(() {
    //   alertCount = count;
    // });
  }

  Future AlertReserve() async {
    showTopSnackBar(
        context,
        CustomSnackBar.success(
          message: "มีการจองห้องพิเศษ",
          backgroundColor: Color(0xFFF7DC6F),
          textStyle: TextStyle(color: Colors.black, fontSize: 18),
        ),
        showOutAnimationDuration: Duration(milliseconds: 2000),
        hideOutAnimationDuration: Duration(milliseconds: 1000),
        displayDuration: Duration(milliseconds: 200000));
  }

  Future onUpdatestatusHead(String ward, String room) async {
    try {
      var res = await apiProvider.UpdateStatusHead(ward, room);
      if (res.statusCode == 200) {
        var data = {'ward': ward, 'room': room};
        socket.emit('confirm_room', data);
      }
    } on Exception catch (_) {
      print(_);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeSocket();
    getRoom('');
  }

  Future onUpdatestatus(int id, String roomno) async {
    try {
      var res = await apiProvider.updateStatusRoom(id, roomno);
      if (res.statusCode == 200) {
        getRoom('');
      }
    } on Exception catch (_) {
      print(_);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 0, left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Ionicons.business_outline),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'ตึก ${ward_name}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () async {
                            AlertReserve();
                          },
                          child: Container(
                            height: 40,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(config.color_sub),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Ionicons.timer_outline),
                                SizedBox(width: 5),
                                Text('รอจอง'),
                                SizedBox(width: 5),
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(config.color_active)),
                                  child: Center(
                                    child: Text(
                                      '${alertCount}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: GestureDetector(
                          onTap: () async {
                            var value = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Ward(),
                                ));
                            // print(value);
                            if (value != null) {
                              getRoom(value);
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.amber,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Ionicons.business_outline),
                                SizedBox(width: 5),
                                Text('เลือกตึก'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )),
          Container(
            height: 450,
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
                          if (data[index]['status_id'] == 5) {
                            CoolAlert.show(
                                width: 20.0,
                                context: context,
                                type: CoolAlertType.confirm,
                                text: 'ยืนยันการจองหรือไม่',
                                confirmBtnText: 'ตกลง',
                                cancelBtnText: 'ไม่',
                                confirmBtnColor: Colors.green,
                                onConfirmBtnTap: () {
                                  onUpdatestatus(4, data[index]['roomno']);
                                  onUpdatestatusHead(data[index]['ward'],
                                      data[index]['roomno']);
                                  Navigator.pop(context);
                                });
                          } else {
                            print('hh');
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
                                    'ห้อง ${data[index]['roomno']}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
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
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        onUpdatestatus(
                                            1, data[index]['roomno']);
                                      },
                                      child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(10)),
                                            color: Color(0xFF2CCCAD),
                                          ),
                                          child: Center(child: Text('R'))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        onUpdatestatus(
                                            2, data[index]['roomno']);
                                      },
                                      child: Container(
                                          height: 30,
                                          color: Color(0xFFF6D353),
                                          child: Center(child: Text('WH'))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        onUpdatestatus(
                                            3, data[index]['roomno']);
                                      },
                                      child: Container(
                                        height: 30,
                                        color: Color(0xFFD67135),
                                        child: Center(child: Text('WC')),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        onUpdatestatus(
                                            4, data[index]['roomno']);
                                      },
                                      child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(10)),
                                            color: Color(0xFFD03E40),
                                          ),
                                          child: Center(child: Text('A'))),
                                    ),
                                  ),
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
