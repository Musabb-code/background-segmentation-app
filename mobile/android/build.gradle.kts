allprojects {
    repositories {
        mavenLocal()
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
// ponytail: AGP 9 no longer puts common AndroidX on plugin compile classpath.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        dependencies.add("implementation", "androidx.core:core:1.13.1")
        dependencies.add("implementation", "androidx.lifecycle:lifecycle-common:2.7.0")
        dependencies.add("implementation", "androidx.fragment:fragment:1.7.1")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
