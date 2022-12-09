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

import '../api_provider.dart';

class General extends StatefulWidget {
  const General({Key? key}) : super(key: key);

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  String endPoint = config.endPoint;
  List data = [];
  int tcount = 0;
  int tab = 1;

  Future getTest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _token = prefs.getString('token').toString();
    // String token =
    //     'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJKV1QgRGVjb2RlIiwiaWF0IjoxNjA4NTgxNzczLCJleHAiOjE2NDAxMTc3NzMsImF1ZCI6Ind3dy5qd3RkZWNvZGUuY29tIiwic3ViIjoiQSBzYW1wbGUgSldUIiwibmFtZSI6IlZhcnVuIFMgQXRocmV5YSIsImVtYWlsIjoidmFydW4uc2F0aHJleWFAZ21haWwuY29tIiwicm9sZSI6IkRldmVsb3BlciJ9.vXE9ogUeMMsOTz2XQYHxE2hihVKyyxrhi_qfhJXamPQ';

    print(_token);
    Map<String, dynamic> payload = Jwt.parseJwt(_token);
    print(payload);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // getTest();
    getReservWait();
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
                          // var value = await Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => Ward(),
                          //     ));
                          // // print(value);
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
                              Container(
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
                              ),
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
                  height: 400,
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
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: GestureDetector(
                                      onTap: () async {
                                        var value = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => WardNext(),
                                            ));
                                        print(value);
                                        // getRoom();
                                      },
                                      child: Container(
                                        height: 38,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color: Colors.amber,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                              Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Ionicons.business_outline,
                                              size: 18,
                                            ),
                                            SizedBox(width: 5),
                                            Text('เลือกตึก'),
                                          ],
                                        ),
                                      ),
                                    ),
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
