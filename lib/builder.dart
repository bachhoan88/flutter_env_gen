import 'package:build/build.dart';
import 'src/builder/env_generator_builder.dart';

/// Factory function for the builder
Builder envGeneratorBuilder(BuilderOptions options) => EnvGeneratorBuilder(options);