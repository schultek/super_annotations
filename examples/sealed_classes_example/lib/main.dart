@CodeGen(runAfter: [CodeGen.addPartOfDirective])
library main;

import 'package:super_annotations/super_annotations.dart';

import 'freezed.dart';

part 'main.g.dart';

@freezed
class Union with _$Union {
  const factory Union(int value) = Data;
  const factory Union.loading() = Loading;
  const factory Union.error([String? message]) = ErrorDetails;
}

void main() {
  var data = Union(42);
  print(data.runtimeType); // prints: Data

  var error = Union.error('Test');
  print(error.runtimeType); // prints: ErrorDetails

  handleUnion(data); // prints: Got data with value 42
  handleUnion(error); // prints: An error occurred with message Test
}

void handleUnion(Union union) {
  print(union.map(
    data: (d) => 'Got data with value ${d.value}',
    loading: (l) => 'Is loading...',
    error: (e) => 'An error occurred with message ${e.message}',
  ));
}
