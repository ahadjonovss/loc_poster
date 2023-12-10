import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:loc_poster/ui/home/data/models/data_model.dart';
import 'package:location/location.dart';

mixin class LocationMixin {
  LocationMixin._();

  static LocationMixin get instance => LocationMixin._();
  final Location location = Location();

  Future<Points> determinePosition() async {
    if (!await hasPermission()) {
      return determinePosition();
    }
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.low,
    );
    return Points(latitude: position.latitude, longitude: position.longitude);
  }

  Future<bool> hasPermission() async {
    late PermissionStatus permissionGranted;

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied ||
        permissionGranted == PermissionStatus.deniedForever) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.denied ||
          permissionGranted != PermissionStatus.deniedForever) {
        return false;
      }
    }
    return location.serviceEnabled();
  }

  Future<bool> isRequestService() async {
    if (!(await location.serviceEnabled())) {
      return location.requestService();
    }
    return true;
  }
}
