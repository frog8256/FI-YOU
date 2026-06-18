allprojects {
    repositories {
        google()
        mavenCentral()
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

fun Project.forceCompileSdk36() {
    extensions.findByName("android")?.let { extension ->
        @Suppress("DEPRECATION")
        (extension as? com.android.build.gradle.BaseExtension)?.compileSdkVersion(36)
    }
}

subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            compileSdk = 36
        }
    }
    if (state.executed) {
        forceCompileSdk36()
    } else {
        afterEvaluate {
            forceCompileSdk36()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
