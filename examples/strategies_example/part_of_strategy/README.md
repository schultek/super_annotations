# Part of strategy example

This strategy makes use of `part` and `part of` directives to extend the target library.
The `.super.dart` file acts as the main library and the generated `.g.dart` file acts as a part of this library.

## What it does

This example generates a simple mixin for the annotated class, providing a `hello()` method that just does `print('World')`.

## Setup

You need the following setup for this to work:

### 1. 
Add a part directive to your `.super.dart` file.

```dart
// inside: myfile.super.dart
part 'myfile.g.dart';
```

### 2. 

Place your custom annotations in separate files (not the `.super.dart` file) and import your annotations in your `.super.dart` file.

See [Splitting files]() for an explanation why this is needed.

### 3. 

When building your target library, make sure to add the `part of` statement.

You can use the `@CodeGen.runAfter()` hook and reference the current filename using `CodeGen.currentFile`.

Place this in the same file of your annotations or another file, but not the `.super.dart` file.

```
@CodeGen.runAfter()
void addPartOfDirective(LibraryBuilder library) {
  library.directives.add(
    Directive.partOf(CodeGen.currentFile)
  );
}
```

When using a separate file for your generation hook, make sure to import this inside your `.super.dart` file.

> When using linting, it might warn you about unused imports or even remove this import statement automatically. You could prevent this with a linting comment, but an easier way is to use `export` instead.

