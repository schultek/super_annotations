import 'models/person.super.dart';

void main() {
  var p = Person('Steffen', age: 23);
  var map = p.toJson();
  print(map);

  var p2 = Person.fromJson(map);
  print(p2.name);
}
