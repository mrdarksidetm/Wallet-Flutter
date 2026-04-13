import com.android.build.gradle.BaseExtension

subprojects {
    afterEvaluate {
        if ((project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library"))) {    
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                android.namespace = project.group.toString() + "." + project.name.replace("-", "_")
            }
            android.compileSdkVersion(36)
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


