import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:loc_poster/ui/splash/ui/splash_page.dart';
import 'package:loc_poster/utils/assistants.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void printHello() async {
  await postWithDataAndHeaders();
}

@pragma('vm:entry-point')
Future<void> callBackDispatcher2() async {
  Workmanager().executeTask((task, inputData) async {
    await postWithDataAndHeaders();

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), 1, printHello,
      rescheduleOnReboot: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
