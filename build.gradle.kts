plugins {
    id("com.android.library") version "8.6.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.10" apply false
    id("org.jetbrains.dokka") version "1.9.20"
    id("io.github.gradle-nexus.publish-plugin") version "2.0.0"
}

nexusPublishing {
    repositories {
        sonatype {
            // Portal's OSSRH Staging API compatibility layer
            nexusUrl.set(uri("https://ossrh-staging-api.central.sonatype.com/service/local/"))
            // Snapshots go directly to Central Portal's snapshots repo
            snapshotRepositoryUrl.set(uri("https://central.sonatype.com/repository/maven-snapshots/"))
            stagingProfileId.set("b1ae6041-fc54-4b54-943b-545b02837ba6")
            username.set(project.findProperty("sonatypeUsername") as String? ?: "")
            password.set(project.findProperty("sonatypePassword") as String? ?: "")
        }
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}