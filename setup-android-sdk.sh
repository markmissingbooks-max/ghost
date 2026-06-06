#!/data/data/com.termux/files/usr/bin/bash

echo "🔍 Checking GhostStep project structure..."
echo

ROOT="."
APP="$ROOT/app/src/main"
JAVA="$APP/java/com/example/ghoststep"
RES="$APP/res/values"

check() {
    if [ -e "$1" ]; then
        echo "✔️  Found: $1"
    else
        echo "❌ Missing: $1"
    fi
}

echo "📁 Checking root files..."
check "$ROOT/settings.gradle.kts"
check "$ROOT/build.gradle.kts"
check "$ROOT/gradle.properties"
check "$ROOT/build.sh"
check "$ROOT/setup-android-sdk.sh"

echo
echo "📁 Checking app module..."
check "$ROOT/app/build.gradle.kts"
check "$ROOT/app/proguard-rules.pro"

echo
echo "📁 Checking manifest..."
check "$APP/AndroidManifest.xml"

echo
echo "📁 Checking Kotlin source files..."
check "$JAVA/FakeStepsApp.kt"
check "$JAVA/MainActivity.kt"
check "$JAVA/MainViewModel.kt"
check "$JAVA/PermissionsRationaleActivity.kt"

check "$JAVA/health/HealthConnectManager.kt"
check "$JAVA/config/StepConfig.kt"
check "$JAVA/config/SettingsRepository.kt"
check "$JAVA/plan/StepPlanner.kt"

check "$JAVA/schedule/StepAlarmScheduler.kt"
check "$JAVA/schedule/AlarmReceiver.kt"
check "$JAVA/schedule/BootReceiver.kt"

check "$JAVA/work/StepsWorker.kt"

check "$JAVA/ui/Common.kt"
check "$JAVA/ui/HomeScreen.kt"
check "$JAVA/ui/SettingsScreen.kt"

echo
echo "📁 Checking resources..."
check "$RES/strings.xml"
check "$RES/themes.xml"
check "$RES/colors.xml"

echo
echo "✅ Structure check complete."
echo "If any ❌ appear, fix those paths before compiling."