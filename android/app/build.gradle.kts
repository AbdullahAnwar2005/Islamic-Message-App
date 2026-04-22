plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")// ✅ modern plugin id
    // The Flutter Gradle Plugin must be applied after Android & Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.alghaya.islamicmessage"

    // These come from Flutter’s plugin, keep them:
    compileSdk = flutter.compileSdkVersion

    // (Optional) keep if you installed this NDK version; otherwise remove the line
    ndkVersion = "27.0.12077973"

    // ✅ Use Java 17 with AGP 8.x / Kotlin 1.9.x
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }


    defaultConfig {
        applicationId = "com.alghaya.islamicmessage"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // (Optional) If you don’t need 32-bit, this avoids some CMake/NDK issues on Windows
        // ndk {
        //     abiFilters "arm64-v8a"
        // }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // Enable ProGuard/R8
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
