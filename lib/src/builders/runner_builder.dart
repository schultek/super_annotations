import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import './code_builder_string.dart';
import '../../super_annotations.dart';
import '../core/utils.dart';
import 'imports_builder.dart';

const classAnnotationChecker = TypeChecker.fromRuntime(ClassAnnotation);
const codeGenChecker = TypeChecker.fromRuntime(CodeGen);

class RunnerBuilder {
  final BuildStep buildStep;

  final AssetId runnerId;
  RunnerBuilder(this.buildStep)
      : runnerId = buildStep.inputId.changeExtensionFull('.runner.g.dart');

  Future<void> create() async {
    Map<ClassElement, List<String>> runBuild = {};
    List<String> runBefore = [], runAfter = [];
    var imports = ImportsBuilder(buildStep.inputId)
      ..add(Uri.parse('dart:isolate'))
      ..add(Uri.parse('package:super_annotations/super_annotations.dart'));

    await for (var library in buildStep.resolver.libraries) {
      if (library.isInSdk) continue;

      var classes = library.units.expand((u) => u.classes).toList();
      var functions = library.units.expand((u) => u.functions).toList();

      for (var elem in classes) {
        for (var meta in elem.metadata) {
          if (meta.element is ConstructorElement) {
            var parent = (meta.element! as ConstructorElement).enclosingElement;
            if (classAnnotationChecker.isAssignableFrom(parent)) {
              (runBuild[elem] ??= []).add(parent.name);
              imports.add(parent.library.source.uri);
            }
          } else if (meta.element is PropertyAccessorElement) {
            var type = (meta.element! as PropertyAccessorElement).returnType;
            if (classAnnotationChecker.isAssignableFromType(type)) {
              (runBuild[elem] ??= []).add(type.element!.name!);
              imports.add(type.element!.library!.source.uri);
            }
          }
        }
      }

      for (var elem in functions) {
        for (var meta in elem.metadata) {
          if (meta.element is ConstructorElement) {
            var parent = (meta.element! as ConstructorElement).enclosingElement;
            if (codeGenChecker.isExactly(parent)) {
              if (meta.element!.name == 'runBefore') {
                runBefore.add(elem.name);
                imports.add(elem.library.source.uri);
              } else if (meta.element!.name == 'runAfter') {
                runAfter.add(elem.name);
                imports.add(elem.library.source.uri);
              }
            }
          }
        }
      }
    }

    var runnerCode = """
      ${imports.write()}
      
      void main(List<String> args, SendPort port) {
        CodeGen.currentFile = args[0];
        var library = Library((l) {
          ${runBefore.map((fn) => '$fn(l);\n').join()}
          
          ${runBuild.entries.map((e) => e.key.builder(e.value)).join('\n')}
         
          ${runAfter.map((fn) => '$fn(l);\n').join()}
        });
        port.send(library.accept(DartEmitter.scoped()).toString());
      }
    """;

    await File(runnerId.path).writeAsString(
        DartFormatter(fixes: [StyleFix.docComments]).format(runnerCode));
  }

  Future<String> execute() async {
    var dataPort = ReceivePort();

    var resultFuture = dataPort.first;

    await Isolate.spawnUri(
      runnerId.uri,
      [path.basename(buildStep.inputId.path)],
      dataPort.sendPort,
    );

    return await resultFuture as String;
  }

  Future<void> cleanup() async {
    await File(runnerId.path).delete();
  }

  Future<String> run() async {
    await create();
    var result = await execute();
    await cleanup();
    return result;
  }
}
