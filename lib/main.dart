import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/access_bloc.dart';
import 'view/home_page.dart';

void main() => runApp(const Lab6App());

class Lab6App extends StatelessWidget {
  const Lab6App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторная 6',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: BlocProvider(
        create: (_) => AccessBloc(),
        child: const HomePage(),
      ),
    );
  }
}