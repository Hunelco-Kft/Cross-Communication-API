mkdir -p android/src/main/java/com/flutter/pigeon
flutter pub run pigeon \
  --input pigeons/api.dart \
  --dart_out lib/api.dart \
  --objc_header_out ios/Classes/api.h \
  --objc_source_out ios/Classes/api.m \
  --objc_prefix FLT \
  --java_out ./android/src/main/java/com/flutter/pigeon/Pigeon.java \
  --java_package "com.flutter.pigeon"