import 'package:flutter/foundation.dart' show immutable;

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
