import 'models/models.super.dart';

void main() {
  var p1 = Person('Tom', 32);
  print(p1); // prints: Person{name: Tom, age: 32}

  var p2 = p1.copyWith(name: 'Alice');
  print(p2); // prints: Person{name: Alice, age: 32}
}
