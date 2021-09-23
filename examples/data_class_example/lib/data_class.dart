import 'package:super_annotations/super_annotations.dart';

class DataClass extends ClassAnnotation {
  const DataClass();

  @override
  void apply(Class target, LibraryBuilder output) {
    var copyWith = Method((m) => m
      ..name = 'copyWith'
      ..returns = refer(target.name)
      ..optionalParameters.addAll([
        for (var p in target.constructors.first.parameters)
          p.rebuild((p) => p
            ..named = true
            ..required = false
            ..toThis = false
            ..defaultTo = null
            ..type = refer('${p.type!.symbol!}?'))
      ])
      ..body = target.constructors.first
          .invokeWith(target.name,
              (p) => refer(p.name).ifNullThen(refer('this.${p.name}')))
          .code);

    var toString = Method((m) => m
      ..name = 'toString'
      ..returns = refer('String')
      ..body = literalString(
              '${target.name}{${target.fields.map((f) => '${f.name}: \$${f.name}').join(', ')}}')
          .code);

    var mixin = Mixin((m) => m
      ..name = '_\$${target.name}'
      ..fields.addAll([])
      ..methods.addAll([
        for (var f in target.fields)
          Method((m) => m
            ..name = f.name
            ..type = MethodType.getter
            ..returns = f.type),
        copyWith,
        toString,
      ]));

    output.body.add(mixin);
  }
}
