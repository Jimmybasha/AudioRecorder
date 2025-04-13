import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<String?> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/recorded_audio.wav';

      await _recorder.start(
        path: path,
       const RecordConfig(
         encoder: AudioEncoder.wav,
         bitRate: 128000,
         sampleRate: 16000,
       )
      );
      return path;
    }
    return null;
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    if (path != null) {
      final file = File(path);
      final size = await file.length();
      print("Audio file saved at: $path");
      print("Audio file size: $size bytes");
    } else {
      print("No audio file returned.");
    }
    return path;
  }


  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }
}
