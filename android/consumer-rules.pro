# Consumer ProGuard rules for the FCM plugin
# These rules will be applied to any app that uses this plugin

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Tauri classes
-keep class app.tauri.** { *; }
