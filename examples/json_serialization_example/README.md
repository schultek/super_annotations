# JSON serialization example

This example shows how to generate json serialization code. 
It is inspired by and mimics the basic behavior of [json_serializable](https://pub.dev/packages/json_serializable)

## What it does

For each template file it generates a `part of` file. 
This contains `fromJson` and `toJson` methods for each annotated class.