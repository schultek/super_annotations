/// Add the CodeGen annotation to the library declaration.
/// This tells the package to run code generation on this library.
/// @param runBefore: An optional list of functions that
///   will be executed before any annotation
@CodeGen(runBefore: [addTitleComment])
library main;

import 'package:super_annotations/super_annotations.dart';

/// First part of the file:
/// Define classes as you normally would,
/// and annotate them with a custom annotation

@MyAnnotation()
class MyClass {
  final String data;

  MyClass(this.data);
}

/// Second part of the file:
/// Define your custom annotations and what they should do
/// This will be executed during the build phase

/// Choose a name and extend [ClassAnnotation]
class MyAnnotation extends ClassAnnotation {
  /// You need a const constructor to be usable as an annotation
  const MyAnnotation();

  /// You have to implement the [apply] method, which will be
  /// executed during the build phase
  /// @param target: A formal description of the annotated class, e.g. its name and fields
  /// @param output: The output that will be generated as part of the build phase
  @override
  void apply(Class target, LibraryBuilder output) {
    /// You can add any declaration or code here
    /// like classes, extensions, mixins, etc.
    /// Example: Add the class name as a comment
    output.body.add(Code('// - ${target.name}\n'));
  }
}

/// Optional: A custom function that will be executed
/// at the beginning of the build phase, before any annotation
/// See [CodeGen.runBefore]
/// @param output: The output that will be generated as part of the build phase
void addTitleComment(LibraryBuilder output) {
  /// Modify the contents of the library
  /// Example: Add a title comment
  output.body.add(Code('// Classes annotated with @MyAnnotation:\n'));
}

void main() {}

/// After running the build step, a new file `main.g.dart` is created with
/// the following contents:
///   // Classes annotated with @MyAnnotation:
///   // - MyClass
