@CodeGen(runAfter: [CodeGen.addPartOfDirective])
library main;

import 'package:super_annotations/super_annotations.dart';

import 'annotations.dart';

part 'main.g.dart';

@MyAnnotation()
class MyClass with _$MyClass {}

void main() {
  var v = MyClass();
  v.hello();
}
