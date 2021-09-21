import 'package:super_annotations/super_annotations.dart';

class JsonSerializable extends ClassAnnotation {
  const JsonSerializable();

  @override
  void apply(Class c, LibraryBuilder l) {
    var fromJson = Method((m) => m
      ..name = '_\$${c.name}FromJson'
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'map'
        ..type = refer('Map<String, dynamic>')))
      ..returns = refer(c.name)
      ..body = c.constructors.first
          .invokeWith(
              c.name,
              (p) => refer('map')
                  .index(literalString(p.name))
                  .asA(p.type!.expression))
          .returned
          .statement);

    var toJson = Method((m) => m
      ..name = '_\$${c.name}ToJson'
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'v'
        ..type = refer(c.name)))
      ..returns = refer('Map<String, dynamic>')
      ..body = literalMap({
        for (var f in c.fields)
          literalString(f.name): refer('v').property(f.name),
      }).returned.statement);

    l.body.addAll([fromJson, toJson]);
  }
}
