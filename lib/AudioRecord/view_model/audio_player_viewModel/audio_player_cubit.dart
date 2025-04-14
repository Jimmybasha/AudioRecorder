import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'audio_player_states.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer;
  bool isStopped = true;

  AudioPlayerCubit(this._audioPlayer) : super(AudioPlayerInitial()) {
    // Listen for playback state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      print("Player state changed: ${playerState.processingState}");
      if (playerState.processingState == ProcessingState.completed) {
        isStopped = true;
        emit(AudioPlayerStopped());
      }
    });

    // Listen for errors
    _audioPlayer.playbackEventStream.listen(
          (event) {},
      onError: (Object e, StackTrace stackTrace) {
        print("Audio player error: $e");
        print("Stack trace: $stackTrace");
        emit(AudioPlayerError("Playback error: $e"));
      },
    );
  }

  Future<void> toggleAudio(String filePath) async {
    try {
      // Verify the file exists
      final file = File(filePath);
      if (!await file.exists()) {
        print("File doesn't exist: $filePath");
        emit(AudioPlayerError("Audio file not found at: $filePath"));
        return;
      }

      final fileSize = await file.length();
      print("File size: $fileSize bytes");
      if (fileSize <= 44) { // WAV header without data
        print("File appears to be empty (only header)");
        emit(AudioPlayerError("Audio file appears to be empty"));
        return;
      }

      print("Attempting to play file: $filePath");

      if (_audioPlayer.playing) {
        print("Player was playing - pausing");
        await _audioPlayer.pause();
        emit(AudioPlayerPaused());
      } else {
        if (isStopped) {
          print("Player stopped - setting new source");
          try {
            await _audioPlayer.setFilePath(filePath);
            final duration = await _audioPlayer.duration;
            print("Audio duration: $duration");

            if (duration == null || duration.inMilliseconds < 100) {
              print("Warning: Audio file has very short or null duration");
            }

            isStopped = false;
          } catch (e) {
            print("Error setting audio source: $e");
            emit(AudioPlayerError("Failed to load audio: $e"));
            return;
          }
        } else {
          print("Player was paused - resuming");
        }

        try {
          await _audioPlayer.play();
          print("Playback started");
          emit(AudioPlayerPlaying());
        } catch (e) {
          print("Error playing audio: $e");
          emit(AudioPlayerError("Failed to play audio: $e"));
        }
      }
    } catch (e) {
      print("Unexpected error in toggle audio: $e");
      emit(AudioPlayerError("Error playing audio: $e"));
    }
  }

  // Add a method to play test audio from assets
  Future<void> playTestAsset(String assetPath) async {
    try {
      print("Playing test audio from asset: $assetPath");
      await _audioPlayer.setAsset(assetPath);
      final duration = await _audioPlayer.duration;
      print("Test audio duration: $duration");
      await _audioPlayer.play();
      isStopped = false;
      emit(AudioPlayerPlaying());
    } catch (e) {
      print("Error playing test audio: $e");
      emit(AudioPlayerError("Error playing test audio: $e"));
    }
  }

  Future<void> stopAudio() async {
    print("Stopping audio playback");
    await _audioPlayer.stop();
    isStopped = true;
    emit(AudioPlayerStopped());
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}