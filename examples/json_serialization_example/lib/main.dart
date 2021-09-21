@CodeGen(runAfter: [CodeGen.addPartOfDirective])
library main;

import 'package:super_annotations/super_annotations.dart';

import 'json_serializable.dart';

part 'main.g.dart';

@JsonSerializable()
class Person {
  final String name;
  final int? age;
  Person(this.name, {this.age});

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

void main() {
  var p = Person('Steffen', age: 23);
  var map = p.toJson();
  print(map);

  var p2 = Person.fromJson(map);
  print(p2.name);
}
