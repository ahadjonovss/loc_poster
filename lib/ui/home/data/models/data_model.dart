class DataModel {
  int id;
  String name;
  String surname;
  int battery;
  String network;
  int lat;
  int long;

  DataModel({
    required this.id,
    required this.name,
    required this.network,
    required this.battery,
    required this.lat,
    required this.long,
    required this.surname
});
}
