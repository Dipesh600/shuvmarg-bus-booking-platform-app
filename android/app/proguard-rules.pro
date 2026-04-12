# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Google Play Services classes
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# Keep JSON parsing classes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep model classes
-keep class com.shuvmarg.app.models.** { *; }

# OkHttp - Ignore missing SSL providers
-dontwarn org.bouncycastle.jsse.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.javax.net.ssl.**
-dontwarn org.openjsse.net.ssl.**

# Play Core Library - deferred components
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.tasks.**
-keep class com.google.android.play.core.** { *; }

# Keep OkHttp
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep Retrofit/Dio related classes
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Keep eSewa PNP classes
-keep class np.com.uashim.esewa_pnp.** { *; }
-dontwarn np.com.uashim.esewa_pnp.**

# Keep Flutter plugins
-keep class com.dexterous.** { *; }
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }

# Keep Lottie
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

# General
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.view.View

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keep class * implements java.io.Serializable { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}
