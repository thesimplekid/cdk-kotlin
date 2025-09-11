# Consumer ProGuard rules for CDK Kotlin

# Keep JNA
-keep class com.sun.jna.** { *; }
-keep class * implements com.sun.jna.** { *; }

# Keep CDK bindings
-keep class org.cashudevkit.** { *; }
-keep interface org.cashudevkit.** { *; }