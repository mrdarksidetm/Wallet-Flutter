import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// THE CODEMAGIC BYPASS
// Direct injection avoids Java string escaping issues entirely.
val envStorePassword = (System.getenv("F_KEYSTORE_PASSWORD") ?: System.getenv("CM_KEYSTORE_PASSWORD"))?.trim()
if (envStorePassword != null) {
    val ksFile = file("upload-keystore.jks")
    println("Codemagic: Keystore Status -> Exists: ${ksFile.exists()}, Size: ${ksFile.length()} bytes")
    println("Codemagic: Password Check -> Length: ${envStorePassword.length}, Starts with: ${envStorePassword.take(1)}...")
    
    keystoreProperties.setProperty("storePassword", envStorePassword)
    keystoreProperties.setProperty("keyPassword", (System.getenv("F_KEY_PASSWORD") ?: System.getenv("CM_KEY_PASSWORD"))?.trim() ?: envStorePassword)
    keystoreProperties.setProperty("keyAlias", (System.getenv("F_KEY_ALIAS") ?: System.getenv("CM_KEY_ALIAS"))?.trim() ?: "upload")
    keystoreProperties.setProperty("storeFile", ksFile.absolutePath)
} else {
    println("Codemagic: Signing environment variables NOT found. Using local properties.")
}

android {
    namespace = "com.mrdarksidetm.wallet"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        jvmToolchain(21)
    }

    defaultConfig {
        applicationId = "com.mrdarksidetm.wallet"
        minSdk = 33
        targetSdk = 36
        multiDexEnabled = true
        ndk {
           abiFilters.add("armeabi-v7a")
           abiFilters.add("arm64-v8a")
        }
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.containsKey("storeFile")) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String?
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
            }
        }
    }

    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a")
            isUniversalApk = true            
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystoreProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
