import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tabua_de_mares/screens/home_screen.dart';
import 'package:tabua_de_mares/controllers/home_controller.dart';
import 'package:tabua_de_mares/services/graph_sharer_service.dart';
import 'package:tabua_de_mares/services/location_service.dart';
import 'package:tabua_de_mares/services/tidal_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider<ScreenshotController>(create: (_) => ScreenshotController()),
        Provider<GraphSharerService>(
          create: (context) =>
              GraphSharerService(context.read<ScreenshotController>()),
        ),

        Provider<LocationService>(create: (_) => LocationService()),

        Provider<TidalService>(create: (_) => TidalService()),

        ChangeNotifierProvider(
          create: (context) => HomeController(
            context.read<GraphSharerService>(),
            context.read<LocationService>(),
            context.read<TidalService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tábua de Marés',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}
