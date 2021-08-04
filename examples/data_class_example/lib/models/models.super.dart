import '../data_class.dart';

part 'models.g.dart';

@DataClass()
class Person with _$Person {
  final String name;
  final int age;

  Person(this.name, [this.age = 0]);
}

@DataClass()
class Animal with _$Animal {
  final String name;
  final int height;
  final bool isMammal;

  Animal(this.name, this.height, {this.isMammal = true});
}
