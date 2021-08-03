import 'package:build/build.dart';

import 'src/builders/super_annotations_builder.dart';

/// Entry point for the builder
SuperAnnotationsBuilder buildSuperGeneration(BuilderOptions options) =>
    SuperAnnotationsBuilder(options);
