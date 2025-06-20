import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/models/altura.dart';
import '/models/extreme.dart';
import '../services/graph_sharer_service.dart';
import '/services/location_service.dart';
import '/services/tidal_service.dart';
import '/models/tidal_data.dart';

class HomeController extends ChangeNotifier {
  final GraphSharerService _graphSharerService;
  final LocationService _locationService;
  final TidalService _tidalService;

  HomeController(
      this._graphSharerService,
      this._locationService,
      this._tidalService,
      );

  // Estados da tela
  bool isLoading = false;
  String regiao = '';
  String error = '';
  List<Altura> alturas = [];
  List<Extreme> extremos = [];
  List<FlSpot> spots = [];

  /// Compartilhar o gráfico
  Future<void> onShareGraph() async {
    try {
      notifyListeners();
      await _graphSharerService.shareGraph();
    } catch (e) {
      debugPrint('Erro ao compartilhar gráfico: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Buscar dados de cidade e maré
  Future<void> fetchCityAndTidalData(double latitude, double longitude) async {
    try {
      isLoading = true;
      notifyListeners();

      final city = await _locationService.fetchCity(latitude, longitude);
      final localizacao = await _locationService.fetchRegiao(
        latitude,
        longitude,
      );

      regiao = localizacao;

      final tidalData = await _tidalService.fetchTidalData(city);

      alturas = tidalData.alturas;
      extremos = tidalData.extremos;
      spots = alturas
          .map((altura) => FlSpot(altura.dt.toDouble(), altura.height))
          .toList();

      error = '';
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
