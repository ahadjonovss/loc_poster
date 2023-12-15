// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showCupertinoDialog(BuildContext context) async {
  TextEditingController idController = TextEditingController();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController intervalCtrl = TextEditingController();

  SharedPreferences instance = await SharedPreferences.getInstance();
  idController.text = instance.getString('id') ?? '0';
  loginController.text = instance.getString('login') ?? '';
  passwordController.text = instance.getString('password') ?? '';
  urlController.text = instance.getString('url') ?? '';
  intervalCtrl.text = (instance.getInt('duration') ?? 5).toString();
  print((instance.getString('start') ?? '7:00').split(":").first);
  print("Salomjon");
  TimeOfDay? startTime = TimeOfDay(
      hour: int.parse((instance.getString('start') ?? '7:00').split(":").first),
      minute: int.parse((instance.getString('start') ?? '7:00').split(":")[1]));
  TimeOfDay? endTime = TimeOfDay(
      hour: int.parse((instance.getString('end') ?? '21:00').split(":").first),
      minute: int.parse((instance.getString('end') ?? '21:00').split(":")[1]));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text("Ma'lumotlarni kiriting"),
        content: Card(
          color: Colors.transparent,
          elevation: 0.0,
          child: Column(
            children: <Widget>[
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'ID',
                ),
              ),
              TextField(
                controller: loginController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Login',
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Parol',
                ),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'API',
                ),
              ),
              TextField(
                controller: intervalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Interval',
                ),
              ),
              Row(
                children: [
                  Text(
                      "${startTime!.hour} :${startTime!.minute}- ${endTime!.hour} :${endTime!.minute}"),
                  IconButton(
                      onPressed: () async {
                        startTime = await selectTime(context);
                        endTime = await selectTime(context);
                      },
                      icon: Icon(Icons.edit))
                ],
              )
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('Bekor qilish'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text('Saqlash'),
            onPressed: () async {
              // Handle the submitted data
              String id = idController.text;
              String login = loginController.text;
              String password = passwordController.text;
              String url = urlController.text;

              SharedPreferences instance =
                  await SharedPreferences.getInstance();
              instance.setString('id', id);
              instance.setString('password', login);
              instance.setString('login', password);
              instance.setString('url', url);
              instance.setInt('duration', int.parse(intervalCtrl.text));
              instance.setString(
                  'start', "${startTime?.hour}:${startTime?.minute}");
              instance.setString('end', "${endTime?.hour}:${endTime?.minute}");
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

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
          : 'Basic ${stringToBase64(login)}:${stringToBase64(password)}'
    };

    print(headers);
    print(DateTime.now());

    print({
      "latitude": position == null ? 0 : position.latitude.toString(),
      "longitude": position == null ? 0 : position.longitude.toString(),
      "agent_id": id,
      "battery": "$percent %",
      "accuracy": position == null ? '0 m' : '${position.accuracy} m',
      "gps": true,
      "internet": connection
    });

    try {
      dio.options.headers.addAll(headers);
      Response response = await dio.post(url, data: {
        "latitude": position == null ? 0 : position.latitude.toString(),
        "longitude": position == null ? 0 : position.longitude.toString(),
        "agent_id": id,
        "battery": "83%",
        "accuracy": position == null ? '0 m' : '${position.accuracy} m',
        "gps": true,
        "internet": connection
      });

      SharedPreferences instance = await SharedPreferences.getInstance();
      List<String> times = instance.getStringList('times') ?? [];
      List<String> statuses = instance.getStringList('statuses') ?? [];
      times.add(DateTime.now().toString());
      statuses.add(response.statusCode.toString());
      instance.setStringList('statuses', statuses);
      instance.setStringList('times', times);
      return response.statusCode;
    } on DioError catch (e) {
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
