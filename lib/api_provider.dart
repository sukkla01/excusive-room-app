import 'dart:convert';

import 'package:http/http.dart' as http;
import './config.dart' as config;

class ApiProvider {
//  ApiProvider();

//  String endPoint = 'http://localhost:4000';
  String endPoint = config.endPoint;

//  ApiProvider apiProvider = ApiProvider();

  Future<http.Response> getRoom(var ward) async {
    Uri url = Uri.parse('$endPoint/get-room/${ward}');
    return await http.get(url);
  }

  Future<http.Response> updateStatusRoom(int id, String room_no) async {
    Map params = {
      "status_id": id.toString(),
      "room_no": room_no.toString(),
    };
    Uri url = Uri.parse('$endPoint/update-status-room');
    return await http.post(url, body: params);
  }

  Future<http.Response> getWard() async {
    Uri url = Uri.parse('$endPoint/get-ward');
    return await http.get(url);
  }

  Future<http.Response> getPttype() async {
    Uri url = Uri.parse('$endPoint/get-pttype');
    return await http.get(url);
  }

  Future<http.Response> getReserveAll() async {
    Uri url = Uri.parse('$endPoint/get-reserve-all');
    return await http.get(url);
  }

  Future<http.Response> getReserveSuccess() async {
    Uri url = Uri.parse('$endPoint/get-reserve-success');
    return await http.get(url);
  }

  Future<http.Response> getReserveWait() async {
    Uri url = Uri.parse('$endPoint/get-reserve-wait');
    return await http.get(url);
  }

  Future<http.Response> getPatientHn(String hn) async {
    print(hn);
    Uri url = Uri.parse('$endPoint/get-patient-hn/${hn}');
    print(url);
    return await http.get(url);
  }

  Future<http.Response> getPatientCid(String cid) async {
    print(cid);
    Uri url = Uri.parse('$endPoint/get-patient-cid/${cid}');
    print(url);
    return await http.get(url);
  }

  Future<http.Response> getConfirmLog() async {
    Uri url = Uri.parse('$endPoint/get-confirm-log');
    print(url);
    return await http.get(url);
  }

  Future<http.Response> login(String username, String password) async {
    Map params = {
      "username": username.toString(),
      "password": password.toString()
    };
    Uri url = Uri.parse('$endPoint/signin');
    return await http.post(url, body: params);
  }

  Future<http.Response> create(
      String hn,
      String cid,
      String tname,
      String age,
      String pttype,
      String vstdate,
      String vsttime,
      String ward,
      String room,
      String icd10,
      String NameReserve,
      String tel,
      String detial) async {
    Map data = {
      "hn": hn,
      "cid": cid,
      "tname": tname,
      "pttype": pttype,
      "age": age,
      "vstdate": vstdate,
      "vsttime": vsttime,
      "ward": ward,
      "room": room,
      "icd10": icd10,
      "NameReserve": NameReserve,
      "tel": tel,
      "detial": detial
    };
    Uri url = Uri.parse('$endPoint/add-reserv');
    return await http.post(url, body: data);
  }

  Future<http.Response> UpdateStatusRoom(
      String ward, String roomno, String hn, String vstdate) async {
    Map data = {
      "ward": ward,
      "roomno": roomno,
      "hn": hn,
      "vstdate": vstdate,
    };
    Uri url = Uri.parse('$endPoint/update-status-room-no');
    return await http.post(url, body: data);
  }

  Future<http.Response> UpdateStatusRoomCancel(
      String ward, String roomno, String hn, String vstdate) async {
    Map data = {
      "ward": ward,
      "roomno": roomno,
      "hn": hn,
      "vstdate": vstdate,
    };
    Uri url = Uri.parse('$endPoint/update-status-room-no-cancel');
    return await http.post(url, body: data);
  }

  Future<http.Response> UpdateStatusHead(String ward, String room) async {
    Map data = {
      "ward": ward,
      "room": room,
    };
    Uri url = Uri.parse('$endPoint/update-status-head');
    return await http.post(url, body: data);
  }

  Future<http.Response> UpdateStatusLog(String hn, String vstdate) async {
    Map data = {
      "hn": hn,
      "vstdate": vstdate,
    };
    Uri url = Uri.parse('$endPoint/update-status-log');
    return await http.post(url, body: data);
  }
}
