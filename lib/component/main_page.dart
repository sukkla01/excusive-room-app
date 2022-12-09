import 'dart:convert';

import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:swroom/component/public_relations.dart';
import 'package:swroom/component/ward.dart';
import '../api_provider.dart';
import '../config.dart' as config;
import 'general.dart';
import 'room.dart';
import 'setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int tab = 1;
  int selectPages = 0;
  int bg_color = config.bg_color;
  int color_sub = config.color_sub;
  int color_header = config.color_header;
  int color_active = config.color_active;
  List data = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List pages = [PublicRelation(), Room(), General(), Setting()];

  IO.Socket socket = IO.io(config.endPoint, <String, dynamic>{
    "transports": ["websocket"],
    "autoConnect": true,
  });

  Future getConfirmLog() async {
    ApiProvider apiProvider = ApiProvider();

    try {
      var res = await apiProvider.getConfirmLog();
      if (res.statusCode == 200) {
        var jsonDecode = json.decode(res.body);
        print(jsonDecode);
        setState(() {
          data = jsonDecode;
        });
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  Future updateConfirmLog(hn, vstdate) async {
    var tdate = DateFormat('yyyy-MM-dd').format(DateTime.parse(vstdate));
    ApiProvider apiProvider = ApiProvider();

    try {
      var res = await apiProvider.UpdateStatusLog(hn, vstdate);
      if (res.statusCode == 200) {
        getConfirmLog();
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  void initializeSocket() {
    socket.connect(); //connect the Socket.IO Client to the Server
    print('ccc');
    //SOCKET EVENTS
    // --> listening for connection
    socket.on('connect', (data) {
      print(socket.connected);
    });

    socket.on('alert_confirm', (_) => _openEndDrawer());

    //listens when the client is disconnected from the Server
    socket.on('disconnect', (data) {
      print('disconnect');
    });
  }

  void _openEndDrawer() {
    if (tab == 1) {
      getConfirmLog();
      _scaffoldKey.currentState!.openEndDrawer();
    }
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }

  void onTab(int i) {
    setState(() {
      tab = i;
      selectPages = i - 1;
    });
    print(color_active);
  }

  Future setWard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ward', '64');
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setWard();
    initializeSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          new Container(),
        ],
        title: Row(
          children: [
            Icon(Ionicons.browsers_outline),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('ระบบจองห้องพิเศษ'),
            ),
          ],
        ),
        elevation: 0.0,
        backgroundColor: Color(color_header),
      ),
      key: _scaffoldKey,
      endDrawer: Drawer(
        backgroundColor: Colors.red.withOpacity(0.0),
        elevation: 0.0,
        child: Container(
          height: 200,
          child: ListView.builder(
              itemCount: data.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Color(0xFF72DDC8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 5),
                                      child:
                                          Icon(Ionicons.checkmark_done_outline),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, top: 5),
                                      child: Text(
                                        'ยืนยันการจอง',
                                        style: TextStyle(
                                            color: Color(0xFF264249),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'HN : ${data[index]['hn']}',
                                        style: TextStyle(
                                            color: Color(0xFF264249),
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'ชื่อ-สกุล : ${data[index]['tname']}',
                                        style: TextStyle(
                                            color: Color(0xFF264249),
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  updateConfirmLog(data[index]['hn'],
                                      data[index]['vstdate']);
                                },
                                child: Container(
                                  height: 35,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Color(0xFF31595A),
                                  ),
                                  child: Center(
                                      child: Text(
                                    'ตกลง',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 0),
                          child: Row(
                            children: [
                              Text(
                                'ward : ${data[index]['wname']}  ห้อง ${data[index]['room']}',
                                style: TextStyle(
                                    color: Color(0xFF264249), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            color: Color(color_sub),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    onTab(1);
                  },
                  child: Container(
                      height: 40,
                      width: 110,
                      color: tab == 1 ? Color(color_active) : Color(color_sub),
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Ionicons.keypad_outline,
                            size: 16,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text('ประชาสัมพันธ์'),
                        ],
                      ))),
                ),
                SizedBox(
                  width: 0,
                ),
                GestureDetector(
                  onTap: () {
                    onTab(2);
                  },
                  child: Container(
                      height: 40,
                      width: 100,
                      color: tab == 2 ? Color(color_active) : Color(color_sub),
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Ionicons.business_outline,
                            size: 18,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text('ตึกพิเศษ'),
                        ],
                      ))),
                ),
                SizedBox(
                  width: 0,
                ),
                GestureDetector(
                  onTap: () {
                    onTab(3);
                  },
                  child: Container(
                      height: 40,
                      width: 100,
                      color: tab == 3 ? Color(color_active) : Color(color_sub),
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Ionicons.bed_outline,
                            size: 18,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text('ตึกสามัญ'),
                        ],
                      ))),
                ),
                SizedBox(
                  width: 0,
                ),
                GestureDetector(
                  onTap: () {
                    onTab(4);
                  },
                  child: Container(
                      height: 40,
                      width: 100,
                      color: tab == 4 ? Color(color_active) : Color(color_sub),
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Ionicons.cog_outline,
                            size: 18,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text('ตั่งค่า'),
                        ],
                      ))),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Container(
              height: 1000,
              color: Colors.red,
              child: pages[selectPages],
            ),
          )
          // PublicRelations(),
        ],
      ),
    );
  }
}
