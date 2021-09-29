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

    var targets = codeGenAnnotation
        .getField('targets')
        ?.toListValue()
        ?.map((o) => o.toStringValue())
        .whereType<String>();
    if (targets == null || targets.isEmpty) {
      targets = ['g'];
    }

    for (var target in targets) {
      var outputId = buildStep.inputId.changeExtension('.$target.dart');
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
  Map<String, List<String>> get buildExtensions => {
        '.dart': [
          '.g.dart',
          '.super.dart',
          '.client.dart',
          '.server.dart',
          '.freezed.dart',
          '.json.dart',
          '.data.dart',
          '.mapper.dart',
          '.gen.dart',
          '.def.dart',
          '.types.dart',
          '.api.dart',
          '.schema.dart',
          '.db.dart',
          '.query.dart',
          '.part.dart',
          '.meta.dart',
          if (options.config['targets'] is List)
            ...options.config['targets'].map((t) => '.$t.dart')
        ]
      };
}
