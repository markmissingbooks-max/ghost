#!/data/data/com.termux/files/usr/bin/bash

# GhostStep Termux Build Script
# Run with: bash build.sh

echo "🔧 Setting up environment..."

export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/openjdk-17
export PATH=$JAVA_HOME/bin:$PATH

echo "📦 Cleaning previous builds..."
./gradlew clean

echo "🚀 Building GhostStep APK..."
./gradlew assembleDebug --no-daemon

APK_PATH="app/build/outputs/apk/debug/app-debug.apk"

if [ -f "$APK_PATH" ]; then
    echo "✅ Build complete!"
    echo "📍 APK located at:"
    echo "$APK_PATH"
else
    echo "❌ Build failed — check the Gradle output above."
fi