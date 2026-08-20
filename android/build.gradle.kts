buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.13.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.10")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    plugins.withId("com.android.library") {
        val android = extensions.findByName("android")
        if (android is com.android.build.gradle.LibraryExtension) {
            android.compileSdk = 36
        }
    }
    plugins.withId("com.android.application") {
        val android = extensions.findByName("android")
        if (android is com.android.build.gradle.AppExtension) {
            android.compileSdk = 36
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
