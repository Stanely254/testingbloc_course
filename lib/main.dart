import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'dart:math' as math show Random;

const names = [
  'Foo',
  'Bar',
  'Barz',
];

extension RanomElement<T> on Iterable<T> {
  T getRandomElement() => elementAt(math.Random().nextInt(length));
}

class NamesCubit extends Cubit<String?> {
  NamesCubit() : super(null);

  void pickRandomName() => emit(names.getRandomElement());
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NamesCubit namesCubit;

  @override
  void initState() {
    super.initState();
    namesCubit = NamesCubit();
  }

  @override
  void dispose() {
    namesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: StreamBuilder<String?>(
        stream: namesCubit.stream,
        builder: (context, snapshot) {
          final button = TextButton(
            onPressed: () {
              namesCubit.pickRandomName();
            },
            child: const Text('Pick a random name'),
          );

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return button;
            case ConnectionState.waiting:
              return button;
            case ConnectionState.active:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.data ?? ''),
                    button,
                  ],
                ),
              );

            case ConnectionState.done:
              return const SizedBox();
            default:
              return Container();
          }
        },
      ),
    );
  }
}
