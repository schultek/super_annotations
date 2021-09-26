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

    var targets = getTargets(codeGenAnnotation);

    for (var target in targets) {
      var output = await RunnerBuilder(
        buildStep,
        target,
        codeGenAnnotation,
        options.config,
      ).run();

      var outputId = buildStep.inputId.changeExtension('.$target.dart');
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
      '.dart': [
        '.g.dart',
        ...options.config['targets']?.map((t) => '.$t.dart') ?? []
      ]
    };
  }

  List<String> getTargets(DartObject annotation) {
    var targets = annotation
            .getField('targets')
            ?.toListValue()
            ?.map((o) => o.toStringValue())
            .whereType<String>()
            .toList() ??
        [];
    if (targets.isEmpty) {
      targets.add('g');
    }
    return targets;
  }
}
