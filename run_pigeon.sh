flutter pub run pigeon \
  --input pigeons/api.dart \
  --dart_out lib/api.dart \
  --objc_header_out ios/Classes/api.h \
  --objc_source_out ios/Classes/api.m \
  --objc_prefix FLT \
  --java_out ./android/src/main/java/io/flutter/plugins/Pigeon.java \
  --java_package "io.flutter.plugins"