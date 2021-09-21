# Inherit strategy example

This strategy builds on top of the part_of strategy.
Instead generating a mixin, it will generate a new class extending the original class.

This strategy is useful if you want to modify the existing behaviour of a class.

## What it does

This example generates a simple logging wrapper, that logs each invocation of any method of the class.

## Setup

You need the following setup for this to work:

### 1. 

Do the setup from the part_of strategy

### 2.

You annotation should create a new class, extending the annotated class. 
Make sure to use your new class is the one used in your program, 
e.g. by prefixing your original class and removing this prefix in the generated class.
