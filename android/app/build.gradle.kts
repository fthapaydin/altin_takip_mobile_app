plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.fatalsoft.altintakip.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.fatalsoft.altintakip.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
         multiDexEnabled = true
    }

     signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

  
    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
        debug {
            // Debug build type uses default debug signing
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

// APK'yı Flutter'ın beklediği konuma kopyala
afterEvaluate {
    // Tüm assemble task'larını bul ve APK kopyalama ekle
    tasks.matching { it.name.startsWith("assemble") && it.name.contains("Debug") }.configureEach {
        doLast {
            val sourceApk = file("build/outputs/flutter-apk/app-debug.apk")
            val targetDir = file("../../build/app/outputs/flutter-apk")
            if (sourceApk.exists()) {
                targetDir.mkdirs()
                copy {
                    from(sourceApk)
                    into(targetDir)
                }
                println("✓ Debug APK copied to ${targetDir.absolutePath}")
            }
        }
    }
    
    tasks.matching { it.name.startsWith("assemble") && it.name.contains("Release") }.configureEach {
        doLast {
            val sourceApk = file("build/outputs/flutter-apk/app-release.apk")
            val targetDir = file("../../build/app/outputs/flutter-apk")
            if (sourceApk.exists()) {
                targetDir.mkdirs()
                copy {
                    from(sourceApk)
                    into(targetDir)
                }
                println("✓ Release APK copied to ${targetDir.absolutePath}")
            }
        }
    }
    
    // AAB dosyalarını Flutter'ın beklediği konuma kopyala
    tasks.matching { it.name.startsWith("bundle") && it.name.contains("Release") }.configureEach {
        doLast {
            val sourceAab = file("build/outputs/bundle/release/app-release.aab")
            val targetDir = file("../../build/app/outputs/bundle/release")
            if (sourceAab.exists()) {
                targetDir.mkdirs()
                copy {
                    from(sourceAab)
                    into(targetDir)
                }
                println("✓ Release AAB copied to ${targetDir.absolutePath}")
            }
        }
    }
}
