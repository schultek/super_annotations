library super_annotations;

import 'package:code_builder/code_builder.dart';
// ignore: implementation_imports
import 'package:code_builder/src/mixins/annotations.dart';
// ignore: implementation_imports
import 'package:code_builder/src/specs/code.dart';

export 'package:code_builder/code_builder.dart';

abstract class SuperAnnotation<T extends Spec> {
  const SuperAnnotation();

  /// Receive the annotated declaration as target and modify the output library
  void apply(T target, LibraryBuilder output);
}

/// Extend this to create a custom annotation for classes
abstract class ClassAnnotation extends SuperAnnotation<Class> {
  const ClassAnnotation();

  /// Overwrite to modify the annotated class before being passed
  /// to the [apply] method of any annotation
  void modify(ClassBuilder builder) {}
}

/// Extend this to create a custom annotation for enums
abstract class EnumAnnotation extends SuperAnnotation<Enum> {
  const EnumAnnotation();
}

/// Extend this to create a custom annotation for functions
abstract class FunctionAnnotation extends SuperAnnotation<Method> {
  const FunctionAnnotation();
}

typedef CodeGenHook = void Function(LibraryBuilder output);

class CodeGen {
  /// Contains the path to the current source file for the build
  static String currentFile = '';

  /// Contains the current target
  static String currentTarget = '';

  /// Functions to be run at the beginning of the build phase,
  /// before any annotation
  final List<CodeGenHook> runBefore;

  /// Functions to be run at the end of the build phase,
  /// after every annotation
  final List<CodeGenHook> runAfter;

  const CodeGen({
    this.runBefore = const [],
    this.runAfter = const [],
  });

  static void addPartOfDirective(LibraryBuilder library) {
    library.directives.add(Directive.partOf(CodeGen.currentFile));
  }
}

extension Cascade<T> on T {
  void run(void Function(T target) fn) => fn(this);
}

extension ConstructorParameters on Constructor {
  Iterable<Parameter> get parameters =>
      requiredParameters.followedBy(optionalParameters);
  Iterable<Parameter> get positionalParameters => requiredParameters.followedBy(
      optionalParameters.any((p) => p.named) ? [] : optionalParameters);
  Iterable<Parameter> get namedParameters =>
      optionalParameters.any((p) => p.named) ? optionalParameters : [];
}

extension ToMap<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() => Map.fromEntries(this);
}

extension InvokeConstructor on Constructor {
  Expression invokeWith(
      String className, Expression Function(Parameter p) toExpression) {
    var posArgs = positionalParameters.map(toExpression);
    var namedArgs =
        namedParameters.map((p) => MapEntry(p.name, toExpression(p))).toMap();
    return name != null
        ? refer(className).newInstanceNamed(name!, posArgs, namedArgs)
        : refer(className).newInstance(posArgs, namedArgs);
  }
}

/// Special type of expression to store an annotation object during runtime
class ResolvedAnnotation<T> extends Expression {
  final String source;
  final T annotation;
  ResolvedAnnotation(this.annotation, this.source);

  @override
  R accept<R>(covariant ExpressionVisitor<R> visitor, [R? context]) {
    return visitor.visitAnnotation(this, context);
  }
}

/// Extension to quickly access all resolved annotations of a spec element
extension HasResolvedAnnotations on HasAnnotations {
  List<dynamic> get resolvedAnnotations {
    return annotations
        .whereType<ResolvedAnnotation>()
        .map((a) => a.annotation)
        .toList();
  }

  List<T> resolvedAnnotationsOfType<T>() {
    return resolvedAnnotations.whereType<T>().toList();
  }
}

/// Special type of code to hold a resolved value during runtime
class ResolvedValue<T> implements Code {
  final T value;
  final String code;

  ResolvedValue(this.value, this.code);

  @override
  R accept<R>(covariant CodeVisitor<R> visitor, [R? context]) {
    return visitor.visitStaticCode(Code(code) as StaticCode, context);
  }
}

/// Extension to quickly access the resolved default value of a parameter
extension DefaultValue on Parameter {
  dynamic get defaultValue =>
      defaultTo is ResolvedValue ? (defaultTo! as ResolvedValue).value : null;
}
