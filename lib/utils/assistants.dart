// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

String stringToBase64(String inputString) {
  return base64Encode(utf8.encode(inputString));
}

Future<int?> postWithDataAndHeaders() async {
  SharedPreferences instance = await SharedPreferences.getInstance();

  bool isWillSend = await isCurrentTimeInRange();
  if (isWillSend) {
    Dio dio = Dio();

    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    String id = instance.getString('id') ?? '0';
    String login = instance.getString('login') ?? '';
    String password = instance.getString('password') ?? '';
    String url = instance.getString('url') ?? '';
    Position? position;
    String connection = await getConnectionType();
    Battery battery = Battery();
    int percent = await battery.batteryLevel;
    String admin = 'Basic 0JDQtNC80LjQvdC40YHRgtGA0LDRgtC+0YA6';
    if (isServiceEnabled) {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }

    Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      'Authorization': password.isEmpty
          ? admin
          : 'Basic ${stringToBase64(login + ":" + password)}'
    };

    print(headers);
    print(DateTime.now());

    print({
      "latitude": position == null ? 0 : position.latitude.toString(),
      "longitude": position == null ? 0 : position.longitude.toString(),
      "agent_id": id,
      "battery": "$percent%",
      "accuracy": position == null ? '0 m' : '${position.accuracy} m',
      "gps": isServiceEnabled,
      "internet": connection
    });

    try {
      dio.options.headers.addAll(headers);
      Response response = await dio.post(url, data: {
        "latitude": position == null ? 0 : position.latitude.toString(),
        "longitude": position == null ? 0 : position.longitude.toString(),
        "agent_id": id,
        "battery": "${percent}%",
        "accuracy": position == null ? '0 m' : '${position.accuracy} m',
        "gps": isServiceEnabled,
        "internet": connection
      });

      SharedPreferences instance = await SharedPreferences.getInstance();
      List<String> times = instance.getStringList('times') ?? [];
      List<String> statuses = instance.getStringList('statuses') ?? [];
      times.add(DateTime.now().toString());
      statuses.add(response.statusCode.toString());
      instance.setStringList('statuses', statuses);
      instance.setStringList('times', times);
      print("Success ${response.statusCode} ${response.data}");
      return response.statusCode;
    } on DioError catch (e) {
      print("Errorga tushdi ${e.response?.statusCode}");
      List<String> times = instance.getStringList('times') ?? [];
      List<String> statuses = instance.getStringList('statuses') ?? [];
      times.add(DateTime.now().toString());
      statuses
          .add(e.response == null ? "null" : e.response!.statusCode.toString());
      instance.setStringList('statuses', statuses);
      instance.setStringList('times', times);
      return e.response?.statusCode;
    }
  } else {
    print("Jo'natilmadi");
  }
}

Future<String> getConnectionType() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return "Mobile";
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return "WiFi";
  } else if (connectivityResult == ConnectivityResult.ethernet) {
    return "Ethernet";
  } else {
    return "None";
  }
}

Future<TimeOfDay?> selectTime(BuildContext context) async {
  final TimeOfDay? picked =
      await showTimePicker(context: context, initialTime: TimeOfDay.now());

  return picked;
}

Future<bool> isCurrentTimeInRange() async {
  SharedPreferences instance = await SharedPreferences.getInstance();
  TimeOfDay currentTime = TimeOfDay.now();
  TimeOfDay? startTime = TimeOfDay(
      hour: int.parse((instance.getString('start') ?? '7:00').split(":").first),
      minute: int.parse((instance.getString('start') ?? '7:00').split(":")[1]));
  TimeOfDay? endTime = TimeOfDay(
      hour: int.parse((instance.getString('end') ?? '21:00').split(":").first),
      minute: int.parse((instance.getString('end') ?? '21:00').split(":")[1]));
  // Convert TimeOfDay to minutes since midnight for easier comparison.
  int currentMinutes = currentTime.hour * 60 + currentTime.minute;
  int startMinutes = startTime.hour * 60 + startTime.minute;
  int endMinutes = endTime.hour * 60 + endTime.minute;

  // Check if current time is between start and end time.
  return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
}

String makeClockFormat(int i) {
  return i < 10 ? "0$i" : i.toString();
}
