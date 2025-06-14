import 'package:flutter/material.dart';
import 'package:tabua_de_mares/models/extreme.dart';

class BoxMare extends StatelessWidget {
  Extreme extremo;

  BoxMare({super.key, required this.extremo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Maré ${extremo.isLow() ? 'Baixa' : 'Alta'}',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          Icon(
            extremo.isLow() ? Icons.trending_down : Icons.trending_up,
            color: extremo.isLow() ? Colors.indigo : Colors.red,
          ),
          Text(extremo.getHeightWithMeter()),
          Text(extremo.getHourFormatted()),
        ],
      ),
    );
  }
}
