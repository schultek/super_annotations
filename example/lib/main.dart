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
  /// @param clazz: A formal description of the annotated class, e.g. its name and fields
  /// @param library: The library that will be generated as output of the build phase
  @override
  void apply(Class target, LibraryBuilder library) {
    /// You can add any declaration or code here
    /// like classes, extensions, mixins, etc.
    library.body.add(Code('// - ${target.name}\n'));
  }
}

/// Optional: Define a custom function that will be executed
/// at the beginning of the build phase, before the annotations
/// Alternatively, you can also use @CodeGen.runAfter()
/// @param library: The library that will be generated as output of the build phase
@CodeGen.runBefore()
void writeOutput(LibraryBuilder library) {
  /// Modify the contents of the library
  /// Here: Add a title comment
  library.body.add(Code('// Classes annotated with @MyAnnotation\n'));
}

void main() {}

/// After running the build step, a new file `example.g.dart` is created with
/// the following contents:
///   // Classes annotated with @MyAnnotation
///   // - MyClass
