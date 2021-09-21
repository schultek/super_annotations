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
    var codeGenAnnotation = await getCodeGenAnnotation(buildStep);

    if (codeGenAnnotation == null) {
      return;
    }

    var output =
        await RunnerBuilder(buildStep, codeGenAnnotation, options.config).run();

    var outputId = buildStep.inputId.changeExtension('.g.dart');
    await buildStep.writeAsString(outputId, DartFormatter().format(output));
  }

  Future<DartObject?> getCodeGenAnnotation(BuildStep buildStep) async {
    var library = await buildStep.inputLibrary;
    return codeGenChecker.firstAnnotationOf(library);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.g.dart']
      };
}
