import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../view_model/audio_player_viewModel/audio_player_cubit.dart';
import '../view_model/audio_player_viewModel/audio_player_states.dart';

class AudioPlayerScreen extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioPlayerCubit(_audioPlayer),
      child: Scaffold(
        appBar: AppBar(title: const Text("Audio Player")),
        body: Center(
          child: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
            builder: (context, state) {
              if (state is AudioPlayerPlaying) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => context
                          .read<AudioPlayerCubit>()
                          .stopAudio(), // Stop audio
                      child: const Text("Stop Audio"),
                    ),
                  ],
                );
              } else if (state is AudioPlayerPaused) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => context
                          .read<AudioPlayerCubit>()
                          .toggleAudio("your-file-id"), // Resume audio
                      child: const Text("Resume Audio"),
                    ),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AudioPlayerCubit>()
                          .stopAudio(), // Stop audio
                      child: const Text("Stop Audio"),
                    ),
                  ],
                );
              } else if (state is AudioPlayerStopped) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => context
                          .read<AudioPlayerCubit>()
                          .toggleAudio("your-file-id"), // Play audio
                      child: const Text("Play Audio"),
                    ),
                  ],
                );
              } else if (state is AudioPlayerError) {
                return Center(
                  child: Text(state.message),
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context
                        .read<AudioPlayerCubit>()
                        .toggleAudio("your-file-id"), // Play audio
                    child: const Text("Play Audio"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
