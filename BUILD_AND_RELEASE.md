# Build & Release Instructions

## 🚀 Automatic APK Builds

This repository is configured with GitHub Actions to automatically build APKs on every push and pull request.

### ✅ What Gets Built

**Debug APK** - For testing and development
- Built automatically on every push
- No signing required
- Available as artifact in Actions tab
- Retention: 30 days

**Release APK** - For distribution (optional)
- Built automatically on every push
- Requires signing configuration (see below)
- Available as artifact in Actions tab
- Retention: 30 days

---

## 📥 How to Download APKs

1. Navigate to the **Actions** tab in your GitHub repository
2. Click on the latest successful workflow run
3. Scroll down to **Artifacts** section
4. Download:
   - `GhostStep-Debug` - Debug APK for testing
   - `GhostStep-Release` - Release APK (if available)

---

## 🏷️ Creating a Release with APKs

To create a GitHub Release and automatically attach APK files:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This will:
- Trigger a build workflow
- Create a GitHub Release on the tag
- Attach both APKs to the release

---

## 🔑 Release Signing (Optional)

For production releases with code signing:

### Step 1: Create a Keystore (one-time)
```bash
keytool -genkey -v -keystore ghoststep.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ghoststep
```

### Step 2: Add to GitHub Secrets
1. Go to **Settings → Secrets and variables → Actions**
2. Create these secrets:
   - `KEYSTORE_PASSWORD` - Your keystore password
   - `KEY_ALIAS` - `ghoststep` (from command above)
   - `KEY_PASSWORD` - Your key password

### Step 3: Upload Keystore
1. Add `app/keystore.jks` to `.gitignore` (never commit!)
2. Store the keystore file securely

---

## 🏗️ Local Build (Manual)

To build locally on your machine:

### Debug APK
```bash
./gradlew assembleDebug
```
Output: `app/build/outputs/apk/debug/app-debug.apk`

### Release APK
```bash
./gradlew assembleRelease
```
Output: `app/build/outputs/apk/release/app-release.apk`

---

## 📋 Build Workflow Triggers

Builds are triggered automatically when:
- ✅ Push to `main` branch
- ✅ Push to `reorganize-project-structure` branch
- ✅ Create/update a pull request to `main`
- ✅ Push a tag (v1.0.0, v2.0.0, etc.)

---

## 🔧 System Requirements

- **JDK 17+** (automatically installed by Actions)
- **Android SDK 34+** (automatically installed by Actions)
- **Gradle wrapper** (included in repo)

---

## 📦 Gradle Build Optimization

The `gradle.properties` file includes:
- JVM memory optimization
- Parallel builds enabled
- Gradle daemon enabled
- AndroidX support enabled

---

## 🛠️ Troubleshooting

### Build fails in GitHub Actions
1. Check the **Actions** tab for error messages
2. Common issues:
   - Java version mismatch (requires Java 17)
   - Missing dependencies
   - Gradle cache issues (try clearing cache)

### APK won't install on device
- Use Debug APK for testing
- Ensure device has "Unknown Sources" enabled
- Check device Android version matches minSdk (26+)

### Release build fails
- Ensure keystore file is properly configured
- Verify secrets are set correctly in GitHub
- Check that ProGuard rules don't strip essential classes

---

## 📚 Additional Resources

- [Gradle Android Documentation](https://developer.android.com/build/gradle)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)

