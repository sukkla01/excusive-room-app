import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:swroom/component/ward.dart';
import 'package:swroom/component/ward_next.dart';
import '../api_provider.dart';
import '../config.dart' as config;
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cool_alert/cool_alert.dart';

class AddReserve extends StatefulWidget {
  const AddReserve({Key? key}) : super(key: key);

  @override
  State<AddReserve> createState() => _AddReserveState();
}

class _AddReserveState extends State<AddReserve> {
  String endPoint = config.endPoint;
  List data = [];
  String ward = '';
  String ward_name = '';
  String roomno = '';
  List<Map> _dataPttype = [
    {'pttype': '22', 'name': 'xxx'}
  ];

  final Map<String, IconData> _data = Map.fromIterables(
      ['First', 'Second', 'Third'],
      [Icons.filter_1, Icons.filter_2, Icons.filter_3]);
  String _selectedType = '';

  ApiProvider apiProvider = ApiProvider();

  TextEditingController ctrlHn = TextEditingController();
  TextEditingController ctrlCid = TextEditingController();
  TextEditingController ctrlTname = TextEditingController();
  TextEditingController ctrlAge = TextEditingController();
  TextEditingController ctrlPttype = TextEditingController();
  TextEditingController ctrlVstdate = TextEditingController();
  TextEditingController ctrlVsttime = TextEditingController();
  TextEditingController ctrlWard = TextEditingController();
  TextEditingController ctrlRoom = TextEditingController();
  TextEditingController ctrlIcd = TextEditingController();
  TextEditingController ctrlNameReserve = TextEditingController();
  TextEditingController ctrlTel = TextEditingController();
  TextEditingController ctrlDetail = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  var fontSize = 14.0;
  var boxHeight = 50.0;
  var iconSize = 28.0;
  int color_textfield = 0xFF2196F3;
  int color_textfield_icon = 0xFF1664A2;

  String? selectedValue;

  Future getHn(String hn) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? ward = prefs.getString('ward');
    // final String? _ward_name = prefs.getString('ward_name');
    // print(hn);
    try {
      var res = await apiProvider.getPatientHn(hn);
      if (res.statusCode == 200) {
        var jsonDecode = json.decode(res.body);
        if (jsonDecode.length > 0) {
          var tage = jsonDecode.length > 0 ? jsonDecode[0]['age'] : '';
          setState(() {
            data = jsonDecode;
            ctrlCid.text =
                jsonDecode[0]['cid'] == null ? '' : jsonDecode[0]['cid'];
            ctrlTname.text =
                jsonDecode[0]['tname'] == null ? '' : jsonDecode[0]['tname'];
            ctrlAge.text = tage.toString();
            // isLoadingBid = false;
          });
        }
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  Future getCid(String cid) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? ward = prefs.getString('ward');
    // final String? _ward_name = prefs.getString('ward_name');
    // print(hn);
    try {
      var res = await apiProvider.getPatientCid(cid);
      print(res.statusCode);
      if (res.statusCode == 200) {
        var jsonDecode = json.decode(res.body);
        if (jsonDecode.length > 0) {
          var tage = jsonDecode.length > 0 ? jsonDecode[0]['age'] : '';
          setState(() {
            data = jsonDecode;
            ctrlHn.text =
                jsonDecode[0]['hn'] == null ? '' : jsonDecode[0]['hn'];
            ctrlTname.text =
                jsonDecode[0]['tname'] == null ? '' : jsonDecode[0]['tname'];
            ctrlAge.text = tage.toString();
            // isLoadingBid = false;
          });
        }
      }
    } on Exception catch (_) {
      print(_);
    }
    // }
  }

  Future getPttype() async {
    List<Map> tmp_myJson = [];
    var res = await apiProvider.getPttype();
    if (res.statusCode == 200) {
      var jsonDecode = res.body;

      json.decode(jsonDecode).forEach((e) {
        tmp_myJson.add(e);
      });

      setState(() {
        _dataPttype = tmp_myJson;
      });
    }
  }

  Future submit() async {
    Navigator.pop(context);
    if (ctrlVstdate.text == '' || ctrlVsttime.text == '') {
      CoolAlert.show(
          width: 20.0,
          context: context,
          type: CoolAlertType.error,
          text: 'กรุณากรอกวันที่และเวลาที่จอง',
          confirmBtnText: 'ตกลง',
          cancelBtnText: 'ไม่',
          confirmBtnColor: Colors.red,
          onConfirmBtnTap: () {
            Navigator.pop(context);
          });
      print('dd');
    } else {
      try {
        var res = await apiProvider.create(
            ctrlHn.text,
            ctrlCid.text,
            ctrlTname.text,
            ctrlAge.text,
            selectedValue.toString(),
            ctrlVstdate.text,
            ctrlVsttime.text,
            ward,
            roomno,
            ctrlIcd.text,
            ctrlNameReserve.text,
            ctrlTel.text,
            ctrlDetail.text);
        // print(res.statusCode);
        if (res.statusCode == 200) {
          // Fluttertoast.showToast(
          //     msg: "บันทึกเรียบร้อยแล้ว",
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.TOP_RIGHT,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Color(0xFF2CCCAD),
          //     textColor: Colors.white,
          //     fontSize: 16.0);
          Navigator.pop(context);
        } else {
          CoolAlert.show(
              width: 20.0,
              context: context,
              type: CoolAlertType.error,
              text: 'ไม่สามารถบันทึกได้ เกิดข้อผิดพลาด',
              confirmBtnText: 'ตกลง',
              cancelBtnText: 'ไม่',
              confirmBtnColor: Colors.red,
              onConfirmBtnTap: () {
                Navigator.pop(context);
              });
        }
      } catch (err) {
        print(err);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPttype();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('บันทึกการจอง'),
        ),
        body: ListView(children: [
          Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 130),
                        child: GestureDetector(
                          onTap: () async {
                            var value = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WardNext(),
                                ));
                            if (value == null) {
                              setState(() {
                                ward = '';
                                ward_name = '';
                                roomno = '';
                              });
                            } else {
                              setState(() {
                                ward = value['ward'];
                                ward_name = value['ward_name'];
                                roomno = value['roomno'];
                              });
                            }

                            // getRoom();
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
                                Text('เลือกห้อง'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text('   ${ward_name} '),
                      roomno != '' ? Text('ห้อง : ${roomno}') : Text(''),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HN :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: TextFormField(
                          controller: ctrlHn,
                          onChanged: (value) {
                            if (value.length == 7) {
                              getHn(value);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาระบุ HN';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              icon: Icon(
                                Ionicons.document_text_outline,
                                size: iconSize,
                                color: Color(color_textfield_icon),
                              ),
                              hintText: 'HN',
                              hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: Color(color_textfield_icon)
                                      .withOpacity(0.6)),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เลข ปชช. 13 หลัก :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: TextFormField(
                          controller: ctrlCid,
                          onChanged: (value) {
                            if (value.length == 13) {
                              getCid(value);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาระบุ เลข ปชช. 13 หลัก';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              icon: Icon(
                                Ionicons.document_text_outline,
                                size: iconSize,
                                color: Color(color_textfield_icon),
                              ),
                              hintText: 'เลข ปชช. 13 หลัก',
                              hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: Color(color_textfield_icon)
                                      .withOpacity(0.6)),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ชื่อ-สกุล :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: TextFormField(
                          controller: ctrlTname,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาระบุ ชื่อ-สกุล';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              icon: Icon(
                                Ionicons.document_text_outline,
                                size: iconSize,
                                color: Color(color_textfield_icon),
                              ),
                              hintText: 'ชื่อ-สกุล',
                              hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: Color(color_textfield_icon)
                                      .withOpacity(0.6)),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'อายุ :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: TextFormField(
                          controller: ctrlAge,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาระบุ อายุ';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              icon: Icon(
                                Ionicons.document_text_outline,
                                size: iconSize,
                                color: Color(color_textfield_icon),
                              ),
                              hintText: 'อายุ',
                              hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: Color(color_textfield_icon)
                                      .withOpacity(0.6)),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สิทธิการรักษา :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            isExpanded: true,
                            hint: Row(
                              children: const [
                                Icon(
                                  Icons.list,
                                  size: 16,
                                  color: Color(0xFF1664A2),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Text(
                                    'เลือกสิทธิการรักษา',
                                    style: TextStyle(
                                      fontSize: 14,
                                      // fontWeight: FontWeight.bold,
                                      color: Color(0xFF1664A2),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            items: _dataPttype
                                .map((item) => DropdownMenuItem<String>(
                                      value: item['name'],
                                      child: Text(
                                        item['name'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          // fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            value: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value as String;
                              });
                            },
                            icon: const Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: 14,
                            iconEnabledColor: Color(color_textfield_icon),
                            iconDisabledColor: Colors.grey,
                            buttonHeight: 50,
                            buttonWidth: 160,
                            buttonDecoration: BoxDecoration(
                              // borderRadius: BorderRadius.circular(14),
                              // border: Border.all(
                              //   color: Colors.black26,
                              // ),
                              color: Color(color_textfield).withAlpha(0),
                            ),
                            // buttonElevation: 2,
                            itemHeight: 40,
                            itemPadding:
                                const EdgeInsets.only(left: 14, right: 14),
                            dropdownMaxHeight: 200,
                            dropdownWidth: 400,
                            dropdownPadding: null,
                            dropdownDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Color(0xFF1664A2),
                            ),
                            dropdownElevation: 8,
                            scrollbarRadius: const Radius.circular(40),
                            scrollbarThickness: 6,
                            scrollbarAlwaysShow: true,
                            offset: const Offset(-20, 0),
                          ),
                        ),
                      )

                      // Container(
                      //   margin: EdgeInsets.symmetric(vertical: 5),
                      //   padding:
                      //       EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      //   width: size.width * 0.8,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(10),
                      //     color: Color(color_textfield).withAlpha(50),
                      //   ),
                      //   child: TextFormField(
                      //     controller: ctrlPttype,
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return 'กรุณาระบุ สิทธิการรักษา';
                      //       }
                      //       return null;
                      //     },
                      //     cursorColor: Colors.black,
                      //     style: TextStyle(color: Colors.black),
                      //     decoration: InputDecoration(
                      //         icon: Icon(
                      //           Ionicons.document_text_outline,
                      //           size: iconSize,
                      //           color: Color(color_textfield_icon),
                      //         ),
                      //         hintText: 'สิทธิการรักษา',
                      //         hintStyle: TextStyle(
                      //             fontSize: fontSize,
                      //             color: Color(color_textfield_icon)
                      //                 .withOpacity(0.6)),
                      //         border: InputBorder.none),
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'วันที่จอง :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      GestureDetector(
                        onTap: () async {
                          var value = await showRoundedDatePicker(
                            context: context,
                            locale: Locale("th", "TH"),
                            era: EraMode.BUDDHIST_YEAR,
                            initialDate: DateTime.now(),
                            theme: ThemeData.dark(),
                            firstDate:
                                DateTime.now().subtract(Duration(days: 10)),
                            lastDate: DateTime.now().add(Duration(days: 30)),
                          );
                          if (value != null) {
                            setState(() {
                              ctrlVstdate.text =
                                  DateFormat('yyyy-MM-dd').format(value);
                            });

                            // setState(() => dateSelectStart =
                            //     DateFormat('yyyy-MM-dd').format(newDateTime));
                          }
                        },
                        child: Container(
                          height: boxHeight,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          width: size.width * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(color_textfield).withAlpha(50),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 0, right: 20),
                                child: Icon(
                                  Ionicons.calendar_outline,
                                  size: iconSize,
                                  color: Color(color_textfield_icon),
                                ),
                              ),
                              Text(
                                ctrlVstdate.text,
                                style: TextStyle(
                                    color: '' == 'วันนที่เริิ่มบิต'
                                        ? Colors.black
                                        : Colors.black,
                                    fontSize: fontSize),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เวลาที่จอง :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        height: boxHeight,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: DateTimePicker(
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          type: DateTimePickerType.time,
                          controller: ctrlVsttime,
                          //initialValue: _initialValue,
                          icon: Icon(
                            Ionicons.timer_outline,
                            size: iconSize,
                            color: Color(color_textfield_icon),
                          ),
                          timeLabelText: "",
                          //use24HourFormat: false,
                          onChanged: (val) =>
                              setState(() => ctrlVsttime.text = val),
                          // validator: (val) {
                          //   setState(() => _timeStart = val);
                          //   return null;
                          // },
                          // onSaved: (val) => setState(() => _timeStart = val),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'icd10 :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: TextFormField(
                          controller: ctrlIcd,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาระบุ icd10';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              icon: Icon(
                                Ionicons.document_text_outline,
                                size: iconSize,
                                color: Color(color_textfield_icon),
                              ),
                              hintText: 'icd10',
                              hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: Color(color_textfield_icon)
                                      .withOpacity(0.6)),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ผู้จอง :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: TextFormField(
                          controller: ctrlNameReserve,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาระบุ ผู้จอง';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              icon: Icon(
                                Ionicons.document_text_outline,
                                size: iconSize,
                                color: Color(color_textfield_icon),
                              ),
                              hintText: 'ผู้จอง',
                              hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: Color(color_textfield_icon)
                                      .withOpacity(0.6)),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เบอร์โทรติดต่อ :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: TextFormField(
                          controller: ctrlTel,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาระบุ เบอร์โทรติดต่อ';
                            }
                            return null;
                          },
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              icon: Icon(
                                Ionicons.document_text_outline,
                                size: iconSize,
                                color: Color(color_textfield_icon),
                              ),
                              hintText: 'เบอร์โทรติดต่อ',
                              hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: Color(color_textfield_icon)
                                      .withOpacity(0.6)),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'รายละเอียดเพิ่มเติม :',
                        style: TextStyle(
                            fontSize: 14, color: Color(color_textfield_icon)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        width: size.width * 0.8,
                        height: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(color_textfield).withAlpha(50),
                        ),
                        child: TextFormField(
                          controller: ctrlDetail,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              icon: Icon(
                                Ionicons.document_text_outline,
                                size: iconSize,
                                color: Color(color_textfield_icon),
                              ),
                              hintText: 'รายละเอียดเพิ่มเติม',
                              hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: Color(color_textfield_icon)
                                      .withOpacity(0.6)),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 130),
                        child: GestureDetector(
                          onTap: () async {
                            CoolAlert.show(
                                width: 20.0,
                                context: context,
                                type: CoolAlertType.confirm,
                                text: 'ต้องการบันทึกการจองหรือไม่',
                                confirmBtnText: 'ตกลง',
                                cancelBtnText: 'ไม่',
                                confirmBtnColor: Colors.green,
                                onConfirmBtnTap: () {
                                  submit();
                                });
                          },
                          child: Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(color_textfield),
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
                                Icon(Ionicons.checkmark_done_circle_outline),
                                SizedBox(width: 5),
                                Text('บันทึกการจอง'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xFFE90000),
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
                                Icon(Ionicons.close_outline),
                                SizedBox(width: 5),
                                Text('ยกเลิก'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ))
        ]));
  }
}
