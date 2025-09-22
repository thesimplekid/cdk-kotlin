plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("maven-publish")
    id("signing")
}

android {
    namespace = "org.cashudevkit"
    compileSdk = 35

    defaultConfig {
        minSdk = 24
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
        }
        animationsDisabled = true
        targetSdk = 35
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
        jniLibs {
            useLegacyPackaging = true
        }
    }

    publishing {
        singleVariant("release") {
            withSourcesJar()
            withJavadocJar()
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.10")
    implementation("net.java.dev.jna:jna:5.14.0@aar")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")

    // Unit tests (JVM)
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.jetbrains.kotlin:kotlin-test:2.1.10")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit:2.1.10")
    testImplementation("net.java.dev.jna:jna:5.14.0")

    // Android instrumentation tests - following BDK Android configuration
    androidTestImplementation("com.github.tony19:logback-android:2.0.0")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
    androidTestImplementation("org.jetbrains.kotlin:kotlin-test:2.1.10")
    androidTestImplementation("org.jetbrains.kotlin:kotlin-test-junit:2.1.10")
    androidTestImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.9.0")

    // Coroutines test support for unit tests
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.9.0")
}

afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                from(components["release"])
                
                groupId = "io.github.thesimplekid"
                artifactId = "cdk-kotlin"
                version = "0.1.0"
                
                pom {
                    name.set("cdk-kotlin")
                    description.set("Kotlin bindings for Cashu Development Kit")
                    url.set("https://github.com/thesimplekid/cdk-kotlin")
                    
                    licenses {
                        license {
                            name.set("MIT License")
                            url.set("https://opensource.org/licenses/MIT")
                        }
                    }
                    
                    developers {
                        developer {
                            id.set("thesimplekid")
                            name.set("thesimplekid")
                        }
                    }
                    
                    scm {
                        connection.set("scm:git:github.com/thesimplekid/cdk-kotlin.git")
                        developerConnection.set("scm:git:ssh://github.com/thesimplekid/cdk-kotlin.git")
                        url.set("https://github.com/thesimplekid/cdk-kotlin")
                    }
                }
            }
        }
        
        repositories {
            maven {
                name = "local"
                url = uri("${project.rootDir}/build/repo")
            }
            maven {
                name = "sonatype"
                url = uri("https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/")
                credentials {
                    username = project.findProperty("sonatypeUsername") as String? ?: ""
                    password = project.findProperty("sonatypePassword") as String? ?: ""
                }
            }
        }
    }
}

val localBuild: Boolean = project.hasProperty("localBuild")

signing {
    val signingKey: String? by project
    val signingPassword: String? by project
    useInMemoryPgpKeys(signingKey, signingPassword)
    sign(publishing.publications)
}

if (localBuild) {
    tasks.register<Exec>("buildCdkLibrary") {
        workingDir = projectDir
        // Use macOS build for local testing instead of Android
        commandLine("bash", "../scripts/build-macos-aarch64.sh")
    }

    tasks.named("preBuild") {
        dependsOn("buildCdkLibrary")
    }
}