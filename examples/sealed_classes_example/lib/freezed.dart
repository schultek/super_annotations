import 'package:super_annotations/super_annotations.dart';

const freezed = Freezed();

class Freezed extends ClassAnnotation {
  const Freezed();

  @override
  void apply(Class target, LibraryBuilder output) {
    var mapMethod = Method((mm) => mm
      ..name = 'map'
      ..lambda = true
      ..returns = refer('TResult')
      ..types.add(refer('TResult'))
      ..optionalParameters.addAll([
        for (var factory in target.constructors.where((c) => c.factory))
          Parameter((p) => p
            ..name = factory.name ?? factory.redirect!.symbol!.toLowerCase()
            ..type = FunctionType((ft) => ft
              ..returnType = refer('TResult')
              ..requiredParameters
                  .add(refer(factory.redirect!.symbol! + ' value')))
            ..named = true
            ..required = true),
      ]));

    var mc = Mixin((m) => m
      ..name = '_\$${target.name}'
      ..methods.addAll([
        mapMethod.rebuild((m) =>
            m.body = refer('UnimplementedError').newInstance([]).thrown.code),
      ]));
    output.body.add(mc);

    for (var factory in target.constructors.where((c) => c.factory)) {
      if (factory.redirect != null) {
        var fc = Class((fc) => fc
          ..name = factory.redirect!.symbol
          ..implements.add(refer(target.name))
          ..fields.addAll([
            for (var p in factory.requiredParameters
                .followedBy(factory.optionalParameters))
              Field((f) => f
                ..name = p.name
                ..type = p.type
                ..modifier = FieldModifier.final$),
          ])
          ..constructors.add(Constructor((c) => c
            ..constant = factory.constant
            ..requiredParameters.addAll(
                factory.requiredParameters.map((p) => p.rebuild((pp) => pp
                  ..toThis = true
                  ..type = null)))
            ..optionalParameters.addAll(
                factory.optionalParameters.map((p) => p.rebuild((pp) => pp
                  ..toThis = true
                  ..type = null)))))
          ..methods.addAll([
            mapMethod.rebuild((m) => m.body =
                refer(factory.name ?? factory.redirect!.symbol!.toLowerCase())
                    .call([refer('this')]).code),
          ]));
        output.body.add(fc);
      }
    }
  }
}
