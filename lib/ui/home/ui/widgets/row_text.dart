import 'package:flutter/material.dart';

class RowText extends StatelessWidget {
  String title;
  String subtitle;
  RowText({required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
