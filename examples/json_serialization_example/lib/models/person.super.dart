import '../json_serializable.dart';

part 'person.g.dart';

@JsonSerializable()
class Person {
  final String name;
  final int? age;
  Person(this.name, {this.age});

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
