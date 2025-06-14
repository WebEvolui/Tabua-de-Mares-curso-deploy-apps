import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

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
  late final String _weekdayWithDateBR = '${_dias[_agora.weekday % 7]} ${_agora.day.toString().padLeft(2, '0')}/${_agora.month.toString().padLeft(2, '0')}/${_agora.year}';


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
