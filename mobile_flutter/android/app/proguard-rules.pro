# Flutter Secure Storage
-dontwarn com.it_nomads.fluttersecurestorage.**
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Audio plugins
-dontwarn com.ryanheise.just_audio.**
-keep class com.ryanheise.just_audio.** { *; }

-dontwarn com.github.thibault_lataillade.**
-keep class com.github.thibault_lataillade.** { *; }

# Camera
-dontwarn io.flutter.plugins.camera.**
-keep class io.flutter.plugins.camera.** { *; }

# Image picker
-dontwarn io.flutter.plugins.imagepicker.**
-keep class io.flutter.plugins.imagepicker.** { *; }

# Path provider
-dontwarn io.flutter.plugins.pathprovider.**
-keep class io.flutter.plugins.pathprovider.** { *; }

# Google Sign In
-dontwarn com.google.android.gms.auth.api.signin.**
-keep class com.google.android.gms.auth.api.signin.** { *; }

# Video player
-dontwarn com.google.android.exoplayer2.**
-keep class com.google.android.exoplayer2.** { *; }

# General Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Disable R8 full mode optimization
-keep,allowshrinking class * {
  native <methods>;
}
