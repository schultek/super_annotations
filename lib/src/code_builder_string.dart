import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';

import 'imports_builder.dart';

extension EnumCodeBuilder on EnumElement {
  String builder(ImportsBuilder imports, [List<String> writes = const []]) {
    return """
      Enum((e) => e
        ..name = '${name.escaped}'
        ..values.addAll([${fields.where((f) => f.isEnumConstant).map((v) => v.builder(imports)).join(',')}])
        ${metadata.isNotEmpty ? '..annotations.addAll([${metadata.map((m) => m.builder(imports)).join(',')}])' : ''}
      )
      ${writes.map((w) => "..run((e) => $w.apply(e, l))").join("\n")};
    """;
  }
}

extension ClassCodeBuilder on ClassElement {
  String builder(ImportsBuilder imports, [List<String> writes = const []]) {
    return """
      Class((c) => c
        ..name = '${name.escaped}'
        ${isAbstract ? '..abstract = true' : ''}
        ${supertype != null ? "..extend = ${supertype!.builder()}" : ''}
        ${typeParameters.isNotEmpty ? "..types.addAll([${typeParameters.map((t) => t.builder()).join(',')}])" : ''}
        ${interfaces.isNotEmpty ? "..implements.addAll([${interfaces.map((t) => t.builder()).join(',')}])" : ''}
        ${fields.isNotEmpty ? "..fields.addAll([${fields.map((f) => f.builder(imports)).join(',')}])" : ''}
        ${constructors.isNotEmpty ? "..constructors.addAll([${constructors.map((c) => c.builder(imports)).join(',')}])" : ''}
        ${mixins.isNotEmpty ? "..mixins.addAll([${mixins.map((m) => m.builder()).join(',')}])" : ''}
        ${methods.isNotEmpty ? "..methods.addAll([${methods.map((m) => m.builder(imports)).join(',')}])" : ''}
        ${metadata.isNotEmpty ? '..annotations.addAll([${metadata.map((m) => m.builder(imports)).join(',')}])' : ''}
        ${writes.map((w) => "..run((c) => $w.modify(c))").join("\n")}
      )
      ${writes.map((w) => "..run((c) => $w.apply(c, l))").join("\n")};
    """;
  }
}

extension FieldCodeBuilder on FieldElement {
  String builder(ImportsBuilder imports) {
    if (isEnumConstant) {
      return """
        EnumValue((v) => v
          ..name = '${name.escaped}'
          ${metadata.isNotEmpty ? '..annotations.addAll([${metadata.map((m) => m.builder(imports)).join(',')}])' : ''}
        )
      """;
    }
    return """
      Field((f) => f
        ..name = '${name.escaped}'
        ..type = ${type.builder()}
        ..modifier = FieldModifier.${isFinal ? 'final\$' : isConst ? 'constant' : 'var\$'}
        ..static = $isStatic
        ..late = $isLate
        ${metadata.isNotEmpty ? '..annotations.addAll([${metadata.map((m) => m.builder(imports)).join(',')}])' : ''}
      )
    """;
  }
}

extension FunctionBuilder on FunctionElement {
  String builder(ImportsBuilder imports, [List<String> writes = const []]) {
    return """
      Method((m) => m
        ..name = '${name.escaped}'
        ..types.addAll([${typeParameters.map((t) => t.builder()).join(',')}])
        ..returns = ${returnType.builder()}
        ..external = $isExternal
        ${isAsynchronous || isGenerator ? '..modifier = MethodModifier.${isAsynchronous ? 'async' : 'sync'}${isGenerator ? '*' : ''}' : ''}
        ..optionalParameters.addAll([${parameters.where((p) => !p.isRequiredPositional).map((p) => p.builder(imports)).join(',')}])
        ..requiredParameters.addAll([${parameters.where((p) => p.isRequiredPositional).map((p) => p.builder(imports)).join(',')}])
        ${metadata.isNotEmpty ? '..annotations.addAll([${metadata.map((m) => m.builder(imports)).join(',')}])' : ''}
      )
      ${writes.map((w) => "..run((m) => $w.apply(m, l))").join("\n")};
    """;
  }
}

extension ConstructorCodeBuilder on ConstructorElement {
  String builder(ImportsBuilder imports) {
    List<String> reqParams = [], optParams = [];

    var node = getNode() as ConstructorDeclaration?;
    for (var p in parameters) {
      if (p.isOptional || p.isNamed) {
        optParams.add(p.builder(imports));
      } else {
        reqParams.add(p.builder(imports));
      }
    }

    return """
      Constructor((c) => c
        ${name.isNotEmpty ? "..name = '${name.escaped}'" : ""}
        ..factory = $isFactory
        ..constant = $isConst
        ${reqParams.isNotEmpty ? '..requiredParameters.addAll([${reqParams.join(',')}])' : ''}
        ${optParams.isNotEmpty ? '..optionalParameters.addAll([${optParams.join(',')}])' : ''}
        ${node?.redirectedConstructor != null ? "..redirect = refer('${node!.redirectedConstructor!.toString().escaped}')" : ''}
        ${metadata.isNotEmpty ? '..annotations.addAll([${metadata.map((m) => m.builder(imports)).join(',')}])' : ''}
      )
    """;
  }
}

extension ParameterCodeBuilder on ParameterElement {
  String builder(ImportsBuilder imports) {
    var isFieldFormal = this is FieldFormalParameterElement;
    return """
      Parameter((p) => p
        ..name = '${name.escaped}'
        ..type = ${type.builder()}
        ..toThis = $isFieldFormal
        ..named = $isNamed
        ..required = ${isNamed && isRequired}
        ..defaultTo = ${hasDefaultValue ? "ResolvedValue($defaultValueCode, '${defaultValueCode!.escaped}')" : null}
        ${metadata.isNotEmpty ? '..annotations.addAll([${metadata.map((m) => m.builder(imports)).join(',')}])' : ''}
      )
    """;
  }
}

extension MethodCodeBuilder on MethodElement {
  String builder(ImportsBuilder imports) {
    return """
      Method((m) => m
        ..name = '${name.escaped}'
        ..returns = ${returnType.builder()}
        ..types.addAll([${typeParameters.map((t) => t.builder()).join(',')}])
        ..requiredParameters.addAll([${parameters.where((p) => p.isRequiredPositional).map((p) => p.builder(imports)).join(',')}])
        ..optionalParameters.addAll([${parameters.where((p) => !p.isRequiredPositional).map((p) => p.builder(imports)).join(',')}])
        ..static = $isStatic
        ${metadata.isNotEmpty ? '..annotations.addAll([${metadata.map((m) => m.builder(imports)).join(',')}])' : ''}
      )
    """;
  }
}

extension AnnotationCodeBuilder on ElementAnnotation {
  String builder(ImportsBuilder imports) {
    if (element?.library != null) {
      imports.add(element!.library!.source.uri);
    }
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

class DartTypeVisitor extends UnifyingTypeVisitor<String> {
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
        ${type.bound is! DynamicType ? "..bound = ${type.bound.builder()}" : ''}
      )
    """;
  }

  @override
  String visitVoidType(VoidType type) {
    return "refer('void')";
  }

  @override
  String visitRecordType(Object type) {
    return "refer('record')";
  }

  @override
  String visitDartType(DartType type) {
    return "refer('${type.getDisplayString(withNullability: true)}')";
  }
}

extension StringEscaped on String {
  String get escaped => replaceAll('\$', '\\\$').replaceAll("'", "\\'");
}

extension ElementToNode on Element {
  AstNode? getNode() {
    var node =
        (session?.getParsedLibraryByElement(library!) as ParsedLibraryResult?)
            ?.getElementDeclaration(this)
            ?.node;
    return node;
  }
}
