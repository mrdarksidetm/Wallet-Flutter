# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Isar database
-keep class io.isar.** { *; }
-keepnames class io.isar.** { *; }
-keep class dev.isar.** { *; }
-keepnames class dev.isar.** { *; }
-dontwarn dev.isar.**
-dontwarn io.isar.**

# Desugar and general annotations
-dontwarn **
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

