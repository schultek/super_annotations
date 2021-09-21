part of 'main.dart';

Person _$PersonFromJson(Map<String, dynamic> map) {
  return Person((map['name'] as String), age: (map['age'] as int));
}

Map<String, dynamic> _$PersonToJson(Person v) {
  return {'name': v.name, 'age': v.age};
}
