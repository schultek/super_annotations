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
        ${node?.isAbstract == true ? '..abstract = true' : ''}
        ${node?.extendsClause != null ? "..extend = refer('${node!.extendsClause!.superclass.toSource()}')" : ''}
        ${node?.implementsClause != null ? "..implements.addAll([${node!.implementsClause!.interfaces.map((t) => "refer('${t.toSource()}')").join(', ')}])" : ''}
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
    var varNode = getNode() as VariableDeclaration?;
    var node = varNode?.parent?.parent as FieldDeclaration?;
    var annotations = node?.metadata ?? <Annotation>[];

    return """
      Field((f) => f
        ..name = '$name'
        ..type = refer('${type.getDisplayString(withNullability: true)}')
        ..modifier = FieldModifier.${isFinal ? 'final\$' : isConst ? 'constant' : 'var\$'}
        ..static = $isStatic
        ..late = $isLate
        ${annotations.isNotEmpty ? '..annotations.addAll([${annotations.map((m) => m.builder()).join(',')}])' : ''}
      )
    """;
  }
}

extension AnnotationCodeBuilder on Annotation {
  String builder() {
    return "ResolvedAnnotation(${toSource().substring(1)}, '${toSource().escaped}')";
  }
}

extension ConstructorCodeBuilder on ConstructorElement {
  String builder() {
    List<String> reqParams = [], optParams = [];

    var node = getNode() as ConstructorDeclaration?;
    var annotations = node?.metadata ?? <Annotation>[];

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
        ${node?.redirectedConstructor != null ? "..redirect = refer('${node!.redirectedConstructor!.toString()}')" : ''}
        ${annotations.isNotEmpty ? '..annotations.addAll([${annotations.map((m) => m.builder()).join(',')}])' : ''}
      )
    """;
  }
}

extension ParameterCodeBuilder on ParameterElement {
  String builder() {
    var isFieldFormal = this is FieldFormalParameterElement;

    var node = getNode() as FormalParameter?;
    var annotations = node?.metadata ?? <Annotation>[];

    return """
      Parameter((p) => p
        ..name = '$name'
        ..type = refer('${type.getDisplayString(withNullability: true)}')
        ..toThis = $isFieldFormal
        ..named = $isNamed
        ..required = ${isNamed && isNotOptional}
        ..defaultTo = ${hasDefaultValue ? "ResolvedValue($defaultValueCode, '${defaultValueCode!.escaped}')" : null}
        ${annotations.isNotEmpty ? '..annotations.addAll([${annotations.map((m) => m.builder()).join(',')}])' : ''}
      ),
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
