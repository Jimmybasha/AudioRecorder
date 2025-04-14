import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/audio_player_viewModel/audio_player_cubit.dart';
import '../view_model/audio_player_viewModel/audio_player_states.dart';
import '../view_model/record_cubit.dart';
import '../view_model/record_states.dart';

class RecordScreenBody extends StatelessWidget {
  const RecordScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final recordCubit = context.read<RecordCubit>();
    final audioPlayerCubit = context.read<AudioPlayerCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Record Audio')),
      body: BlocBuilder<RecordCubit, RecordState>(
        builder: (context, state) {
          if (state is RecordingInProgress) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Recording..."),
                  const SizedBox(height: 20),
                  // Visual indicator
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => recordCubit.stopRecording(),
                    child: const Text("Stop"),
                  )
                ],
              ),
            );
          } else if (state is RecordingComplete) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Recording saved successfully!",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text("File path: ${state.filePath}",
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 20),
                  BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                    builder: (context, playerState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await audioPlayerCubit.toggleAudio(state.filePath);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Playback failed: $e')),
                                );
                              }
                            },
                            child: Text(
                                playerState is AudioPlayerPlaying ? "Pause" : "Play Recording"
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (playerState is AudioPlayerPlaying || playerState is AudioPlayerPaused)
                            ElevatedButton(
                              onPressed: () => audioPlayerCubit.stopAudio(),
                              child: const Text("Stop"),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => recordCubit.startRecording(),
                    child: const Text("Record Again"),
                  ),
                  const SizedBox(height: 20),
                  // Add this button to test with a built-in sound
                  ElevatedButton(
                    onPressed: () {
                      // Make sure to add a test.mp3 file to your assets
                      // and register it in pubspec.yaml
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            'Please add a test.mp3 file to your assets directory and uncomment this code'
                        )),
                      );
                      // audioPlayerCubit.playTestAsset('assets/test.mp3');
                    },
                    child: const Text("Test Audio System"),
                  ),
                ],
              ),
            );
          } else if (state is RecordError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 10),
                  Text("Error: ${state.message}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => recordCubit.startRecording(),
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, size: 64),
                  const SizedBox(height: 20),
                  Text("Ready to record",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => recordCubit.startRecording(),
                    child: const Text("Start Recording"),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}