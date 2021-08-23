import 'package:super_annotations/super_annotations.dart';

class MyAnnotation extends ClassAnnotation {
  const MyAnnotation();
  @override
  void apply(Class target, LibraryBuilder library) {
    library.body.add(Mixin((e) => e
      ..name = '_\$${target.name}'
      ..methods.add(Method((m) => m
        ..name = 'hello'
        ..body = Code("print('World');")))))
  }
}
