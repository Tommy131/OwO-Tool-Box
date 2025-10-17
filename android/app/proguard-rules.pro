# Flutter 通用规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# javax.annotation
-dontwarn javax.annotation.**
-keep class javax.annotation.** { *; }
-keep interface javax.annotation.** { *; }

# javax.annotation.concurrent
-dontwarn javax.annotation.concurrent.**
-keep class javax.annotation.concurrent.** { *; }

# Google Crypto Tink
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# 保留注解
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod

# 保留本地通知相关
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.** { *; }

# ===== 自动生成的规则 - Google Play Core =====
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
