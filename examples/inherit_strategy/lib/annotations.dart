import 'package:super_annotations/super_annotations.dart';

class MyAnnotation extends ClassAnnotation {
  const MyAnnotation();
  @override
  void apply(Class target, LibraryBuilder output) {
    output.body.add(Class((e) => e
      ..name = target.name.substring(1)
      ..extend = refer(target.name)
      ..fields.add(Field((f) => f
        ..name = '_logs'
        ..type = refer('List<String>')
        ..assignment = literalList([]).code))
      ..methods.addAll([
        for (var method in target.methods)
          method.rebuild((m) => m
            ..annotations.add(refer('override'))
            ..body = Block.of([
              Code(
                  "_logs.add('Method invoked: ${method.name}(${method.requiredParameters.map((p) => "\${${p.name}}").join(', ')})');"),
              refer('super.${method.name}')
                  .call(method.requiredParameters.map((p) => refer(p.name)))
                  .returned
                  .statement,
            ])),
        Method((m) => m
          ..name = 'logs'
          ..returns = refer('void')
          ..body = Code("print(_logs.join('\\n'));"))
      ])));
  }
}
