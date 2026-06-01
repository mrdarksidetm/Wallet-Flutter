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
    afterEvaluate {
        val project = this
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                // Set compileSdk via reflection for maximum compatibility
                android.javaClass.getMethod("setCompileSdk", Integer::class.java).invoke(android, 36)
            } catch (e: Exception) {
                try {
                    android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType).invoke(android, 36)
                } catch (e2: Exception) {
                    // Ignore
                }
            }

            // Also ensure targetSdk is set to 36
            try {
                val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
                defaultConfig.javaClass.getMethod("setTargetSdk", Integer::class.java).invoke(defaultConfig, 36)
            } catch (e: Exception) {
                // Fallback to direct setting if reflection fails or if it's a standard extension
                try {
                    @Suppress("UNCHECKED_CAST")
                    (android as com.android.build.gradle.BaseExtension).defaultConfig.targetSdk = 36
                } catch (e2: Exception) {
                    // Ignore
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
