#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "======================================="
echo "   🚀 GhostStep Full SuperScript        "
echo "======================================="
echo ""

ROOT="/sdcard/GhostStep"

echo "📁 Resetting project directory at $ROOT..."
rm -rf "$ROOT"
mkdir -p "$ROOT"
cd "$ROOT" || exit 1

echo "📦 Installing dependencies (OpenJDK, wget, unzip, git)..."
pkg install -y openjdk-17 wget unzip git

export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/openjdk-17
export PATH=$JAVA_HOME/bin:$PATH

echo "📥 Downloading Gradle 8.5..."
wget -q https://services.gradle.org/distributions/gradle-8.5-bin.zip -O gradle.zip
unzip -q gradle.zip -d gradle
rm gradle.zip

echo "⚙️ Creating Gradle wrapper..."
mkdir -p gradle/wrapper
cat > gradle/wrapper/gradle-wrapper.properties <<EOF
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-bin.zip
EOF

cat > gradlew <<'EOF'
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$DIR/gradle/bin/gradle" "$@"
EOF
chmod +x gradlew

echo "📁 Creating project structure..."
mkdir -p app/src/main/java/com/example/ghoststep/ui
mkdir -p app/src/main/java/com/example/ghoststep/health
mkdir -p app/src/main/java/com/example/ghoststep/config
mkdir -p app/src/main/java/com/example/ghoststep/plan
mkdir -p app/src/main/java/com/example/ghoststep/schedule
mkdir -p app/src/main/java/com/example/ghoststep/work
mkdir -p app/src/main/res/values

echo "📝 Writing Gradle files..."

cat > settings.gradle.kts <<EOF
rootProject.name = "GhostStep"
include(":app")
EOF

cat > build.gradle.kts <<EOF
plugins {
    id("com.android.application") version "8.5.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.23" apply false
}
EOF

cat > gradle.properties <<EOF
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
EOF

cat > app/build.gradle.kts <<EOF
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.ghoststep"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.ghoststep"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.11"
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.activity:activity-compose:1.9.0")
    implementation("androidx.compose.ui:ui:1.6.7")
    implementation("androidx.compose.ui:ui-tooling-preview:1.6.7")
    implementation("androidx.compose.material3:material3:1.3.0")

    implementation("androidx.datastore:datastore-preferences:1.1.1")
    implementation("androidx.work:work-runtime-ktx:2.9.0")

    debugImplementation("androidx.compose.ui:ui-tooling:1.6.7")
}
EOF

echo "📝 Writing AndroidManifest..."
cat > app/src/main/AndroidManifest.xml <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:name=".FakeStepsApp"
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher"
        android:theme="@style/Theme.GhostStep">

        <activity android:name=".PermissionsRationaleActivity" />

        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <receiver android:name=".schedule.AlarmReceiver" />
        <receiver android:name=".schedule.BootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>

    </application>

</manifest>
EOF

echo "📝 Writing Kotlin sources..."

# FakeStepsApp
cat > app/src/main/java/com/example/ghoststep/FakeStepsApp.kt <<EOF
package com.example.ghoststep

import android.app.Application
import androidx.work.Configuration

class FakeStepsApp : Application(), Configuration.Provider {
    override fun getWorkManagerConfiguration(): Configuration =
        Configuration.Builder().build()
}
EOF

# StepConfig
cat > app/src/main/java/com/example/ghoststep/config/StepConfig.kt <<EOF
package com.example.ghoststep.config

data class StepConfig(
    val averageStepsPerDay: Int = 8000,
    val weekendAverageSteps: Int = 5000,
    val variancePercent: Int = 20,
    val activeStartHour: Int = 7,
    val activeEndHour: Int = 22,
    val burstsPerDay: Int = 12,
    val autoEnabled: Boolean = false
)
EOF

# SettingsRepository
cat > app/src/main/java/com/example/ghoststep/config/SettingsRepository.kt <<EOF
package com.example.ghoststep.config

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore("ghost_step_config")

class SettingsRepository(private val context: Context) {

    private object Keys {
        val AVG = intPreferencesKey("average_steps")
        val WEEKEND = intPreferencesKey("weekend_steps")
        val VARIANCE = intPreferencesKey("variance_percent")
        val START = intPreferencesKey("active_start")
        val END = intPreferencesKey("active_end")
        val BURSTS = intPreferencesKey("bursts_per_day")
        val AUTO = booleanPreferencesKey("auto_enabled")
    }

    val configFlow: Flow<StepConfig> =
        context.dataStore.data.map { prefs -> prefs.toConfig() }

    suspend fun update(config: StepConfig) {
        context.dataStore.edit { prefs ->
            prefs[Keys.AVG] = config.averageStepsPerDay
            prefs[Keys.WEEKEND] = config.weekendAverageSteps
            prefs[Keys.VARIANCE] = config.variancePercent
            prefs[Keys.START] = config.activeStartHour
            prefs[Keys.END] = config.activeEndHour
            prefs[Keys.BURSTS] = config.burstsPerDay
            prefs[Keys.AUTO] = config.autoEnabled
        }
    }

    private fun Preferences.toConfig(): StepConfig =
        StepConfig(
            averageStepsPerDay = this[Keys.AVG] ?: 8000,
            weekendAverageSteps = this[Keys.WEEKEND] ?: 5000,
            variancePercent = this[Keys.VARIANCE] ?: 20,
            activeStartHour = this[Keys.START] ?: 7,
            activeEndHour = this[Keys.END] ?: 22,
            burstsPerDay = this[Keys.BURSTS] ?: 12,
            autoEnabled = this[Keys.AUTO] ?: false
        )
}
EOF

# StepPlanner
cat > app/src/main/java/com/example/ghoststep/plan/StepPlanner.kt <<EOF
package com.example.ghoststep.plan

import com.example.ghoststep.config.StepConfig
import kotlin.random.Random

data class StepBurst(
    val hour: Int,
    val minute: Int,
    val steps: Int
)

class StepPlanner {

    fun planDay(config: StepConfig, isWeekend: Boolean): List<StepBurst> {
        val avg = if (isWeekend) config.weekendAverageSteps else config.averageStepsPerDay
        val variance = config.variancePercent / 100.0
        val minTotal = (avg * (1 - variance)).toInt()
        val maxTotal = (avg * (1 + variance)).toInt()
        val total = Random.nextInt(minTotal, maxTotal + 1)

        val bursts = mutableListOf<StepBurst>()
        var remaining = total

        repeat(config.burstsPerDay) { i ->
            val share = remaining / (config.burstsPerDay - i).coerceAtLeast(1)
            val steps = (share * Random.nextDouble(0.5, 1.5)).toInt().coerceAtLeast(10)
            remaining -= steps

            val hour = Random.nextInt(config.activeStartHour, config.activeEndHour)
            val minute = Random.nextInt(0, 60)

            bursts += StepBurst(hour, minute, steps)
        }

        return bursts
    }
}
EOF

# HealthConnectManager (stub)
cat > app/src/main/java/com/example/ghoststep/health/HealthConnectManager.kt <<EOF
package com.example.ghoststep.health

import android.content.Context
import android.util.Log

class HealthConnectManager(private val context: Context) {
    fun writeFakeSteps(totalSteps: Int) {
        Log.i("HealthConnectManager", "Pretend writing \$totalSteps steps to Health Connect")
    }
}
EOF

# StepsWorker
cat > app/src/main/java/com/example/ghoststep/work/StepsWorker.kt <<EOF
package com.example.ghoststep.work

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.ghoststep.config.StepConfig
import com.example.ghoststep.health.HealthConnectManager
import com.example.ghoststep.plan.StepPlanner
import kotlinx.coroutines.delay

class StepsWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        val config = StepConfig()
        val planner = StepPlanner()
        val bursts = planner.planDay(config, isWeekend = false)
        val total = bursts.sumOf { it.steps }

        val manager = HealthConnectManager(applicationContext)
        manager.writeFakeSteps(total)

        delay(300)
        return Result.success()
    }
}
EOF

# StepAlarmScheduler
cat > app/src/main/java/com/example/ghoststep/schedule/StepAlarmScheduler.kt <<EOF
package com.example.ghoststep.schedule

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

class StepAlarmScheduler(private val context: Context) {

    fun scheduleDaily(hour: Int, minute: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java)
        val pending = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val now = System.currentTimeMillis()
        val triggerAt = now + 60 * 60 * 1000 // simple: 1 hour from now

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pending)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAt, pending)
        }
    }
}
EOF

# AlarmReceiver
cat > app/src/main/java/com/example/ghoststep/schedule/AlarmReceiver.kt <<EOF
package com.example.ghoststep.schedule

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.example.ghoststep.work.StepsWorker

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val request = OneTimeWorkRequestBuilder<StepsWorker>().build()
        WorkManager.getInstance(context).enqueue(request)
    }
}
EOF

# BootReceiver
cat > app/src/main/java/com/example/ghoststep/schedule/BootReceiver.kt <<EOF
package com.example.ghoststep.schedule

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val scheduler = StepAlarmScheduler(context)
        scheduler.scheduleDaily(hour = 9, minute = 0)
    }
}
EOF

# MainViewModel
cat > app/src/main/java/com/example/ghoststep/MainViewModel.kt <<EOF
package com.example.ghoststep

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.example.ghoststep.config.SettingsRepository
import com.example.ghoststep.config.StepConfig
import com.example.ghoststep.work.StepsWorker
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

data class UiState(
    val config: StepConfig = StepConfig(),
    val autoEnabled: Boolean = false
)

class MainViewModel(app: Application) : AndroidViewModel(app) {

    private val repo = SettingsRepository(app)
    private val workManager = WorkManager.getInstance(app)

    private val _uiState = MutableStateFlow(UiState())
    val uiState: StateFlow<UiState> = _uiState

    init {
        viewModelScope.launch {
            repo.configFlow.collect { cfg ->
                _uiState.value = _uiState.value.copy(config = cfg)
            }
        }
    }

    fun toggleAuto(enabled: Boolean) {
        _uiState.value = _uiState.value.copy(autoEnabled = enabled)
    }

    fun writeNow() {
        val request = OneTimeWorkRequestBuilder<StepsWorker>().build()
        workManager.enqueue(request)
    }
}
EOF

# MainActivity
cat > app/src/main/java/com/example/ghoststep/MainActivity.kt <<EOF
package com.example.ghoststep

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import com.example.ghoststep.ui.HomeScreen

class MainActivity : ComponentActivity() {

    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface {
                    HomeScreen(
                        state = viewModel.uiState,
                        onWriteNow = viewModel::writeNow
                    )
                }
            }
        }
    }
}
EOF

# PermissionsRationaleActivity
cat > app/src/main/java/com/example/ghoststep/PermissionsRationaleActivity.kt <<EOF
package com.example.ghoststep

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text

class PermissionsRationaleActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface {
                    Text("GhostStep writes fake step data locally on your device.")
                }
            }
        }
    }
}
EOF

# UI Common
cat > app/src/main/java/com/example/ghoststep/ui/Common.kt <<EOF
package com.example.ghoststep.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun SectionCard(title: String, content: @Composable () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Text(text = title, style = MaterialTheme.typography.titleMedium)
            content()
        }
    }
}

@Composable
fun SliderSetting(
    label: String,
    value: Float,
    range: ClosedFloatingPointRange<Float>,
    onValueChange: (Float) -> Unit
) {
    Column(modifier = Modifier.padding(top = 8.dp)) {
        Text("\$label: \${value.toInt()}")
        Slider(
            value = value,
            onValueChange = onValueChange,
            valueRange = range
        )
    }
}

@Composable
fun ToggleSetting(
    label: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Column(modifier = Modifier.padding(top = 8.dp)) {
        Text(label)
        Switch(checked = checked, onCheckedChange = onCheckedChange)
    }
}
EOF

# HomeScreen
cat > app/src/main/java/com/example/ghoststep/ui/HomeScreen.kt <<EOF
package com.example.ghoststep.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.ghoststep.UiState
import kotlinx.coroutines.flow.StateFlow

@Composable
fun HomeScreen(
    state: StateFlow<UiState>,
    onWriteNow: () -> Unit
) {
    val ui = state.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("GhostStep", modifier = Modifier.padding(bottom = 8.dp))
        Text("Average steps per day: \${ui.value.config.averageStepsPerDay}")
        Text("Bursts per day: \${ui.value.config.burstsPerDay}")

        Button(
            modifier = Modifier.padding(top = 16.dp),
            onClick = onWriteNow
        ) {
            Text("Write fake steps now")
        }
    }
}
EOF

# SettingsScreen (not wired yet, but present)
cat > app/src/main/java/com/example/ghoststep/ui/SettingsScreen.kt <<EOF
package com.example.ghoststep.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.ghoststep.config.StepConfig

@Composable
fun SettingsScreen(
    config: StepConfig,
    onConfigChange: (StepConfig) -> Unit,
    onClose: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("Settings")

        SliderSetting(
            label = "Average steps",
            value = config.averageStepsPerDay.toFloat(),
            range = 1000f..30000f
        ) { new ->
            onConfigChange(config.copy(averageStepsPerDay = new.toInt()))
        }

        SliderSetting(
            label = "Bursts per day",
            value = config.burstsPerDay.toFloat(),
            range = 4f..40f
        ) { new ->
            onConfigChange(config.copy(burstsPerDay = new.toInt()))
        }

        ToggleSetting(
            label = "Auto generate daily",
            checked = config.autoEnabled,
            onCheckedChange = { checked ->
                onConfigChange(config.copy(autoEnabled = checked))
            }
        )

        Button(
            modifier = Modifier.padding(top = 16.dp),
            onClick = onClose
        ) {
            Text("Close")
        }
    }
}
EOF

echo "📝 Writing resources..."

cat > app/src/main/res/values/strings.xml <<EOF
<resources>
    <string name="app_name">GhostStep</string>
</resources>
EOF

cat > app/src/main/res/values/themes.xml <<EOF
<resources>
    <style name="Theme.GhostStep" parent="Theme.Material3.DayNight.NoActionBar" />
</resources>
EOF

cat > app/src/main/res/values/colors.xml <<EOF
<resources>
    <color name="purple_500">#6200EE</color>
</resources>
EOF

echo ""
echo "🔨 Building APK..."
./gradlew assembleDebug --no-daemon

APK="app/build/outputs/apk/debug/app-debug.apk"

if [ -f "$APK" ]; then
    echo "✅ Build complete!"
    echo "📍 APK: $APK"
    echo "📲 Installing..."
    pm install -r "$APK" && echo "🎉 Installed!"
else
    echo "❌ Build failed. Check Gradle output above."
    exit 1
fi

echo ""
echo "🎉 GhostStep is built and installed."