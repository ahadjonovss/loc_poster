import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class LocationButton extends StatefulWidget {
  const LocationButton({super.key});

  @override
  State<LocationButton> createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton> {
  bool isGranted = false;

  getStatus() async {
    isGranted = await Permission.location.isGranted;
    setState(() {});
  }

  @override
  void initState() {
    getStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: () async {
        print("Salom");
        await Permission.location.request();
        getStatus();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        height: 60,
        width: 90,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.deepPurple,
            )),
        child: Icon(
          Icons.location_on,
          color: isGranted ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
