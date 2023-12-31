import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loc_poster/ui/history/ui/history_page.dart';
import 'package:loc_poster/ui/home/data/models/data_model.dart';
import 'package:loc_poster/ui/home/ui/widgets/loc_mixin.dart';
import 'package:loc_poster/ui/home/ui/widgets/location_button.dart';
import 'package:loc_poster/ui/home/ui/widgets/row_text.dart';
import 'package:loc_poster/utils/assistants.dart';
import 'package:platform_device_id_v3/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

part 'my_mixin.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with MainMixin, WidgetsBindingObserver {
  int son = 0;
  String id = '';
  String name = '';
  String surname = '';
  String url = '';
  int percent = 0;
  String deviceId = '';

  Future<void> getData() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    id = instance.getString('id') ?? '';
    deviceId = await PlatformDeviceId.getDeviceId ?? '';

    name = instance.getString('login') ?? '';
    surname = instance.getString('password') ?? '';
    url = instance.getString('url') ?? '';
    Battery battery = Battery();
    percent = await battery.batteryLevel;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initController(this);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.withOpacity(0.1),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                getData();
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ))
        ],
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        elevation: 0,
        title: ZoomTapAnimation(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryPage()));
            },
            child: Image.asset('assets/logo.png', width: 70)),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            RowText(title: "ID:", subtitle: id),
            RowText(title: "Login:", subtitle: name),
            RowText(title: "Battery:", subtitle: "$percent %"),
            RowText(title: "DeviceID:", subtitle: "$deviceId"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const LocationButton(),
                // IconButton(
                //     onPressed: () {
                //       if (url.isNotEmpty) {
                //         Workmanager().initialize(callBackDispatcher,
                //             isInDebugMode: true);
                //         Workmanager().initialize(callBackDispatcher1,
                //             isInDebugMode: true);
                //         Workmanager().initialize(callBackDispatcher2,
                //             isInDebugMode: true);
                //         Workmanager().registerPeriodicTask(
                //             "first", "first-task",
                //             constraints: Constraints(
                //                 networkType: NetworkType.connected,
                //                 requiresStorageNotLow: true),
                //             frequency: const Duration(minutes: 15));
                //         Workmanager().registerPeriodicTask(
                //             "second", "second-task",
                //             constraints: Constraints(
                //                 networkType: NetworkType.connected,
                //                 requiresStorageNotLow: true),
                //             frequency: const Duration(minutes: 15));
                //         Workmanager().registerPeriodicTask(
                //             "third", "third-task",
                //             constraints: Constraints(
                //                 networkType: NetworkType.connected,
                //                 requiresStorageNotLow: true),
                //             frequency: const Duration(minutes: 15));
                //       }
                //       setState(() {});
                //     },
                //     icon: Icon(Icons.not_started,
                //         color: url.isNotEmpty ? Colors.green : Colors.red))
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomTapAnimation(
        onLongTap: () async {
          int? code = await postWithDataAndHeaders();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(code.toString())));
        },
        child: FloatingActionButton(
          child: const Icon(Icons.edit),
          onPressed: () async {
            showCupertinoDialog(context);
          },
        ),
      ),
    );
  }

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
    TimeOfDay? startTime = TimeOfDay(
        hour:
            int.parse((instance.getString('start') ?? '7:00').split(":").first),
        minute:
            int.parse((instance.getString('start') ?? '7:00').split(":")[1]));
    TimeOfDay? endTime = TimeOfDay(
        hour:
            int.parse((instance.getString('end') ?? '21:00').split(":").first),
        minute:
            int.parse((instance.getString('end') ?? '21:00').split(":")[1]));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Fill in the details"),
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
                  decoration: const InputDecoration(
                    labelText: 'Login',
                  ),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
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
                        "${makeClockFormat(startTime!.hour)}:${makeClockFormat(startTime!.minute)} - ${makeClockFormat(endTime!.hour)}:${makeClockFormat(endTime!.minute)}"),
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Save'),
              onPressed: () async {
                // Handle the submitted data
                String id = idController.text;
                String login = loginController.text;
                String password = passwordController.text;
                String url = urlController.text;

                SharedPreferences instance =
                    await SharedPreferences.getInstance();
                instance.setString('id', id);
                instance.setString('login', login);
                instance.setString('password', password);
                instance.setString('url', url);
                instance.setInt('duration', int.parse(intervalCtrl.text));
                instance.setString('start',
                    "${startTime == null ? 7 : startTime!.hour}:${startTime == null ? 0 : startTime!.minute}");
                instance.setString('end',
                    "${endTime == null ? 21 : endTime!.hour}:${endTime == null ? 0 : endTime!.minute}");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
