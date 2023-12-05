import 'package:battery_plus/battery_plus.dart';

class MainRepository {
  Future<void> listenBattery() async {
    var battery = Battery();
    print(await battery.batteryLevel);
  }
}
