import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val isReleaseTask =
    gradle.startParameter.taskNames.any { taskName ->
        taskName.contains("release", ignoreCase = true)
    }

val requiredKeystoreKeys = listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
val hasReleaseSigning =
    keystorePropertiesFile.exists() &&
        requiredKeystoreKeys.all { key -> !keystoreProperties.getProperty(key).isNullOrBlank() }

if (isReleaseTask && !hasReleaseSigning) {
    throw GradleException(
        """
        Release signing is not configured.

        Create android/key.properties (or key.properties in the project root) with:
          storeFile=/absolute/path/to/your.jks
          storePassword=...
          keyAlias=...
          keyPassword=...

        Then re-run: flutter build apk --release
        """.trimIndent(),
    )
}

android {
    namespace = "com.mafioso.game"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.mafioso.game"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = 3
        versionName = "1.0.2"
        multiDexEnabled = true
    }

    if (hasReleaseSigning) {
        signingConfigs {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")!!
                keyPassword = keystoreProperties.getProperty("keyPassword")!!
                storeFile = file(keystoreProperties.getProperty("storeFile")!!)
                storePassword = keystoreProperties.getProperty("storePassword")!!
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
