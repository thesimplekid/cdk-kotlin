plugins {
    id("com.android.library") version "8.6.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.10" apply false
    id("org.jetbrains.dokka") version "1.9.20"
    id("io.github.gradle-nexus.publish-plugin") version "1.3.0"
}

nexusPublishing {
    repositories {
        sonatype {
            nexusUrl.set(uri("https://s01.oss.sonatype.org/service/local/"))
            snapshotRepositoryUrl.set(uri("https://s01.oss.sonatype.org/content/repositories/snapshots/"))
            username.set(project.findProperty("sonatypeUsername") as String? ?: "")
            password.set(project.findProperty("sonatypePassword") as String? ?: "")
        }
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}