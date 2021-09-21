# Super Annotations

Hassle free metaprogramming as you dream it. Use code generation and custom annotations with ease.

- Write your code generation functions naturally alongside your normal code.
- Define and use custom annotations in the same file or project.

For the first time, this makes code generation applicable for all kinds of projects. 
No complex setup, no experience in writing builders needed.

## Outline

- [Get Started](#get-started)
- [Generating code](#generating-code)
  - [Generation hooks](#generation-hooks)
  - [When it fails](#when-it-fails)
- [Mastering Annotations](#mastering-annotations)
  - [Annotation parameters](#annotation-parameters)
  - [Resolved annotations](#resolved-annotations)
- [Examples](#examples)
  - [Json serialization](#json-serialization)
  - [Sealed classes](#sealed-classes)
  - [Data classes](#data-classes)
- [How does it work?](#how-does-it-work)
  - [Bonus: Why super?](#bonus-why-super)

> This package is still in active development. If you have any feedback or feature requests, write me and issue on github.

## Get Started

First, add `super_annotations` as a dependency, and `build_runner` as a dev_dependency.

```shell script
flutter pub add super_annotations
flutter pub add build_runner --dev
```

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
  /// @param library: The library that will be generated as output of the build phase
  @override
  void apply(Class target, LibraryBuilder library) {
    // Your custom implementation here
  }
}
```

The `target` parameter will hold all the information about the annotated class, and the 
`library` parameter can be used to produce your code generation output in a formal way.

Access information about the class using `target.name`, `target.fields` and so on. 
Add code to the generation output using: `library.body.add(...)`. 
You can add declarations like `Class(...)`, `Extension(...)`, `Mixin(...)` etc, or use raw code with `Code(...)`.

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

Finally, run `flutter pub run build_runner build` to run code generation once or `flutter pub run build_runner watch` to automatically rebuild on each save.

## Generating code

This package leverages the [code_builder](https://pub.dev/packages/code_builder) package to easily specify your generation outputs, 
whether it's classes, mixins, extensions or other code. 
This enables you to just care about the **semantics** of your generation output, while we take care of generating 
the correct **syntax** as well as formatting the generated code.

To define your generation outputs, modify the provided `LibraryBuilder` inside your annotations `apply()` method or a [generation hook](#generation-hooks).
The most used way is to modify the library using `library.body.add()` or `library.body.addAll()`. For a list of all supported declarations, check out
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
  void apply(Class clazz, LibraryBuilder library) {
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
  void apply(Class clazz, LibraryBuilder library) {
    // use [resolvedAnnotations] on any element (e.g. method) to get the actual annotation objects
    var methodAnnotation = clazz.methods.first.resolvedAnnotations.first;
    if (methodAnnotation is MyOtherAnnotation) { // yes
      // do something with [methodAnnotation.label]
    }
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
