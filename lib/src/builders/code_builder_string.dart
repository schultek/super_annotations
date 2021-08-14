import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

import '../core/utils.dart';

extension ClassCodeBuilder on ClassElement {
  String builder([List<String> writes = const []]) {
    var node = getNode() as ClassDeclaration?;

    var mixins = node?.withClause?.mixinTypes.map((t) => t.name.name) ?? [];
    var annotations = node?.metadata ?? <Annotation>[];

    return """
      Class((c) => c
        ..name = '$name'
        ${fields.isNotEmpty ? "..fields.addAll([${fields.map((f) => f.builder()).join(',')}])" : ''}
        ${constructors.isNotEmpty ? "..constructors.addAll([${constructors.map((c) => c.builder()).join(',')}])" : ''}
        ${mixins.isNotEmpty ? "..mixins.addAll([${mixins.map((m) => "refer('${m.escaped}')").join(',')}])" : ''}
        ${methods.isNotEmpty ? "..methods.addAll([${methods.map((m) => m.builder()).join(',')}])" : ''}
        ${annotations.isNotEmpty ? '..annotations.addAll([${annotations.map((m) => m.builder()).join(',')}])' : ''}
      )
      ${writes.map((w) => "..run((c) => $w.apply(c, l))").join("\n")};
    """;
  }
}

extension FieldCodeBuilder on FieldElement {
  String builder() {
    return """
      Field((f) => f
        ..name = '$name'
        ..type = refer('${type.getDisplayString(withNullability: true)}')
        ..modifier = FieldModifier.${isFinal ? 'final\$' : isConst ? 'constant' : 'var\$'}
        ..static = $isStatic
      )
    """;
  }
}

extension AnnotationCodeBuilder on Annotation {
  String builder() {
    if (arguments != null) {
      var str = "refer('${name.name}')";
      if (constructorName != null) {
        str += ".newInstanceNamed('${constructorName!.name}', ";
      } else {
        str += '.newInstance(';
      }

      var posArgs = <Expression>[];
      var namedArgs = <String, Expression>{};

      for (var a in arguments!.arguments) {
        if (a is NamedExpression) {
          namedArgs[a.name.label.name] = a.expression;
        } else {
          posArgs.add(a);
        }
      }

      str +=
          '[${posArgs.map((a) => "refer('${a.toString().replaceAll("'", "\\'")}')").join(', ')}]';

      if (namedArgs.isNotEmpty) {
        str +=
            ', {${namedArgs.entries.map((e) => "'${e.key}': refer('${e.value.toString().replaceAll("'", "\\'")}')").join(', ')}}';
      }

      return '$str)';
    } else {
      return "refer('${name.name}')";
    }
  }
}

extension ConstructorCodeBuilder on ConstructorElement {
  String builder() {
    List<String> reqParams = [], optParams = [];

    var node = getNode() as ConstructorDeclaration?;

    for (var p in parameters) {
      if (p.isOptional || p.isNamed) {
        optParams.add(p.builder());
      } else {
        reqParams.add(p.builder());
      }
    }

    return """
      Constructor((c) => c
        ${name.isNotEmpty ? "..name = '$name'" : ""}
        ..factory = $isFactory
        ..constant = $isConst
        ${reqParams.isNotEmpty ? '..requiredParameters.addAll([${reqParams.join()}])' : ''}
        ${optParams.isNotEmpty ? '..optionalParameters.addAll([${optParams.join()}])' : ''}
        ${node?.redirectedConstructor != null ? "..redirect = refer('${node!.redirectedConstructor!.toString()}')" : ''})
    """;
  }
}

extension ParameterCodeBuilder on ParameterElement {
  String builder() {
    var isFieldFormal = this is FieldFormalParameterElement;
    return """
      Parameter((p) => p
        ..name = '$name'
        ..type = refer('${type.getDisplayString(withNullability: true)}')
        ..toThis = $isFieldFormal
        ..named = $isNamed
        ..required = ${isNamed && isNotOptional}
        ..defaultTo = ${hasDefaultValue ? "Code('${defaultValueCode!.replaceAll("'", "\\'")}')" : null}),
    """;
  }
}

extension MethodCodeBuilder on MethodElement {
  String builder() {
    var node = getNode() as MethodDeclaration?;
    var annotations = node?.metadata ?? <Annotation>[];
    return """
      Method((m) => m
        ..name = '$name'
        ..returns = refer('${returnType.getDisplayString(withNullability: true)}')
        ..requiredParameters.addAll([${parameters.where((p) => p.isRequiredPositional).map((p) => p.builder()).join()}])
        ..optionalParameters.addAll([${parameters.where((p) => !p.isRequiredPositional).map((p) => p.builder()).join()}])
        ..static = $isStatic
        ${annotations.isNotEmpty ? '..annotations.addAll([${annotations.map((m) => m.builder()).join(',')}])' : ''}
      )
    """;
  }
}

extension StringEscaped on String {
  String get escaped => replaceAll('\$', '\\\$').replaceAll("'", "\\'");
}
