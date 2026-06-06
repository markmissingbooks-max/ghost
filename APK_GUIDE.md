# 📱 GhostStep - APK Build & Download Guide

## Quick Start (Dummy's Guide)

### Option 1: Build & Download (Easiest) 🎯

#### Step 1: Push Code to GitHub
```bash
cd your-project-folder
git add .
git commit -m "Build APK"
git push origin reorganize-project-structure
```


#### Step 2: Wait for Build to Complete
- Go to: `https://github.com/markmissingbooks-max/ghost`
- Click the **Actions** tab (top of page)
- You'll see a workflow running
- Wait for the checkmark ✅ (5-10 minutes)

#### Step 3: Download Your APK
1. Click on the latest workflow run
2. Scroll down to **Artifacts** section
3. Download **GhostStep-Debug** (the file)
4. That's your APK! 🎉

---

### Option 2: Build Locally on Your Computer 💻

#### Requirements
- [Java 17 or higher](https://www.oracle.com/java/technologies/downloads/)
- [Android Studio](https://developer.android.com/studio) (optional, but helpful)

#### Steps

**Step 1: Clone the Repository**
```bash
git clone https://github.com/markmissingbooks-max/ghost.git
cd ghost
```

**Step 2: Build the APK**
```bash
./gradlew assembleDebug
```
Wait 2-5 minutes for it to finish.

**Step 3: Find Your APK**
The APK will be at:
```
app/build/outputs/apk/debug/app-debug.apk
```

Copy this file to your phone to install it.

---

## 📲 Installing the APK on Your Phone

### Android Phone

**Step 1: Enable Unknown Sources**
- Settings → Security → Unknown Sources → Turn ON
- (This location varies by phone model)

**Step 2: Transfer APK to Phone**
- Connect phone to computer via USB cable
- Drag & drop `app-debug.apk` to phone storage
- OR use Bluetooth to send the file

**Step 3: Install**
- On your phone, open File Manager
- Find `app-debug.apk`
- Tap it → Install
- Done! 🎉

---

## 🏗️ Project Structure

```
ghost/
├── app/
│   ├── src/main/
│   │   ├── AndroidManifest.xml
│   │   ├── java/com/example/ghoststep/
│   │   │   ├── MainActivity.kt
│   │   │   ├── config/
│   │   │   ├── health/
│   │   │   ├── schedule/
│   │   │   ├── ui/
│   │   │   ├── work/
│   │   │   └── plan/
│   │   └── res/
│   ├── build.gradle.kts
│   └── proguard-rules.pro
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
├── gradlew (build tool - use this!)
└── BUILD_AND_RELEASE.md (detailed guide)
```

---

## 🔧 Troubleshooting

### Build Fails Locally

**Problem:** `./gradlew: command not found`
```bash
chmod +x gradlew  # Make it executable
./gradlew assembleDebug
```

**Problem:** `Java version error`
- Install Java 17: https://www.oracle.com/java/technologies/downloads/
- Verify: `java -version`

**Problem:** `Out of memory error`
- Edit `gradle.properties`
- Change `org.gradle.jvmargs=-Xmx4096m` to `-Xmx2048m`

---

### APK Won't Install

**Problem:** "App not installed"
- Ensure Android version is 8.0+ (API 26+)
- Check Unknown Sources is enabled
- Try uninstalling old version first

**Problem:** "Unknown sources disabled"
- Go to Settings → Security
- Enable "Unknown Sources" or "Install from Unknown Sources"
- Try again

---

## 📊 APK Types Explained

| Type | Use Case | Size | Signing |
|------|----------|------|---------|
| **Debug APK** | Testing, development | Smaller | Auto-signed |
| **Release APK** | Distribution, Play Store | Larger (compressed) | Custom signed |

For testing, use **Debug APK** ✅

---

## 🌐 GitHub Actions Workflow (Auto Build)

When you push code, GitHub automatically:
1. ✅ Checks out your code
2. ✅ Downloads Java 17
3. ✅ Runs `./gradlew assembleDebug`
4. ✅ Uploads APK as artifact
5. ✅ Keeps it for 30 days

**No setup needed!** Just push and download.

---

## 📝 What Each File Does

| File | Purpose |
|------|---------|
| `app/build.gradle.kts` | Build configuration, dependencies |
| `gradle.properties` | Build optimization settings |
| `app/proguard-rules.pro` | Code obfuscation (release only) |
| `build.sh` | Local build script (optional) |
| `AndroidManifest.xml` | App permissions & components |

---

## 🚀 Next Steps

1. **Push the code:**
   ```bash
   git push origin reorganize-project-structure
   ```

2. **Watch the build:**
   - Go to Actions tab
   - Wait for workflow to finish

3. **Download & install:**
   - Get the APK
   - Install on phone
   - Test the app!

---

## 📞 Need Help?

### Common Questions

**Q: Where's my APK?**
A: Actions tab → Latest run → Artifacts section

**Q: How long does it take?**
A: 5-10 minutes for GitHub, 2-5 minutes locally

**Q: Can I share the APK?**
A: Yes! Send `app-debug.apk` to anyone with Android

**Q: How do I update the APK?**
A: Push new code → GitHub builds new APK → Download again

---

## 📚 Full Documentation

For advanced options, see: `BUILD_AND_RELEASE.md`

---

**Happy building! 🎉**
