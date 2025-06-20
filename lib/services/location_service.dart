import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env.dart';

class LocationService {
  Future<String> fetchCity(double latitude, double longitude) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/api/get-location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao obter cidade');
    }

    final data = jsonDecode(response.body);
    return data['city'];
  }

  Future<String> fetchRegiao(double latitude, double longitude) async {
    final response = await http.post(
      Uri.parse('${Env.baseUrl}/api/get-location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao obter região');
    }

    final data = jsonDecode(response.body);
    return data['localizacao'];
  }
}
