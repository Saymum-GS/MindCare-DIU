# Firebase ProGuard rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.daffodil.mindcare_diu.** { *; }
-keep class com.Daffodil.MindCareDIU.** { *; }

# Flutter ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.plugins.** { *; }

# Shared Preferences ProGuard rules
-keep class com.russhwolf.settings.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
