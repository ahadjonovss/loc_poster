import 'package:flutter/material.dart';
import 'package:loc_poster/ui/history/ui/history_page.dart';
import 'package:loc_poster/ui/home/ui/widgets/location_button.dart';
import 'package:loc_poster/ui/home/ui/widgets/row_text.dart';
import 'package:loc_poster/utils/assistants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int son = 0;
  String id = '';
  String name = '';
  String surname = '';
  String url = '';

  Future<void> getData() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    id = instance.getString('id') ?? '';
    name = instance.getString('login') ?? '';
    surname = instance.getString('password') ?? '';
    url = instance.getString('url') ?? '';
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
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
            RowText(title: "Parol:", subtitle: surname),
            RowText(title: "Batereya:", subtitle: "85%"),
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
}
