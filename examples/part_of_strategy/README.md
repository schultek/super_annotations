# Part_of strategy example

This strategy makes use of `part` and `part of` directives to extend the target library.
The target file acts as the main library and the generated `.g.dart` file acts as a part of this library.

This strategy is useful if you want to add new declarations, like classes, mixins or extensions.

## What it does

This example generates a simple mixin for the annotated class, providing a `hello()` method that just does `print('World')`.

## Setup

You need the following setup for this to work:

### 1. 
Add a part directive to your target file.

```dart
// inside: main.dart
part 'main.g.dart';
```

### 2.

The generated code must include the `part of` directive. We use a custom code generation hook for this, 
and since this is a very common pattern, the package ships a predefined hook for this:

```
// inside: main.dart
@CodeGen(runAfter: [CodeGen.addPartOfDirective])
library main;
```

### 3. 

Place your custom annotations in **separate files** (not the target file) and **import** your annotations in your target file.
This is needed, since the target file will have errors while the code generation has not been run. 
However the library containing your annotations needs to be compiled.