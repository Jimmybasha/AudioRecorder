import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_recog/AudioRecord/services/record_service.dart';
import 'package:speech_recog/AudioRecord/view/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'AudioRecord/view_model/audio_player_viewModel/audio_player_cubit.dart';
import 'AudioRecord/view_model/record_cubit.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lfqdlpvjbhhagoscgzum.supabase.co', // from your Supabase dashboard
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxmcWRscHZqYmhoYWdvc2NnenVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1OTI2MjQsImV4cCI6MjA2MDE2ODYyNH0.Y2ewF3u1Q27wS1iP4qyYE68h9smN8EyoCWJTxNcSHbg', // from your Supabase API settings
  );


  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RecordCubit(RecordService())),
        BlocProvider(create: (_) => AudioPlayerCubit(AudioPlayer())),
        // We'll create FluentMeCubit at screen level to improve scoping
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pronunciation Coach',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}