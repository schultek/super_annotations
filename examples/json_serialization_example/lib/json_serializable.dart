import 'package:super_annotations/super_annotations.dart';

class JsonSerializable extends ClassAnnotation {
  const JsonSerializable();

  @override
  void apply(Class target, LibraryBuilder output) {
    var fromJson = Method((m) => m
      ..name = '_\$${target.name}FromJson'
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'map'
        ..type = refer('Map<String, dynamic>')))
      ..returns = refer(target.name)
      ..body = target.constructors.first
          .invokeWith(
              target.name,
              (p) => refer('map')
                  .index(literalString(p.name))
                  .asA(p.type!.expression))
          .returned
          .statement);

    var toJson = Method((m) => m
      ..name = '_\$${target.name}ToJson'
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'v'
        ..type = refer(target.name)))
      ..returns = refer('Map<String, dynamic>')
      ..body = literalMap({
        for (var f in target.fields)
          literalString(f.name): refer('v').property(f.name),
      }).returned.statement);

    output.body.addAll([fromJson, toJson]);
  }
}
