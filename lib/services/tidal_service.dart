import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tabua_de_mares/models/tidal_data.dart';
import '../env.dart';
import '../models/altura.dart';
import '../models/extreme.dart';

class TidalService {
  Future<TidalData> fetchTidalData(String city) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/api/get-tidal/$city'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': Env.tokenApi}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao obter dados da maré');
    }

    final data = jsonDecode(response.body);
    final alturasData = data['alturas'];
    final extremosData = data['extremos'];

    final alturas = alturasData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return Altura(
        dt: index,
        date: DateTime.parse(item['date']),
        height: double.parse(item['height'].toStringAsFixed(2)),
      );
    }).toList();

    final extremos = extremosData.map<Extreme>((item) {
      return Extreme(
        date: item['date'],
        height: item['height'],
        type: item['type'],
      );
    }).toList();

    return TidalData(alturas: alturas, extremos: extremos);
  }
}
