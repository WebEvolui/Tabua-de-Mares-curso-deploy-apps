import 'dart:ffi';

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
import 'package:tabua_de_mares/widgets/box_mare.dart';
import 'package:tabua_de_mares/widgets/container_title.dart';

import '../env.dart';
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
        await _fetchCityAndTidalData(_latitude!, _longitude!);
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

  Future<void> _fetchCityAndTidalData(double latitude, double longitude) async {
    try {
      final cityResponse = await http.post(
        Uri.parse('${Env.baseUrl}/api/get-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        }),
      );

      if (cityResponse.statusCode == 200) {
        final cityData = jsonDecode(cityResponse.body);
        final city = cityData['city'];

        setState(() {
          _regiao = cityData['localizacao'];
        });

        // Envia o POST para obter os dados da maré
        final tidalResponse = await http.post(
          Uri.parse('${Env.baseUrl}/api/get-tidal/$city'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'token': Env.tokenApi}),
        );

        if (tidalResponse.statusCode == 200) {
          final alturasData = jsonDecode(tidalResponse.body)['alturas'];
          final extremosData = jsonDecode(tidalResponse.body)['extremos'];

          _alturas.clear();

          alturasData.asMap().forEach((index, item) {
            _alturas.add(
              Altura(
                dt: index,
                date: DateTime.parse(item['date']),
                height: double.parse(item['height'].toStringAsFixed(2)),
              ),
            );
          });

          List<FlSpot> spots = _alturas.map((altura) {
            return FlSpot(altura.dt.toDouble(), altura.height);
          }).toList();

          setState(() {
            this.spots = spots;
            _isFetching = false;
          });

          _extremos.clear();

          extremosData.forEach((item) {
            _extremos.add(
              Extreme(
                date: item['date'],
                height: item['height'],
                type: item['type'],
              ),
            );
          });

          setState(() {
            _alturas = _alturas;
            _extremos = _extremos;
          });
        } else {
          setState(() {
            _error = 'Erro ao obter dados da maré';
            _isFetching = false;
          });
        }
      } else {
        setState(() {
          _error = 'Erro ao obter cidade';
          _isFetching = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao buscar dados da API';
        _isFetching = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 20;
    double itemWidth = (screenWidth - (3 * 8)) / 4;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tábua de Marés',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _getLocation();
            },
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              _shareGraph();
            },
            icon: Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: _error != ''
            ? Center(child: Text(_error))
            : Padding(
                padding: EdgeInsets.all(10),
                child: _isFetching
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ContainerTitle(title: 'Estatísticas'),
                            SizedBox(height: 10),
                            Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _weekdayWithDateBR,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _regiao,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _extremos.map((extremo) {
                                return SizedBox(
                                  width: itemWidth,
                                  child: BoxMare(extremo: extremo),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 20),
                            ContainerTitle(
                              title: 'Previsões de Maré',
                              showIconBar: false,
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
              ),
      ),
    );
  }
}
