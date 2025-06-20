import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

class GraphSharerService {
  final ScreenshotController screenshotController;

  GraphSharerService(this.screenshotController);

  Future<void> shareGraph() async {
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
}
