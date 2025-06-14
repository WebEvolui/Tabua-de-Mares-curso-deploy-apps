import 'package:flutter/material.dart';
import 'package:tabua_de_mares/screens/home_screen.dart';

class NoPermission extends StatelessWidget {
  const NoPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 100, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              'Sem permissão para acessar',
              style: TextStyle(fontSize: 20),
            ),
            Text('a localização 😕', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
