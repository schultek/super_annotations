import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import '../super_annotations.dart';
import 'code_builder_string.dart';
import 'imports_builder.dart';

const classAnnotationChecker = TypeChecker.fromRuntime(ClassAnnotation);
const enumAnnotationChecker = TypeChecker.fromRuntime(EnumAnnotation);
const codeGenChecker = TypeChecker.fromRuntime(CodeGen);

class RunnerBuilder {
  final BuildStep buildStep;
  final String target;
  final DartObject annotation;
  final Map<String, dynamic> config;

  final AssetId runnerId;
  RunnerBuilder(this.buildStep, this.target, this.annotation, this.config)
      : runnerId = buildStep.inputId.changeExtension('.runner.g.dart');

  Future<void> create() async {
    Map<ClassElement, List<String>> runBuild = {};

    var imports = ImportsBuilder(buildStep.inputId)
      ..add(Uri.parse('dart:isolate'))
      ..add(Uri.parse('package:super_annotations/super_annotations.dart'));

    await for (var library in buildStep.resolver.libraries) {
      if (library.isInSdk) continue;

      var classes = library.units.expand((u) => u.classes).toList();
      var enums = library.units.expand((u) => u.enums).toList();

      for (var elem in classes) {
        for (var meta in elem.metadata) {
          if (meta.element is ConstructorElement) {
            var parent = (meta.element! as ConstructorElement).enclosingElement;
            if (classAnnotationChecker.isAssignableFrom(parent)) {
              (runBuild[elem] ??= []).add(meta.toSource().substring(1));
              imports.add(meta.element!.library!.source.uri);
            }
          } else if (meta.element is PropertyAccessorElement) {
            var type = (meta.element! as PropertyAccessorElement).returnType;
            if (classAnnotationChecker.isAssignableFromType(type)) {
              (runBuild[elem] ??= []).add(meta.toSource().substring(1));
              imports.add(meta.element!.library!.source.uri);
            }
          }
        }
      }

      for (var elem in enums) {
        for (var meta in elem.metadata) {
          if (meta.element is ConstructorElement) {
            var parent = (meta.element! as ConstructorElement).enclosingElement;
            if (enumAnnotationChecker.isAssignableFrom(parent)) {
              (runBuild[elem] ??= []).add(meta.toSource().substring(1));
              imports.add(meta.element!.library!.source.uri);
            }
          } else if (meta.element is PropertyAccessorElement) {
            var type = (meta.element! as PropertyAccessorElement).returnType;
            if (enumAnnotationChecker.isAssignableFromType(type)) {
              (runBuild[elem] ??= []).add(meta.toSource().substring(1));
              imports.add(meta.element!.library!.source.uri);
            }
          }
        }
      }
    }

    var runAfter = getHooks(annotation.getField('runAfter'), imports);
    var runBefore = getHooks(annotation.getField('runBefore'), imports);

    var runAnnotations =
        runBuild.entries.map((e) => e.key.builder(imports, e.value)).toList();

    var runnerCode = """
      ${imports.write()}
      
      void main(List<String> args, SendPort port) {
        CodeGen.currentFile = '${path.basename(buildStep.inputId.path)}';
        CodeGen.currentTarget = '${target.escaped}';
        var library = Library((l) {
          ${runBefore.map((fn) => '$fn(l);\n').join()}
          ${runAnnotations.join('\n')}
          ${runAfter.map((fn) => '$fn(l);\n').join()}
        });
        port.send(library.accept(DartEmitter.scoped(useNullSafetySyntax: true)).toString());
      }
    """;

    await File(runnerId.path).writeAsString(
        DartFormatter(fixes: [StyleFix.docComments]).format(runnerCode));
  }

  Iterable<String> getHooks(DartObject? object, ImportsBuilder imports) {
    if (object == null) return [];
    var hooks = <String>[];
    for (var o in object.toListValue() ?? <DartObject>[]) {
      var fn = o.toFunctionValue();
      if (fn != null) {
        if (fn.isStatic && fn.enclosingElement is ClassElement) {
          hooks.add('${fn.enclosingElement.name}.${fn.name}');
        } else {
          hooks.add(fn.name);
        }
        imports.add(fn.library.source.uri);
      }
    }
    return hooks;
  }

  Future<String> execute() async {
    var dataPort = ReceivePort();

    var resultFuture = dataPort.first;

    try {
      await Isolate.spawnUri(runnerId.uri, [], dataPort.sendPort);
    } on IsolateSpawnException catch (e) {
      var m = 'Unable to spawn isolate: ';
      if (e.message.startsWith(m)) {
        var message = e.message.substring(m.length);
        throw RunnerException(message);
      } else {
        rethrow;
      }
    }

    return await resultFuture as String;
  }

  Future<void> cleanup() async {
    await File(runnerId.path).delete();
  }

  Future<String> run() async {
    await create();
    var result = await execute();
    if (config['cleanup'] != false) {
      await cleanup();
    }
    return result;
  }
}

class RunnerException implements Exception {
  String message;
  RunnerException(this.message);

  @override
  String toString() {
    return 'Cannot run code generation. There probably is a error in your annotation code. See the output below for more details:\n\n$message';
  }
}
