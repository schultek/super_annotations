@CodeGen(runAfter: [CodeGen.addPartOfDirective])
library main;

import 'package:super_annotations/super_annotations.dart';

import 'annotations.dart';

part 'main.g.dart';

@MyAnnotation()
class $MyClass {
  void hello(String name) {
    print('Hello $name');
  }
}

void main() {
  var v = MyClass();
  v.hello('John'); // prints: Hello John
  v.hello('Anna'); // prints: Hello Anna

  v.logs();
  // prints:
  // Method invoked: hello(John)
  // Method invoked: hello(Anna)
}
