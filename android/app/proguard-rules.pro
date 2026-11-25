# FFmpegKit (reveal video export) is called from native code via JNI.
-keep class com.antonkarpenko.ffmpegkit.** { *; }

# Flutter's deferred-components support references Play Core classes that
# this app doesn't ship; nothing calls them at runtime.
-dontwarn com.google.android.play.core.**

# Keep line numbers for readable Crashlytics stack traces.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
