import 'package:flutter/foundation.dart' show immutable;
import 'package:testingbloc_course/bloc/person.dart';

const personUrl1 = 'https://dummyjson.com/users';
const personUrl2 = 'https://dummyjson.com/users';

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction extends LoadAction {
  final String url;
  final PersonsLoader loader;
  const LoadPersonsAction({
    required this.url,
    required this.loader,
  }) : super();
}

enum PersonUrl {
  persons1,
  persons2,
}
