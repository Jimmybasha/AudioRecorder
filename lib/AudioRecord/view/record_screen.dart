import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_recog/AudioRecord/view/record_screen_body.dart';

import '../services/record_service.dart';
import '../view_model/record_cubit.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocProvider(
        create:(context) => RecordCubit(RecordService()),
      child: const RecordScreenBody(),
    );
  }


  }

