import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';

import '../core/utils.dart';

extension ClassCodeBuilder on ClassElement {
  String builder([List<String> writes = const []]) {
    var node = getNode() as ClassDeclaration?;

    var mixins = node?.withClause?.mixinTypes.map((t) => t.name.name) ?? [];
    var annotations = node?.metadata ?? <Annotation>[];

    return """
      Class((c) => c
        ..name = '${name.escaped}'
        ${node?.isAbstract == true ? '..abstract = true' : ''}
        ${node?.extendsClause != null ? "..extend = ${node!.extendsClause!.superclass.builder()}" : ''}
        ${typeParameters.isNotEmpty ? "..types.addAll([${typeParameters.map((t) => t.builder()).join(',')}])" : ''}
        ${node?.implementsClause != null ? "..implements.addAll([${node!.implementsClause!.interfaces.map((t) => t.builder()).join(', ')}])" : ''}
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
        ..name = '${name.escaped}'
        ..type = ${type.builder()}
        ..modifier = FieldModifier.${isFinal ? 'final\$' : isConst ? 'constant' : 'var\$'}
        ..static = $isStatic
        ..late = $isLate
        ${annotations.isNotEmpty ? '..annotations.addAll([${annotations.map((m) => m.builder()).join(',')}])' : ''}
      )
    """;
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
        ${name.isNotEmpty ? "..name = '${name.escaped}'" : ""}
        ..factory = $isFactory
        ..constant = $isConst
        ${reqParams.isNotEmpty ? '..requiredParameters.addAll([${reqParams.join()}])' : ''}
        ${optParams.isNotEmpty ? '..optionalParameters.addAll([${optParams.join()}])' : ''}
        ${node?.redirectedConstructor != null ? "..redirect = refer('${node!.redirectedConstructor!.toString().escaped}')" : ''}
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
        ..name = '${name.escaped}'
        ..type = ${type.builder()}
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
        ..name = '${name.escaped}'
        ..returns = ${returnType.builder()}
        ..requiredParameters.addAll([${parameters.where((p) => p.isRequiredPositional).map((p) => p.builder()).join()}])
        ..optionalParameters.addAll([${parameters.where((p) => !p.isRequiredPositional).map((p) => p.builder()).join()}])
        ..static = $isStatic
        ${annotations.isNotEmpty ? '..annotations.addAll([${annotations.map((m) => m.builder()).join(',')}])' : ''}
      )
    """;
  }
}

extension TypeParameterBuilder on TypeParameter {
  String builder() {
    return """
      TypeReference((t) => t
        ..symbol = '${name.name.escaped}'
        ${bound != null ? "..bound = ${bound!.builder()}" : ''}
      )
    """;
  }
}

extension TypeAnnotationBuilder on TypeAnnotation {
  String builder() {
    return type?.builder() ?? "refer('${toSource().escaped}')";
  }
}

extension AnnotationCodeBuilder on Annotation {
  String builder() {
    return "ResolvedAnnotation(${toSource().substring(1)}, '${toSource().escaped}')";
  }
}

extension TypeCodeBuilder on DartType {
  String builder() {
    return accept(DartTypeVisitor());
  }
}

extension TypeParameterElementBuilder on TypeParameterElement {
  String builder() {
    return """
      TypeReference((t) => t
        ..symbol = '${name.escaped}'
        ${bound != null ? "..bound = ${bound!.builder()}" : ''}
      )
    """;
  }
}

class DartTypeVisitor extends TypeVisitor<String> {
  @override
  String visitDynamicType(DynamicType type) {
    return "refer('dynamic')";
  }

  @override
  String visitFunctionType(FunctionType type) {
    return """
      FunctionType((t) => t
        ${type.typeFormals.isNotEmpty ? '..types.addAll([${type.typeFormals.map((t) => t.builder()).join(', ')}])' : ''}
        ${type.normalParameterTypes.isNotEmpty ? '..requiredParameters.addAll([${type.normalParameterTypes.map((t) => t.builder()).join(', ')}])' : ''}
        ${type.optionalParameterTypes.isNotEmpty ? '..optionalParameters.addAll([${type.optionalParameterTypes.map((t) => t.builder()).join(', ')}])' : ''}
        ${type.namedParameterTypes.isNotEmpty ? '..namedParameters.addEntries([${type.namedParameterTypes.entries.map((e) => "MapEntry('${e.key}', ${e.value.builder()})").join(', ')}])' : ''}
        ..isNullable = ${type.nullabilitySuffix == NullabilitySuffix.question}
        ..returnType = ${type.returnType.builder()}
      )
    """;
  }

  @override
  String visitInterfaceType(InterfaceType type) {
    return """
      TypeReference((t) => t
        ..symbol = '${type.element.name.escaped}'
        ..isNullable = ${type.nullabilitySuffix == NullabilitySuffix.question}
        ${type.typeArguments.isNotEmpty ? '..types.addAll([${type.typeArguments.map((t) => t.builder()).join(', ')}])' : ''}
      )
    """;
  }

  @override
  String visitNeverType(NeverType type) {
    return "refer('Never')";
  }

  @override
  String visitTypeParameterType(TypeParameterType type) {
    return """
      TypeReference((t) => t
        ..symbol = '${type.element.name.escaped}'
        ..isNullable = ${type.nullabilitySuffix == NullabilitySuffix.question}
        ${!type.bound.isDynamic ? "..bound = ${type.bound.builder()}" : ''}
      )
    """;
  }

  @override
  String visitVoidType(VoidType type) {
    return "refer('void')";
  }
}

extension TypeNameCodeBuilder on TypeName {
  String builder() {
    return "refer('${toSource().escaped}')";
  }
}

extension StringEscaped on String {
  String get escaped => replaceAll('\$', '\\\$').replaceAll("'", "\\'");
}
