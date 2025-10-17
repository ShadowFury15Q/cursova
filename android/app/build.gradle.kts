// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Properties
        import java.io.FileInputStream

val keystoreProps = Properties().apply {
    val f = File(rootProject.rootDir, "key.properties")
    if (f.exists()) load(FileInputStream(f))
}

android {
    namespace = "com.anms"               // свій namespace
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"         // ВАЖЛИВО: під Firebase/плагіни

    defaultConfig {
        applicationId = "com.anms"       // свій applicationId
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            // читаємо з key.properties
            val storeFilePath = keystoreProps.getProperty("storeFile") ?: ""
            if (storeFilePath.isNotEmpty()) {
                storeFile = file(storeFilePath)
                storePassword = keystoreProps.getProperty("storePassword")
                keyAlias = keystoreProps.getProperty("keyAlias")
                keyPassword = keystoreProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            // Залишимо без мінімізації щоб уникнути проблем
            isMinifyEnabled = false
            isShrinkResources = false

            // Якщо раптом продовжить нити про strip debug symbols – можна відключити:
            // ndk { debugSymbolLevel = "NONE" }
        }
        debug {
            // debug як завжди
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
        // На деяких конфігураціях допомагає зі старими девайсами/бурчанням packager’а:
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

dependencies {
    // Для multidex, якщо буде потрібно
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}