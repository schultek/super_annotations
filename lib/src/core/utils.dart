import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:path/path.dart';

extension AssetExtension on AssetId {
  AssetId changeExtensionFull(String newExtension) {
    String stripExtension(String path) {
      var p = withoutExtension(path);
      return p != path ? stripExtension(p) : p;
    }

    return AssetId(package, stripExtension(path) + newExtension);
  }
}

extension ElementToNode on Element {
  AstNode? getNode() {
    var node =
        (session?.getParsedLibraryByElement2(library!) as ParsedLibraryResult?)
            ?.getElementDeclaration(this)
            ?.node;
    return node;
  }
}
