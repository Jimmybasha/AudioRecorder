import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecorderInitialized = false;

  Future<void> _initializeRecorder() async {
    if (!_isRecorderInitialized) {
      try {
        final isSupported = await _recorder.isEncoderSupported(AudioEncoder.wav);
        print("Is WAV encoder supported: $isSupported");
        _isRecorderInitialized = true;
      } catch (e) {
        print("Failed to initialize recorder: $e");
      }
    }
  }

  Future<String?> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      // Initialize recorder
      await _initializeRecorder();

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${dir.path}/recording_$timestamp.wav';

      print("Starting recording to: $path");

      try {
        // Higher quality settings for better compatibility
        await _recorder.start(
            path: path,
            const RecordConfig(
              encoder: AudioEncoder.wav,
              bitRate: 128000,
              sampleRate: 44100, // Standard CD-quality sample rate
              numChannels: 1,    // Mono recording for simplicity
            )
        );

        // Verify recording actually started
        bool isRecording = await _recorder.isRecording();
        print("Recording started: $isRecording");

        if (!isRecording) {
          print("Failed to start recording even though no exception was thrown");
          return null;
        }

        return path;
      } catch (e) {
        print("Error starting recording: $e");
        return null;
      }
    } else {
      print("Microphone permission denied");
      return null;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          print("Recording stopped. File saved at: $path");
          print("Audio file size: $size bytes");

          if (size <= 44) { // WAV header is 44 bytes, so this would be an empty recording
            print("WARNING: Audio file appears to be empty (only contains header)");
          }

          return path;
        } else {
          print("File doesn't exist at path: $path");
          return null;
        }
      } else {
        print("No audio file returned after stopping recording");
        return null;
      }
    } catch (e) {
      print("Error stopping recording: $e");
      return null;
    }
  }

  Future<bool> isRecording() async {
    final recording = await _recorder.isRecording();
    print("Recording status: $recording");
    return recording;
  }

  Future<void> dispose() async {
    await _recorder.dispose();
    _isRecorderInitialized = false;
  }
}