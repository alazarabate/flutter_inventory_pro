import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// ------------------------------------------------------------------
// 1.  read key.properties (keystore)
// ------------------------------------------------------------------
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
println(">>> reading key.properties from: " + keystorePropertiesFile.absolutePath)
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
println(">>> loaded properties: $keystoreProperties")
println(">>> storeFile value  : " + keystoreProperties.getProperty("storeFile"))

android {
    namespace = "com.example.new_inventory"
    compileSdk = 36          // 34/35 is safer; 36 is still preview
    buildToolsVersion = "36.0.0"

    defaultConfig {
        applicationId = "com.example.new_inventory"
        minSdk = flutter.minSdkVersion          // flutter.minSdkVersion is undefined here
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    // ------------------------------------------------------------------
    // 2.  signing config  (Kotlin-DSL syntax)
    // ------------------------------------------------------------------
    signingConfigs {
        create("release") {
    storeFile = file(keystoreProperties.getProperty("storeFile")
        ?: error("storeFile missing in key.properties"))
    storePassword = keystoreProperties.getProperty("storePassword")
        ?: error("storePassword missing in key.properties")
    keyAlias = keystoreProperties.getProperty("keyAlias")
        ?: error("keyAlias missing in key.properties")
    keyPassword = keystoreProperties.getProperty("keyPassword")
        ?: error("keyPassword missing in key.properties")
}
    }

    // ------------------------------------------------------------------
    // 3.  ONE build-types block only
    // ------------------------------------------------------------------
    buildTypes {
        getByName("debug") {
        signingConfig = signingConfigs.getByName("debug")
        }
    getByName("release") {
        isMinifyEnabled = false
        isShrinkResources = false
        signingConfig = signingConfigs.getByName("release")
    }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")

    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
}
