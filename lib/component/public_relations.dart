import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:swroom/component/ListReserve.dart';
import 'package:swroom/component/addreserve.dart';
import 'package:swroom/component/ward_next.dart';
import '../config.dart' as config;
import 'package:ionicons/ionicons.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import '../api_provider.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PublicRelation extends StatefulWidget {
  const PublicRelation({Key? key}) : super(key: key);

  @override
  State<PublicRelation> createState() => _PublicRelationState();
}

class _PublicRelationState extends State<PublicRelation> {
  String endPoint = config.endPoint;
  List data = [];
  int tcount = 0;
  int tab = 1;

  IO.Socket socket = IO.io(config.endPoint, <String, dynamic>{
    "transports": ["websocket"],
    "autoConnect": true,
  });

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _send() async {
    socket.emit('confirm_room');
  }

  Future getTest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _token = prefs.getString('token').toString();
    // String token =
    //     'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJKV1QgRGVjb2RlIiwiaWF0IjoxNjA4NTgxNzczLCJleHAiOjE2NDAxMTc3NzMsImF1ZCI6Ind3dy5qd3RkZWNvZGUuY29tIiwic3ViIjoiQSBzYW1wbGUgSldUIiwibmFtZSI6IlZhcnVuIFMgQXRocmV5YSIsImVtYWlsIjoidmFydW4uc2F0aHJleWFAZ21haWwuY29tIiwicm9sZSI6IkRldmVsb3BlciJ9.vXE9ogUeMMsOTz2XQYHxE2hihVKyyxrhi_qfhJXamPQ';

    print(_token);
    Map<String, dynamic> payload = Jwt.parseJwt(_token);
    print(payload);
  }

  void initializeSocket() {
    socket.connect(); //connect the Socket.IO Client to the Server
    print('ccc');
    //SOCKET EVENTS
    // --> listening for connection
    socket.on('connect', (data) {
      print(socket.connected);
    });

    //listen for incoming messages from the Server.
    socket.on('message', (data) {
      print(data); //
    });

    socket.on('select_room', (_) => print('ggg'));

    //listens when the client is disconnected from the Server
    socket.on('disconnect', (data) {
      print('disconnect');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // getTest();
    getReservWait();
    initializeSocket();
  }

  Future getReservAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? ward = prefs.getString('ward');
    final String? _ward_name = prefs.getString('ward_name');

    String ward_name = '';
    ApiProvider apiProvider = ApiProvider();

    try {
      var res = await apiProvider.getReserveAll();
      if (res.statusCode == 200) {
        var jsonDecode = json.decode(res.body);
        // print(jsonDecode);
        setState(() {
          data = jsonDecode;
          ward_name = _ward_name.toString();
          // isLoadingBid = false;
        });
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  Future getReservSuccess() async {
    String ward_name = '';
    ApiProvider apiProvider = ApiProvider();

    try {
      var res = await apiProvider.getReserveSuccess();
      if (res.statusCode == 200) {
        var jsonDecode = json.decode(res.body);
        print(jsonDecode);
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

  Future getReservWait() async {
    String ward_name = '';
    ApiProvider apiProvider = ApiProvider();

    try {
      var res = await apiProvider.getReserveWait();
      if (res.statusCode == 200) {
        var jsonDecode = json.decode(res.body);
        // print(jsonDecode);
        setState(() {
          data = jsonDecode;
          tcount = jsonDecode.length;
          // isLoadingBid = false;
        });
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  Future updateStatus(ward, roomno, hn, vstdate) async {
    String ward_name = '';
    ApiProvider apiProvider = ApiProvider();
    print('xx');
    try {
      var res = await apiProvider.UpdateStatusRoom(ward, roomno, hn, vstdate);
      if (res.statusCode == 200) {
        getReservWait();
        setState(() {
          tab = 1;
        });

        Map data = {
          "ward": ward,
          "roomno": roomno,
          "hn": hn,
          "vstdate": vstdate,
        };
        socket.emit('room', data);
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  Future updateStatusCancel(ward, roomno, hn, vstdate) async {
    String ward_name = '';
    ApiProvider apiProvider = ApiProvider();

    try {
      var res =
          await apiProvider.UpdateStatusRoomCancel(ward, roomno, hn, vstdate);
      if (res.statusCode == 200) {
        getReservWait();
        if (tab == 2) {
          getReservSuccess();
        } else {
          getReservAll();
        }

        setState(() {
          tab = tab;
        });
        socket.emit('cancel');
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 30, right: 30, bottom: 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: GestureDetector(
                        onTap: () async {
                          getReservWait();
                          setState(() {
                            tab = 1;
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(0),
                            ),
                            color: Color(tab == 1
                                ? config.color_header
                                : config.color_sub),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5),
                              Text('รอจอง'),
                              SizedBox(width: 5),
                              tcount > 0
                                  ? Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(config.color_active)),
                                      child: Center(
                                        child: Text(
                                          tcount.toString(),
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: GestureDetector(
                        onTap: () async {
                          // var value = await Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => Ward(),
                          //     ));
                          // // print(value);
                          Scaffold.of(context).openDrawer();
                          getReservSuccess();
                          setState(() {
                            tab = 2;
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            color: Color(tab == 2
                                ? config.color_header
                                : config.color_sub),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5),
                              Text('จองสำเร็จ'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: GestureDetector(
                        onTap: () async {
                          // var value = await Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => Ward(),
                          //     ));
                          // // print(value);
                          getReservAll();
                          setState(() {
                            tab = 3;
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(5),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(5),
                            ),
                            color: Color(tab == 3
                                ? config.color_header
                                : config.color_sub),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 5),
                              Text('ทั้งหมด'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: GestureDetector(
                    onTap: () async {
                      var value = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReserve(),
                          ));
                      // print(value);
                      getReservWait();
                    },
                    child: Container(
                      height: 40,
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(config.color_sub),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Ionicons.add_circle_outline),
                          SizedBox(width: 5),
                          Text('บันทึกจอง'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  height: 500,
                  width: size.width - (size.width * 0.06),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: ListView.builder(
                        itemCount: data.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              height: 60,
                              // width: 100,
                              // color: Colors.red,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.white,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  Color(config.color_active)),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text('HN : ${data[index]['hn']}'),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              data[index]['ward'] == ''
                                                  ? Text('')
                                                  : Text(
                                                      'Ward : ${data[index]['wname']}  '),
                                              data[index]['ward'] == ''
                                                  ? Text('')
                                                  : Text(
                                                      'ห้อง : ${data[index]['room']}'),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                  'วันที่จอง : ${DateFormat('dd/MM/').format(DateTime.parse(data[index]['tdate']))}${int.parse(DateFormat('yyyy').format(DateTime.parse(data[index]['tdate']))) + 543} ${data[index]['vsttime']}'),
                                            ],
                                          ),
                                          Text(
                                              'ชื่อ-สกุล : ${data[index]['tname']}'),
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      data[index]['status'] == 'C'
                                          ? Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFF2CCCAD)),
                                              child: Center(
                                                child: Icon(Ionicons
                                                    .checkmark_done_outline),
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      data[index]['ward'] == ''
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  var value =
                                                      await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    WardNext(),
                                                          ));
                                                  print(value);
                                                  if (value != null) {
                                                    if (value['roomno'] !=
                                                        null) {
                                                      print('next');
                                                      updateStatus(
                                                          value['ward'],
                                                          value['roomno'],
                                                          data[index]['hn'],
                                                          data[index]
                                                              ['vstdate']);
                                                    }
                                                  }

                                                  // getRoom();
                                                },
                                                child: Container(
                                                  height: 38,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.amber,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 1,
                                                        blurRadius: 6,
                                                        offset: Offset(0,
                                                            3), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Ionicons
                                                            .business_outline,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text('เลือกห้อง'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  CoolAlert.show(
                                                      width: 20.0,
                                                      context: context,
                                                      type:
                                                          CoolAlertType.confirm,
                                                      text:
                                                          'ต้องการยกเลิกหรือไม่',
                                                      confirmBtnText: 'ตกลง',
                                                      cancelBtnText: 'ไม่',
                                                      confirmBtnColor:
                                                          Colors.green,
                                                      onConfirmBtnTap: () {
                                                        updateStatusCancel(
                                                            data[index]['ward'],
                                                            data[index]['room'],
                                                            data[index]['hn'],
                                                            data[index]
                                                                ['vstdate']);

                                                        Navigator.pop(context);
                                                      });
                                                },
                                                child: Container(
                                                  height: 38,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.red,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 1,
                                                        blurRadius: 6,
                                                        offset: Offset(0,
                                                            3), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Ionicons.close_outline,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text('ยกเลิก'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
