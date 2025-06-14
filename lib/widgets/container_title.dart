import 'package:flutter/material.dart';

class ContainerTitle extends StatelessWidget {
  String title;
  bool showIconBar;

  ContainerTitle({super.key, required this.title, this.showIconBar = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 0.5),
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(
            showIconBar ? Icons.bar_chart : Icons.ssid_chart,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
}
