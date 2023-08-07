import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:testingbloc_course/bloc/bloc_actions.dart';
import 'package:testingbloc_course/bloc/person.dart';
import 'package:testingbloc_course/bloc/persons_bloc.dart';

const mockedPrsons1 = <Person>[
  Person(
    firstName: "Stanley",
    lastName: "Joho",
    age: 20,
    email: "stanley@gmail.com",
  ),
  Person(
    firstName: "John",
    lastName: "Atuke",
    age: 30,
    email: "john@gmail.com",
  ),
];

const mockedPrsons2 = <Person>[
  Person(
    firstName: "Wanjiku",
    lastName: "Patra",
    age: 21,
    email: "patra@gmail.com",
  ),
];

Future<Iterable<Person>> mockGetPersons1(String url) =>
    Future.value(mockedPrsons1);

Future<Iterable<Person>> mockGetPersons2(String url) =>
    Future.value(mockedPrsons2);

void main() {
  group('Testing bloc', () {
    //Write our tests

    late PersonsBloc bloc;

    setUp(() {
      bloc = PersonsBloc();
    });

    blocTest<PersonsBloc, FetchResults?>(
      'Test initial state',
      build: () => bloc,
      verify: (bloc) => expect(bloc.state, null),
    );

    //fetch mock data (oerson1) and compare it with FetchResult
    blocTest(
      'Mock retrieving persons from first iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          const LoadPersonsAction(url: 'dummy_url_1', loader: mockGetPersons1),
        );
        bloc.add(
          const LoadPersonsAction(url: 'dummy_url_1', loader: mockGetPersons1),
        );
      },
      expect: () => [
        const FetchResults(persons: mockedPrsons1, isRetrievedFromCache: false),
        const FetchResults(persons: mockedPrsons1, isRetrievedFromCache: true),
      ],
    );

    //fetch mock data (person2) and compare it with FetchResult
    blocTest(
      'Mock retrieving persons from second iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
          const LoadPersonsAction(url: 'dummy_url_2', loader: mockGetPersons2),
        );
        bloc.add(
          const LoadPersonsAction(url: 'dummy_url_2', loader: mockGetPersons2),
        );
      },
      expect: () => [
        const FetchResults(persons: mockedPrsons2, isRetrievedFromCache: false),
        const FetchResults(persons: mockedPrsons2, isRetrievedFromCache: true),
      ],
    );
  });
}
