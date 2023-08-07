import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

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

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction extends LoadAction {
  final PersonUrl url;
  const LoadPersonsAction({required this.url}) : super();
}

enum PersonUrl {
  persons1,
  persons2,
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

@immutable
class Person {
  final String firstName;
  final String lastName;
  final int age;
  final String email;

  const Person(
      {required this.firstName,
      required this.lastName,
      required this.age,
      required this.email});

  Person.fromJson(Map<String, dynamic> json)
      : firstName = json['firstName'] as String,
        age = json['age'] as int,
        lastName = json['lastName'] as String,
        email = json['email'] as String;
}

Future<Iterable<Person>> getPersons(String url) {
  return HttpClient()
      .getUrl(Uri.parse(url))
      .then((req) => req.close())
      .then((res) => res.transform(utf8.decoder).join())
      .then((str) => json.decode(str)['users'] as List<dynamic>)
      .then((list) => list.map<Person>((e) => Person.fromJson(e)));
}

@immutable
class FetchResults {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;
  const FetchResults({
    required this.persons,
    required this.isRetrievedFromCache,
  });

  @override
  String toString() {
    return 'FetchResult (isRetrievedFromCache = $isRetrievedFromCache, persons = $persons)';
  }
}

class PersonsBloc extends Bloc<LoadAction, FetchResults?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  PersonsBloc() : super(null) {
    on<LoadPersonsAction>((event, emit) async {
      //todo
      final url = event.url;
      if (_cache.containsKey(url)) {
        // we have the value from cache
        final cachedPersons = _cache[url];
        final result = FetchResults(
          persons: cachedPersons!,
          isRetrievedFromCache: true,
        );
        emit(result);
      } else {
        final persons = await getPersons(url.urlString);
        _cache[url] = persons;
        final result = FetchResults(
          persons: persons,
          isRetrievedFromCache: false,
        );
        emit(result);
      }
    });
  }
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
                            const LoadPersonsAction(url: PersonUrl.persons1),
                          );
                    },
                    child: const Text('Load json #1')),
                TextButton(
                    onPressed: () {
                      context.read<PersonsBloc>().add(
                            const LoadPersonsAction(url: PersonUrl.persons2),
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
