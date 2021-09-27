import 'package:super_annotations/super_annotations.dart';

class MyClassAnnotation extends ClassAnnotation {
  const MyClassAnnotation();
  @override
  void apply(Class target, LibraryBuilder output) {
    output.body.add(
        Code('// Class: ${target.name} ${target.fields.map((f) => f.name)}\n'));
  }
}

class MyEnumAnnotation extends EnumAnnotation {
  const MyEnumAnnotation();

  @override
  void apply(Enum target, LibraryBuilder output) {
    output.body.add(
        Code('// Enum: ${target.name} ${target.values.map((v) => v.name)}\n'));
  }
}

class MyFunctionAnnotation extends FunctionAnnotation {
  const MyFunctionAnnotation();

  @override
  void apply(Method target, LibraryBuilder output) {
    output.body.add(Code(
        '// Function: ${target.name} ${target.requiredParameters.map((p) => p.name)}\n'));
  }
}
