import 'package:super_annotations/super_annotations.dart';

class DataClass extends ClassAnnotation {
  const DataClass();

  @override
  void apply(Class c, LibraryBuilder l) {
    var copyWith = Method((m) => m
      ..name = 'copyWith'
      ..returns = refer(c.name)
      ..optionalParameters.addAll([
        for (var p in c.constructors.first.parameters)
          p.rebuild((p) => p
            ..named = true
            ..required = false
            ..toThis = false
            ..defaultTo = null
            ..type = refer('${p.type!.symbol!}?'))
      ])
      ..body = c.constructors.first
          .invokeWith(
              c.name, (p) => refer(p.name).ifNullThen(refer('this.${p.name}')))
          .code);

    var toString = Method((m) => m
      ..name = 'toString'
      ..returns = refer('String')
      ..body = literalString(
              '${c.name}{${c.fields.map((f) => '${f.name}: \$${f.name}').join(', ')}}')
          .code);

    var mixin = Mixin((m) => m
      ..name = '_\$${c.name}'
      ..fields.addAll([])
      ..methods.addAll([
        for (var f in c.fields)
          Method((m) => m
            ..name = f.name
            ..type = MethodType.getter
            ..returns = f.type),
        copyWith,
        toString,
      ]));

    l.body.add(mixin);
  }
}
