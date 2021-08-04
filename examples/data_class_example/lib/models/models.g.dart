part of 'models.super.dart';

mixin _$Person {
  String get name;
  int get age;
  Person copyWith({String? name, int? age}) =>
      Person(name ?? this.name, age ?? this.age);
  String toString() => 'Person{name: $name, age: $age}';
}
mixin _$Animal {
  String get name;
  int get height;
  bool get isMammal;
  Animal copyWith({String? name, int? height, bool? isMammal}) =>
      Animal(name ?? this.name, height ?? this.height,
          isMammal: isMammal ?? this.isMammal);
  String toString() =>
      'Animal{name: $name, height: $height, isMammal: $isMammal}';
}
