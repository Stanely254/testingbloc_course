import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_actions.dart';
import 'person.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == other.length;
}

class PersonsBloc extends Bloc<LoadAction, FetchResults?> {
  final Map<String, Iterable<Person>> _cache = {};
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
        final loader = event.loader;
        final persons = await loader(url);
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

  @override
  bool operator ==(covariant FetchResults other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashCode => Object.hash(persons, isRetrievedFromCache);
}
