library super_annotations;

import 'package:code_builder/code_builder.dart';

export 'package:code_builder/code_builder.dart';

/// To be extended by custom annotations
abstract class ClassAnnotation {
  const ClassAnnotation();

  /// Overwrite to modify the annotated class before being passed
  /// to the [apply] method of any annotation
  void modify(ClassBuilder builder, Library library) {}

  /// Receive the annotated class as target and modify the output library
  void apply(Class target, LibraryBuilder library) {}
}

class CodeGen {
  /// Contains the path to the current source file for the build
  static String currentFile = '';

  //ignore: unused_element
  CodeGen._();

  /// Use to annotate a function to be run at the beginning of the build phase
  const CodeGen.runBefore();

  /// Use to annotate a function to be run at the end of the build phase
  const CodeGen.runAfter();
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
