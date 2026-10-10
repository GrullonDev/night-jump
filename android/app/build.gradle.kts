import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is read from the project-root .env (git-ignored). When the
// file is absent the release build stays unsigned for local validation.
val releaseEnvFile = rootProject.file("../.env")
val releaseEnv = Properties()
if (releaseEnvFile.exists()) {
    releaseEnvFile.readLines()
        .map { it.trim() }
        .filter { it.isNotEmpty() && !it.startsWith("#") && it.contains("=") }
        .forEach { line ->
            val key = line.substringBefore("=").trim().removePrefix("export ").trim()
            val value = line.substringAfter("=").trim().removeSurrounding("\"").removeSurrounding("'")
            releaseEnv.setProperty(key, value)
        }
}

fun releaseEnvValue(key: String): String =
    releaseEnv.getProperty(key)?.takeIf { it.isNotBlank() }
        ?: throw GradleException("Missing $key in ${releaseEnvFile.path}")

val releaseSigningEnabled = releaseEnvFile.exists()
val releaseKeystoreFile: File? = if (releaseSigningEnabled) {
    // Supports ~/ (macOS home), absolute paths, or paths relative to the project root.
    val rawPath = releaseEnvValue("ANDROID_KEYSTORE_PATH")
    val expanded = if (rawPath.startsWith("~/")) System.getProperty("user.home") + rawPath.substring(1) else rawPath
    val candidate = File(expanded)
    val resolved = if (candidate.isAbsolute) candidate else rootProject.file("../$expanded")
    if (!resolved.exists()) throw GradleException("Keystore not found: ${resolved.path} (ANDROID_KEYSTORE_PATH in .env)")
    resolved
} else {
    null
}

android {
    namespace = "com.grullondev.night_jump"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    defaultConfig {

        applicationId = "com.grullondev.night_jump"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Google Play 16 KB page-size requirement (Android 15+): native
    // libraries must ship uncompressed and 16 KB-aligned. The Flutter
    // engine + NDK r27+ toolchain already produce aligned .so files;
    // this pins the modern (non-legacy) packaging that preserves it.
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    signingConfigs {
        if (releaseSigningEnabled) {
            create("release") {
                storeFile = releaseKeystoreFile
                storePassword = releaseEnvValue("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = releaseEnvValue("ANDROID_KEY_ALIAS")
                keyPassword = releaseEnvValue("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {

            // Without .env this is an unsigned validation build.
            signingConfig = if (releaseSigningEnabled) signingConfigs.getByName("release") else null
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21
    }
}

flutter {
    source = "../.."
}
