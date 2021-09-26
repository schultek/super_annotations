# Super Annotations

Hassle-free static metaprogramming as you dream it. Use code generation and custom annotations with ease.

- Write your code generation functions naturally alongside your normal code.
- Define and use custom annotations in the same file or project.

For the first time, this makes code generation applicable for all kinds of projects. 
No complex setup, no experience in writing builders needed.

> While this package is fully functional, it should be considered more of a concept piece for now, on how to do static metaprogramming in dart.
> Some parts took inspiration from [this github discussion](https://github.com/dart-lang/language/issues/1482).

## Outline

- [Get Started](#get-started)
- [Generating code](#generating-code)
  - [Generation hooks](#generation-hooks)
  - [When it fails](#when-it-fails)
  - [Debugging](#debugging)
- [Available Annotations](#available-annotations)  
- [Mastering Annotations](#mastering-annotations)
  - [Annotation parameters](#annotation-parameters)
  - [Resolved annotations](#resolved-annotations)
- [Examples](#examples)
  - [Part-of strategy](#part-of-strategy)
  - [Inherit strategy](#inherit-strategy)
  - [Json serialization](#json-serialization)
  - [Sealed classes](#sealed-classes)
  - [Data classes](#data-classes)
  - [Resolved annotations](#resolved-annotations-example)
- [How does it work?](#how-does-it-work)
  - [Bonus: Why super?](#bonus-why-super)

> This package is still in active development. If you have any feedback or feature requests, write me and issue on github.

## Get Started

First, add `super_annotations` as a dependency, and `build_runner` as a dev_dependency.

```shell script
pub add super_annotations
pub add build_runner --dev
```

> For every `pub` command prefix it with either `dart` or `flutter` depending on your project.

Next, define your custom annotation like this:

```dart
import 'package:super_annotations/super_annotations.dart';

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
    // Your custom implementation here
  }
}
```

The `target` parameter will hold all the information about the annotated class, and the 
`library` parameter can be used to produce your code generation output in a formal way.

Access information about the class using `target.name`, `target.fields` and so on. 
Add code to the generation output using: `library.body.add(...)`. 
You can add declarations like `Class(...)`, `Extension(...)`, `Mixin(...)` etc, or use raw strings with `Code('...')`.

Finally annotate the library directive with `@CodeGen()` for each library that you want to activate code generation for.
A new `.g.dart` file will be generated alongside each of the annotated libraries.

```dart
@CodeGen()
library main;
```

After that, use your custom annotation in your library, or any of it's imported libraries, as you like:

```dart
@MyAnnotation()
class MyClass {
  MyClass(this.data);

  final String data;
}
```

Finally, run `pub run build_runner build` to run code generation once or `pub run build_runner watch` to automatically rebuild on each save.

> Head over to the example to view the full code

## Generating code

This package leverages the [code_builder](https://pub.dev/packages/code_builder) package to easily specify your generation outputs, 
whether it's classes, mixins, extensions or other code. 
This enables you to just care about the **semantics** of your generation output, while we take care of generating 
the correct **syntax** as well as formatting the generated code.

To define your generation outputs, modify the provided `LibraryBuilder` inside your annotations `apply()` method or a [generation hook](#generation-hooks).
The most used way is to modify the library using `output.body.add()` or `output.body.addAll()`. For a list of all supported declarations, check out
the [api reference](https://pub.dev/documentation/code_builder/latest/) of the code_builder package.

### Generation hooks

With custom annotations, you have the possibility to generate code for each annotated class. 
Besides this you might want to do other tasks during code-generation, such as add imports to your generated library.

To do this, use **generation hooks**. These are just top-level or static functions, which are passed to the `@CodeGen()` annotation:

```dart
@CodeGen(
  runBefore: [myFunction],
  runAfter: [myOtherFunction],
)
library main;
```

As the names suggest, the annotated function will the be run **before** everything else, or **after** everything else.

### When it fails

There exists a common misuse, that lead to a failure of the code generation when executing `build_runner build`.

You have to make sure that the code executed during the code generation phase can be compiled. 
Therefore it is important that the libraries that contain your annotations are syntactically correct 
and can be compiled, otherwise code generation will fail.

However it is common that your target code - the classes using your annotations - is not compilable 
until the code generation is complete, for example when you are referring to mixins or classes that are
later part of the generated code.
 
In those cases you have to place your annotations in separate files and import them from your target code. Make sure that your dart files
containing the annotations are compilable even when the target files are not, especially that they do not import any code with errors. 
The builder is then smart enough to only import the needed files with the annotations.

### Debugging

> Steps for Android Studio / IntelliJ IDEA

Since we use `build_runner` to execute our annotation code, it is not straight forward to debug our code.
To enable debugging, you need to manually add the script that `pub run build_runner build` calls to your run configurations.
This script is inside the `.dart_tool` folder at the root of your project. 
In your IDE add a new run configuration for a dart command line app with the following values:

- Dart file: <project_root>/.dart_tool/build/entrypoint/build.dart
- Program arguments: build --delete-conflicting-outputs

Now you can set breakpoints in your annotations and debug them by selecting the created run config and clicking the `Debug` button.

## Available Annotations

Currently there are two types of annotation classes available.

- **ClassAnnotation**: Extend this class to create a custom annotation for class declarations
- **EnumAnnotation**: Extend this class to create a custom annotation for enum declarations

## Mastering Annotations

With `super_annotations`, your build and runtime environment share the same codebase. This enables a few unique perks, 
that you wouldn't normally get with normal code generation.

### Annotation parameters

Since your annotations are just a normal class, you can define fields that are then used as annotation parameters.

Look at the following example:

```dart
@MyAnnotation("abc", 42)
class MyClass {}

class MyAnnotation extends ClassAnnotation {

  const MyAnnotation(this.id, this.myValue);

  final String id;
  final int myValue;

  @override
  void apply(Class target, LibraryBuilder output) {
    // read on
  }
}
```

In the `apply` method, you can now access `this.id` and `this.myValue`, which will hold the appropriate values from the actual annotation.
When you use your annotation on multiple classes, the fields will always have the correct value matching the currently analyzed class.

### Resolved Annotations

On top of annotation parameters, you can even access non-functional annotations (that are not **super annotations**) with ease:

```dart
@MyAnnotation()
class MyClass {
  @MyOtherAnnotation("important_label")
  void doSomething() {}
}

/// Just a regular annotation, nothing 'super'
class MyOtherAnnotation {
  final String label;
  const MyOtherAnnotation(this.label);
}

/// The real deal
class MyAnnotation extends ClassAnnotation {
  const MyAnnotation();

  @override
  void apply(Class target, LibraryBuilder output) {
    var element = target.methods.first;
    // use [resolvedAnnotations] on any element (e.g. method) to get the actual annotation objects
    var firstAnnotation = element.resolvedAnnotations.first;
    if (firstAnnotation is MyOtherAnnotation) {
      // do something with [firstAnnotation.label]
    }

    // use [resolvedAnnotationsOfType] when you are expecting a specific annotation
    var allMethodAnnotations = element.resolvedAnnotationsOfType<MyOtherAnnotation>();
  }
}
```

**Combine these two methods and bring your code generation game to a whole new level.**

## Examples

We prepared a few examples, that showcase different things that you can do with this package.

### Part-of strategy

Source: [part\_of_strategy](https://github.com/schultek/super_annotations/tree/main/examples/part_of_strategy)

This example demonstrates a strategy using part_of directives in order to extend existing declarations or add new ones.

### Inherit strategy

Source: [inherit\_strategy](https://github.com/schultek/super_annotations/tree/main/examples/inherit_strategy)

This example demonstrates a strategy using inheritance in order to modify existing class declarations.

### Json serialization

Source: [json\_serialization_example](https://github.com/schultek/super_annotations/tree/main/examples/json_serialization_example)

This example shows how to generate json serialization code, which is probably the most common use-case for code generation. 
It is inspired by and mimics the basic behavior of [json_serializable](https://pub.dev/packages/json_serializable)

### Data classes

Source: [data\_class_example](https://github.com/schultek/super_annotations/tree/main/examples/data_class_example)

This example shows how to generate utility methods for data classes. 
This will generate `copyWith` and `toString` methods for each annotated class.

### Sealed classes

Source: [sealed\_classes_example](https://github.com/schultek/super_annotations/tree/main/examples/sealed_classes_example)

This example shows how to generate sealed classes / union types. 
It is inspired by and mimics the basic behavior of [freezed](https://pub.dev/packages/freezed)

### Resolved annotations example

Source: [resolved\_annotations_example](https://github.com/schultek/super_annotations/tree/main/examples/resolved_annotations_example)

This example demonstrates how to use [resolved annotations](#resolved-annotations).

## How does it work?

I plan to publish a detailed article on the inner workings of this package, but here is a short rundown:

1. The package defines a builder that automatically runs on all libraries annotated with `@CodeGen()`
2. It identifies custom annotations and analyzes the annotated classes
3. It produces a new `*.runner.g.dart` file, that:
   - contains the analyzed classes using the `code_builder` syntax
   - calls the custom annotations `write` methods
   - calls additional `runBefore` or `runAfter` methods
   - builds and returns the created library code
4. It spawns the runner as a new isolate and receives the generation results via inter-process communication
5. It kills the isolate and deletes the `*.runner.g.dart` file
6. It writes the generation results to a `*.g.dart` file as the build output

### Bonus: Why super?

Custom annotations are not only *super* great, but also *super* in terms of programming. 
As you would define *super*classes with *super*constructors, this package defines structures above annotations.

Or in other words: While other code generation packages use code that generates other code, this package uses code that generates other code that generates other code.
 
So **super**.
