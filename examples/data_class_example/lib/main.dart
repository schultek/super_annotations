@CodeGen(runAfter: [CodeGen.addPartOfDirective])
library main;

import 'package:super_annotations/super_annotations.dart';

import 'data_class.dart';

part 'main.g.dart';

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

void main() {
  var p1 = Person('Tom', 32);
  print(p1); // prints: Person{name: Tom, age: 32}

  var p2 = p1.copyWith(name: 'Alice');
  print(p2); // prints: Person{name: Alice, age: 32}
}
