import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

extension ClassCodeBuilder on ClassElement {
  String builder([List<String> writes = const []]) {
    var node = getNode() as ClassDeclaration;

    var mixins = node.withClause?.mixinTypes.map((t) => t.name.name) ?? [];

    return """
      Class((c) => c
        ..name = '$name'
        ${fields.isNotEmpty ? "..fields.addAll([${fields.map((f) => f.builder()).join(',')}])" : ''}
        ${constructors.isNotEmpty ? "..constructors.addAll([${constructors.map((c) => c.builder()).join(',')}])" : ''}
        ${mixins.isNotEmpty ? "..mixins.addAll([${mixins.map((m) => "refer('${m.escaped}')").join(',')}])" : ''}
        ${methods.isNotEmpty ? "..methods.addAll([${methods.map((m) => m.builder()).join(',')}])" : ''}
      )
      ${writes.map((w) => "..run((c) => $w().apply(c, l))").join("\n")};
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

extension ConstructorCodeBuilder on ConstructorElement {
  String builder() {
    List<String> reqParams = [], optParams = [];

    var node = getNode() as ConstructorDeclaration;

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
        ${node.redirectedConstructor != null ? "..redirect = refer('${node.redirectedConstructor!.toString()}')" : ''})
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
    return """
      Method((m) => m
        ..name = '$name'
        ..returns = refer('${returnType.getDisplayString(withNullability: true)}')
        ..requiredParameters.addAll([${parameters.where((p) => p.isRequiredPositional).map((p) => p.builder()).join()}])
        ..optionalParameters.addAll([${parameters.where((p) => !p.isRequiredPositional).map((p) => p.builder()).join()}])
        ..static = $isStatic
      )
    """;
  }
}

extension ElementToNode on Element {
  AstNode getNode() {
    var node =
        (session!.getParsedLibraryByElement2(library!) as ParsedLibraryResult)
            .getElementDeclaration(this)!
            .node;
    return node;
  }
}

extension StringEscaped on String {
  String get escaped => replaceAll('\$', '\\\$').replaceAll("'", "\\'");
}
