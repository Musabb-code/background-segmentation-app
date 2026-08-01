plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mackhan.mackhan"
    compileSdk = flutter.compileSdkVersion
    // ponytail: skip ndkVersion until tflite_flutter is wired — auto-install of NDK
    // ~1GB stalls on slow networks (InstallFailedException). Add flutter.ndkVersion back then.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mackhan.mackhan"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // ponytail: phone is arm64 only — skip other ABIs to cut RAM during compile.
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// ponytail: was root afterEvaluate — breaks with evaluationDependsOn(":app").
dependencies {
    implementation("androidx.lifecycle:lifecycle-runtime:2.7.0")
    implementation("com.getkeepsafe.relinker:relinker:1.4.5")
}
