class Altura {
  final int dt;
  final DateTime date;
  final double height;

  Altura({required this.dt, required this.date, required this.height});

  factory Altura.fromJson(Map<String, dynamic> json) {
    return Altura(
      dt: json['dt'],
      date: DateTime.parse(json['date']),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'dt': dt, 'date': date.toIso8601String(), 'height': height};
  }
}
