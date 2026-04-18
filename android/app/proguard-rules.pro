# Flutter Wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Preserve image loading libraries
-keep class com.bumptech.glide.** { *; }
-keep class androidx.appcompat.** { *; }
-keep class com.google.android.material.** { *; }

# Preserve Firebase
-keep class com.google.firebase.** { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }

# Preserve image picker
-keep class com.example.imagepicker.** { *; }

# Keep all resources
-dontshrink
-keep class **.R$* {
    public static <fields>;
}

# Keep names of fields
-keepclassmembernames class * {
    public static final int *;
}

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep Manifest class
-keep class *.Manifest { *; }
