import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

import 'bloc/bloc_actions.dart';
import 'bloc/person.dart';
import 'bloc/persons_bloc.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => PersonsBloc(),
        child: const HomePage(),
      ),
    ),
  );
}

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.persons1:
        return 'https://dummyjson.com/users';
      case PersonUrl.persons2:
        return 'https://dummyjson.com/users';
    }
  }
}

Future<Iterable<Person>> getPersons(String url) {
  return HttpClient()
      .getUrl(Uri.parse(url))
      .then((req) => req.close())
      .then((res) => res.transform(utf8.decoder).join())
      .then((str) => json.decode(str)['users'] as List<dynamic>)
      .then((list) => list.map<Person>((e) => Person.fromJson(e)));
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Bar'),
      ),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      context.read<PersonsBloc>().add(
                            const LoadPersonsAction(
                              url: personUrl1,
                              loader: getPersons,
                            ),
                          );
                    },
                    child: const Text('Load json #1')),
                TextButton(
                    onPressed: () {
                      context.read<PersonsBloc>().add(
                            LoadPersonsAction(
                              url: personUrl2,
                              loader: (url) {
                                return getPersons(url);
                              },
                            ),
                          );
                    },
                    child: const Text('Load json #2')),
              ],
            ),
            BlocBuilder<PersonsBloc, FetchResults?>(
              buildWhen: (previous, current) {
                return previous?.persons != current?.persons;
              },
              builder: (context, fetchResult) {
                fetchResult?.log();
                final persons = fetchResult?.persons;
                if (persons == null) {
                  return const SizedBox();
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (context, index) {
                      final person = persons[index];
                      return ListTile(
                        title: Text(person?.firstName ?? ""),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
