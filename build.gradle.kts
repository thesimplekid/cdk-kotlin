plugins {
    id("com.android.library") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.10" apply false
    id("org.jetbrains.dokka") version "1.9.20"
}

tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}