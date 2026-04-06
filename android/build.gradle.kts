import com.android.build.gradle.BaseExtension

subprojects {
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                android.namespace = project.group.toString() + "." + project.name.replace("-", "_")
            }
            android.compileSdkVersion(36)
        }

        // Fix for AGP 8.0+ where 'package' attribute in AndroidManifest.xml is deprecated
        // and causes build failures in some older libraries like isar_flutter_libs.
        project.tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
            doLast {
                val manifestFile = manifestOutputFile.get().asFile
                if (manifestFile.exists()) {
                    val content = manifestFile.readText()
                    val updatedContent = content.replace(Regex("""\s+package="[^"]+""""), "")
                    manifestFile.writeText(updatedContent)
                }
            }
        }
        project.tasks.withType<com.android.build.gradle.tasks.ProcessApplicationManifest>().configureEach {
            doLast {
                val manifestFile = mainMergedManifest.get().asFile
                if (manifestFile.exists()) {
                    val content = manifestFile.readText()
                    val updatedContent = content.replace(Regex("""\s+package="[^"]+""""), "")
                    manifestFile.writeText(updatedContent)
                }
            }
        }
    }
}
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


