// android/build.gradle.kts (root)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ВАЖЛИВО: Kotlin DSL синтаксис
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}