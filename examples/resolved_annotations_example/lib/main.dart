@CodeGen(runAfter: [CodeGen.addPartOfDirective])
library main;

import 'package:super_annotations/super_annotations.dart';

import 'annotations.dart';
import 'annotations2.dart';

part 'main.g.dart';

@MyAnnotation()
class MyClass {
  @WrapGetter('data')
  String _internal;

  MyClass(this._internal);
}

void main() {
  var v = MyClass('hallo');
  print(v.data); // prints: hallo
}
