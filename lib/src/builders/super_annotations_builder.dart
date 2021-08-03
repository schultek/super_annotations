import 'dart:async';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';

import '../core/utils.dart';
import 'runner_builder.dart';

class SuperAnnotationsBuilder extends Builder {
  final BuilderOptions options;
  SuperAnnotationsBuilder(this.options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var output = await RunnerBuilder(buildStep).run();

    var outputId = buildStep.inputId.changeExtensionFull('.g.dart');
    await buildStep.writeAsString(outputId, DartFormatter().format(output));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.super.dart': ['.g.dart']
      };
}
