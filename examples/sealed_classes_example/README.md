# Sealed classes example

This example shows how to generate sealed classes. 

It is inspired by and mimics the basic behavior of [freezed](https://pub.dev/packages/freezed)

## What it does

For each template file it generates a `part of` file. 

It generates the sealed classes defined by the factory constructors of the annotated union type.
It also generates a `map()` method that handles the decision logic on the union type.