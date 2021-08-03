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
