



# ====== AGORA SDK ======
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# ====== HYPHENATE SDK ======
-keep class com.hyphenate.** { *; }

# ====== flutter_callkit_incoming ======
-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-dontwarn com.hiennv.flutter_callkit_incoming.**

# ====== Broadcast Receivers ======
-keep public class * extends android.content.BroadcastReceiver {
    <init>();
    void onReceive(android.content.Context, android.content.Intent);
}

# ====== Services ======
-keep public class * extends android.app.Service { *; }

# ====== Notification Support ======
-keep class * extends android.app.Notification { *; }

# ====== Native Methods ======
-keepclasseswithmembernames class * {
    native <methods>;
}

# ====== Reflection Support ======
-keepclassmembers class * {
    public <methods>;
}

# ====== General Attributes ======
-keepattributes Annotation
-keepattributes Signature

# ====== Debugging: Avoid Obfuscation ======
-dontobfuscate

# ====== Keep resource files (to prevent missing icons/layouts) ======
#-keepresources res/

# ====== Custom Attributes & XML ======
-keepclassmembers class * {
    @android.annotation.SuppressLint *;
}
-keepclassmembers class ** {
    public <init> (android.content.Context, android.util.AttributeSet);
}
