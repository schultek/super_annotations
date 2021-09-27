@CodeGen()
library main;

import 'package:super_annotations/super_annotations.dart';

import 'annotations.dart';

@MyClassAnnotation()
class MyClass {
  MyClass(this.myField);
  String myField;
}

@MyEnumAnnotation()
enum MyEnum { myValue }

@MyFunctionAnnotation()
void myFunction(String myParam) {}

void main() {}
