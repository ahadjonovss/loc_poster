class TrackingModel {
  int id;
  String name;
  String surname;
  int battery;
  String network;
  double lat;
  double long;

  TrackingModel(
      {required this.id,
      this.name = '',
      this.network = '',
      required this.battery,
      required this.lat,
      required this.long,
      this.surname = ''});
}

class Points {
  num latitude;
  num longitude;
  Points({required this.longitude, required this.latitude});
}
