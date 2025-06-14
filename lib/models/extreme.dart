class Extreme {
  final String date;
  final double height;
  final String type;

  Extreme({required this.date, required this.height, required this.type});

  factory Extreme.fromJson(Map<String, dynamic> json) {
    return Extreme(
      date: json['date'],
      height: (json['height'] as num).toDouble(),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'height': height, 'type': type};
  }

  String getHeightWithMeter() {
    return '${height.toStringAsFixed(2).toString().replaceAll('.', ',')}m';
  }

  String getHourFormatted() {
    return date.toString().substring(11, 16).replaceAll(':', 'h');
  }

  bool isLow() {
    return type == 'Low';
  }
}
