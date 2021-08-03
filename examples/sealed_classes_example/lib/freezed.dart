import 'package:super_annotations/super_annotations.dart';

@CodeGen.runAfter()
void addPartOfDirective(LibraryBuilder l) {
  l.directives.add(Directive.partOf(CodeGen.currentFile));
}

const freezed = Freezed();

class Freezed extends ClassAnnotation {
  const Freezed();

  @override
  void apply(Class c, LibraryBuilder l) {
    var mapMethod = Method((mm) => mm
      ..name = 'map'
      ..lambda = true
      ..returns = refer('TResult')
      ..types.add(refer('TResult'))
      ..optionalParameters.addAll([
        for (var factory in c.constructors.where((c) => c.factory))
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
      ..name = c.mixins.first.symbol
      ..methods.addAll([
        mapMethod.rebuild((m) =>
            m.body = refer('UnimplementedError').newInstance([]).thrown.code),
      ]));
    l.body.add(mc);

    for (var factory in c.constructors.where((c) => c.factory)) {
      if (factory.redirect != null) {
        var fc = Class((fc) => fc
          ..name = factory.redirect!.symbol
          ..implements.add(refer(c.name))
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
        l.body.add(fc);
      }
    }
  }
}
