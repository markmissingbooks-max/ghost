#!/data/data/com.termux/files/usr/bin/bash

echo ""
echo "======================================="
echo "     🚀 GhostStep Auto Build Script     "
echo "======================================="
echo ""

PROJECT_DIR="/sdcard/GhostStep"

# 1. Check project exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Project folder not found at: $PROJECT_DIR"
    echo "➡️  Make sure your GhostStep folder is exactly here."
    exit 1
fi

cd "$PROJECT_DIR"

# 2. Install dependencies
echo "📦 Installing required packages..."
pkg install -y openjdk-17 wget unzip git

export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/openjdk-17
export PATH=$JAVA_HOME/bin:$PATH

# 3. Make gradlew executable
if [ -f "./gradlew" ]; then
    chmod +x gradlew
else
    echo "⚠️ gradlew not found — generating one..."
    wget https://services.gradle.org/distributions/gradle-8.5-bin.zip -O gradle.zip
    unzip gradle.zip -d gradle
    rm gradle.zip
    echo "⚠️ You still need a proper gradlew wrapper for full builds."
fi

# 4. Clean + Build
echo ""
echo "🧹 Cleaning previous builds..."
./gradlew clean

echo ""
echo "🔨 Building GhostStep APK..."
./gradlew assembleDebug --no-daemon

APK_PATH="app/build/outputs/apk/debug/app-debug.apk"

# 5. Check build result
if [ -f "$APK_PATH" ]; then
    echo ""
    echo "======================================="
    echo "     ✅ BUILD SUCCESSFUL                "
    echo "======================================="
    echo "📍 APK saved at:"
    echo "$APK_PATH"
else
    echo ""
    echo "❌ Build failed — scroll up for errors."
    exit 1
fi

# 6. Ask to install
echo ""
read -p "📲 Install APK now? (y/n): " INSTALL

if [ "$INSTALL" = "y" ] || [ "$INSTALL" = "Y" ]; then
    echo "📲 Installing..."
    pm install -r "$APK_PATH" && echo "✅ Installed!"
else
    echo "👍 APK saved — install manually anytime."
fi

echo ""
echo "🎉 Done!"