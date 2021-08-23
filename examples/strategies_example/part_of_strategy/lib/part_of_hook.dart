import 'package:super_annotations/super_annotations.dart';

@CodeGen.runAfter()
void addPartOfDirective(LibraryBuilder library) {
  library.directives.add(Directive.partOf(CodeGen.currentFile));
}
