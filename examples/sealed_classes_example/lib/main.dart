import 'models/freezed.super.dart';

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
