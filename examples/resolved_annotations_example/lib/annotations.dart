import 'package:super_annotations/super_annotations.dart';

import 'annotations2.dart';

class MyAnnotation extends ClassAnnotation {
  const MyAnnotation();
  @override
  void apply(Class target, LibraryBuilder output) {
    output.body.add(Extension((e) => e
      ..name = '${target.name}Extension'
      ..on = refer(target.name)
      ..methods.addAll([
        for (var field in target.fields)
          for (var annotation in field.resolvedAnnotationsOfType<WrapGetter>())
            Method((m) => m
              ..name = annotation.getterName
              ..type = MethodType.getter
              ..returns = field.type
              ..body = refer(field.name).returned.statement),
      ])));
  }
}
