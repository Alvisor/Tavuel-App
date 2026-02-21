# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Prevent stripping of R8-safe classes used via reflection
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
