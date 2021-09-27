import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';

import 'runner_builder.dart';

class SuperAnnotationsBuilder extends Builder {
  final BuilderOptions options;
  SuperAnnotationsBuilder(this.options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var codeGenAnnotation =
        await getCodeGenAnnotation(buildStep).catchError((_) => null);

    if (codeGenAnnotation == null) {
      return;
    }

    for (var outputId in buildStep.allowedOutputs) {
      var target = outputId.path.split('.').reversed.skip(1).first;
      var output = await RunnerBuilder(
              buildStep, target, codeGenAnnotation, options.config)
          .run();

      await buildStep.writeAsString(outputId, DartFormatter().format(output));
    }
  }

  Future<DartObject?> getCodeGenAnnotation(BuildStep buildStep) async {
    var library = await buildStep.inputLibrary;
    return codeGenChecker.firstAnnotationOf(library);
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.dart': (options.config['targets'] as List?)
              ?.map((t) => '.$t.dart')
              .toList() ??
          ['.g.dart']
    };
  }
}
