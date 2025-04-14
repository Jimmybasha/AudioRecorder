import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_recog/AudioRecord/services/record_service.dart';
import 'AudioRecord/view/record_screen.dart';
import 'AudioRecord/view_model/audio_player_viewModel/audio_player_cubit.dart';
import 'AudioRecord/view_model/record_cubit.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RecordCubit(RecordService())),
        BlocProvider(create: (_) => AudioPlayerCubit(AudioPlayer())), // Initialize the AudioPlayerCubit
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech Recorder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RecordScreen(),
    );

  }
}
