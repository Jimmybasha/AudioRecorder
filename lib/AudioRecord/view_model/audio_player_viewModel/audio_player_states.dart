
abstract class AudioPlayerState {}

class AudioPlayerInitial extends AudioPlayerState {}

class AudioPlayerPlaying extends AudioPlayerState {}

class AudioPlayerPaused extends AudioPlayerState {}

class AudioPlayerStopped extends AudioPlayerState {}

class AudioPlayerError extends AudioPlayerState {
  final String message;
  AudioPlayerError(this.message);
}
