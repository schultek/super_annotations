part of 'main.dart';

class MyClass extends $MyClass {
  final List<String> _logs = [];

  @override
  void hello(String name) {
    _logs.add('Method invoked: hello($name)');
    return super.hello(name);
  }

  void logs() {
    print(_logs.join('\n'));
  }
}
