import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:tabua_de_mares/screens/no_permission.dart';

import '../models/altura.dart';
import '../models/extreme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  double? _latitude;
  double? _longitude;
  bool _isFetching = true;
  String _error = '';
  List<Altura> _alturas = [];
  List<Extreme> _extremos = [];
  List<FlSpot>? spots;
  String _regiao = '';
  final _agora = DateTime.now();
  late final _horaAtual = _agora.hour + (_agora.minute / 60);
  final _dias = [
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];
  late final String _anoMesDia =
      '${_agora.year}-${_agora.month.toString().padLeft(2, '0')}-${_agora.day.toString().padLeft(2, '0')}';
  late final String _weekdayWithDateBR =
      '${_dias[_agora.weekday % 7]} ${_agora.day.toString().padLeft(2, '0')}/${_agora.month.toString().padLeft(2, '0')}/${_agora.year}';

  Future<void> _shareGraph() async {
    final Uint8List? image = await screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/grafico.png';
    final file = File(path);
    await file.writeAsBytes(image);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: 'Gráfico da Tábua de Maré de hoje',
      ),
    );
  }

  Future<void> _getLocation() async {
    setState(() {
      _isFetching = true;
      _error = '';
    });

    final Location locationService = Location();

    try {
      try {
        bool serviceEnabled = await locationService.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await locationService.requestService();
          if (!serviceEnabled) {
            _navigateToNoPermissionScreen();
            return;
          }
        }
      } on PlatformException catch (e) {
        setState(() {
          _error = 'Erro ao verificar serviço de localização: $e';
        });

        await _getLocation();
        return;
      }

      PermissionStatus permissionGranted = await locationService
          .hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await locationService.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          _navigateToNoPermissionScreen();
          return;
        }
      }

      final locationData = await locationService.getLocation();
      setState(() {
        _latitude = locationData.latitude;
        _longitude = locationData.longitude;
      });

      if (_latitude != null && _longitude != null) {
        await _fetchCityAndTidalData(_latitude, _longitude);
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter localização: $e';
        _isFetching = false;
      });
    }
  }

  void _navigateToNoPermissionScreen() {
    if (!mounted) {
      setState(() {
        _error = 'Sem permissão para acessar a localização';
        _isFetching = false;
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const NoPermission()),
    );
  }



  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
