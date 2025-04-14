import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_recog/AudioRecord/Repository/fluentme_repository_impl.dart';
import 'package:speech_recog/AudioRecord/view_model/fluentme_viewModel/fluentMe_cubit.dart';

import 'fluentMe_screen_body.dart';

class FluentMeScreen extends StatelessWidget {
  const FluentMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FluentMeCubit(repository: FluentMeRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pronunciation Score'),
        ),
        body:  FluentMeScreenBody(),
      ),
    );
  }
}