import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../view_model/record_cubit.dart';
import '../view_model/record_states.dart';

class RecordScreenBody extends StatelessWidget {
  const RecordScreenBody({super.key});

 @override
    Widget build(BuildContext context) {
   final cubit = context.read<RecordCubit>();

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
                 ElevatedButton(
                   onPressed: () => cubit.stopRecording(),
                   child: const Text("Stop"),
                 )
               ],
             ),
           );
         } else if (state is RecordingComplete) {
           final player = AudioPlayer(

           );
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text("Saved at: ${state.filePath}"),
                 ElevatedButton(
                   onPressed: () => cubit.startRecording(),
                   child: const Text("Record Again"),
                 ),
                 ElevatedButton(
                   onPressed: () async {
                     try {
                       await player.setFilePath(state
                           .filePath); // Load the file
                       await player.play(); // Play it
                     } catch (e) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Playback failed: $e')),
                       );
                     }
                   },
                   child: const Text("Play Recording"),
                 ),
               ],
             ),
           );
         } else if (state is RecordError) {
           return Center(child: Text(state.message));
         } else {
           return Center(
             child: ElevatedButton(
               onPressed: () => cubit.startRecording(),
               child: const Text("Start Recording"),
             ),
           );
         }
       },
     ),
   );
 }
}

