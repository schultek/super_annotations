# Super Annotations

Use code generation with custom annotations with ease.

- No complex builders
- No build.yaml
- No reflection during runtime

Write your code generation functions naturally alongside your normal code.
Define and use custom annotations in the same file or project.

For the first time, this makes code generation applicable for all kinds of projects. 
No complex setup, no experience in writing builders needed.

## Get Started

First, add `super_annotations` as a dependency, and `build_runner` as a dev_dependency.

```shell script
flutter pub add super_annotations
flutter pub add build_runner --dev
```

Next create a new file with the `.super.dart` extension. This tells `super_annotations` to run the build step on this file.
Define your custom annotation like this:

```dart
import 'package:super_annotations/super_annotations.dart';

/// Choose a name and extend [ClassAnnotation]
class MyAnnotation extends ClassAnnotation {
  /// You need a const constructor to be usable as an annotation
  const MyAnnotation();

  /// You have to implement the [apply] method, which will be
  /// executed during the build phase
  /// @param clazz: A formal description of the annotated class, e.g. its name and fields
  /// @param library: The library that will be generated as output of the build phase
  @override
  void apply(Class clazz, LibraryBuilder library) {
    // do someting with [clazz] and [library]
  }
}
```

After that, use your custom annotation as you like:

```dart
@MyAnnotation()
class MyClass {
  MyClass(this.data);

  final String data;
}
```

Finally, run `flutter pub run build_runner build`, which will generate a `.g.dart` file alongside your `.super.dart` file.

## Examples

We prepared a few examples, that showcase a few different things that you can do with this package.
Some of them mimic the basic functionality of popular code-generation libraries, such as [json_serializable](https://pub.dev/packages/json_serializable) and [freezed](https://pub.dev/packages/freezed). 

| Name | Status |
| --- | --- |
| [json\_serialization_example](https://github.com/schultek/super_annotations/tree/main/examples/json_serialization_example) | **Done** |
| [sealed\_classes_example](https://github.com/schultek/super_annotations/tree/main/examples/sealed_classes_example) | **Done** |
| [data\_class_example](https://github.com/schultek/super_annotations/tree/main/examples/data_class_example) | Todo |
| [api\_generation_example](https://github.com/schultek/super_annotations/tree/main/examples/api_generation_example) | Todo |
| [mocking\_example](https://github.com/schultek/super_annotations/tree/main/examples/mocking_example) | Todo |
| [generation\_strategies_example](https://github.com/schultek/super_annotations/tree/main/examples/generation_strategies_example) | Todo |

## How does it work?

I plan to publish a detailed article on the inner workings of this package, but here is a short rundown:

1. The package defines a builder that automatically runs on all `*.super.dart` files
2. It identifies custom annotations and analyzes the annotated classes
3. It produces a new `*.runner.g.dart` file, that:
   - contains the analyzed classes
   - calls the custom annotations `write` methods
   - calls additional `runBefore` or `runAfter` methods
4. It spawns the runner as a new isolate and receives the generation results via inter-process communication
5. It kills the isolate and deletes the `*.runner.g.dart` file
6. It writes the generation results to a `*.g.dart` file as the build output

### Bonus: Why super?

Custom annotations are not only *super* great, but also *super* in terms of programming. 
As you would define *super*classes with *super*constructors, this package defines structures above annotations.

Or in other words: While other code generation packages use code that generates other code, this package uses code that generates other code that generates other code.
 
So **super**.
