import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_recog/AudioRecord/view_model/audio_player_viewModel/audio_player_cubit.dart';
import 'package:speech_recog/AudioRecord/view_model/audio_player_viewModel/audio_player_states.dart';
import 'package:speech_recog/AudioRecord/view_model/fluentme_viewModel/fluentMe_cubit.dart';
import 'package:speech_recog/AudioRecord/view_model/fluentme_viewModel/fluentMe_states.dart';
import 'package:speech_recog/AudioRecord/view_model/record_cubit.dart';
import 'package:speech_recog/AudioRecord/view_model/record_states.dart';



class FluentMeScreenBody extends StatelessWidget {
  AudioPlayer _audioPlayer = AudioPlayer();

   FluentMeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordCubit, RecordState>(
      builder: (context, recordState) {
        // Recording in progress UI
        if (recordState is RecordingInProgress) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Recording your pronunciation...",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  onPressed: () => context.read<RecordCubit>().stopRecording(),
                  child: const Text("Stop Recording"),
                )
              ],
            ),
          );
        }
        // Recording completed UI
        else if (recordState is RecordingComplete) {
          return BlocConsumer<FluentMeCubit, FluentMeState>(
            listener: (context, state) {
              if (state is FluentMeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is FluentMeInitial) {
                // Automatically trigger scoring when recording is complete
                // and FluentMeCubit is still in initial state
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<FluentMeCubit>().scoreRecording(
                    audioFilePath: recordState.filePath,
                    postId: "P535421169", // Configure as needed
                    scale: 90, // Configure as needed
                  );
                });

                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Processing your recording...'),
                      SizedBox(height: 20),
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }
              // Loading state while API processes the recording
              else if (state is FluentMeLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Analyzing your pronunciation...'),
                    ],
                  ),
                );
              }
              // Success state showing the pronunciation score
              else if (state is FluentMeSuccess) {
                final result = state.response;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Score: ${result.overallResultData.overallPoints.toStringAsFixed(1)}/90',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your transcript:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(result.overallResultData.userRecordingTranscript),
                      const SizedBox(height: 16),
                      Text(
                        'Words recognized: ${result.overallResultData.numberOfRecognizedWords}/${result.overallResultData.numberOfWordsInPost}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),

                      // Audio playback controls
                      BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                        builder: (context, playerState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await context.read<AudioPlayerCubit>().toggleAudio(recordState.filePath);
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
                                  onPressed: () => context.read<AudioPlayerCubit>().stopAudio(),
                                  child: const Text("Stop"),
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Word-by-word analysis:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: result.wordResultData.length,
                        itemBuilder: (context, index) {
                          final word = result.wordResultData[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(word.word),
                              subtitle: Text('Speed: ${word.speed}'),
                              trailing: Text(
                                '${word.points.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: word.points > 70
                                      ? Colors.green
                                      : word.points > 40
                                      ? Colors.orange
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: ()async {
                          // Play AI reading from the result
                          // Need to implement this - possibly use AudioPlayerCubit
                          await _audioPlayer.setUrl(result.overallResultData.aiReading);
                          _audioPlayer.play();
                        },
                        child: const Text('Play AI Reading'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<RecordCubit>().startRecording(),
                        child: const Text("Record Again"),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('An error occurred'),
                );
              }
            },
          );
        }
        // Error state
        else if (recordState is RecordError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 10),
                Text("Error: ${recordState.message}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.read<RecordCubit>().startRecording(),
                  child: const Text("Try Again"),
                ),
              ],
            ),
          );
        }
        // Initial state - Ready to record
        else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic, size: 64),
                const SizedBox(height: 20),
                const Text("Ready to record your pronunciation",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Press the button below to start recording, then speak clearly into your microphone.",
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.read<RecordCubit>().startRecording(),
                  child: const Text("Start Recording"),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}