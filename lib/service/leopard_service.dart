import 'package:leopard_flutter/leopard.dart';

class LeopardService {
  late Leopard leopard;
  final String accessKey = 'RzqIRwfjRBLM3w0AfJm6E/3E3VEGXkNHfRqthKkGlJq+NIOrw94GXA==';
  final String modelPath = 'assets/leopard_params.pv';

  Future<void> initLeopard() async {
    leopard = await Leopard.create(accessKey, modelPath);
  }

  Future<String> transcribeAudio(String audioFilePath) async {
    final result = await leopard.processFile(audioFilePath);
    return result.transcript;
  }
}
