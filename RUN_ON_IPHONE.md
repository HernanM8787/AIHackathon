# How to Run App on iPhone via Xcode

## Prerequisites

1. **Mac with Xcode installed** (latest version recommended)
2. **iPhone** (iOS 15.0 or later)
3. **USB cable** to connect iPhone to Mac
4. **Apple Developer Account** (free account works for development)

## Step-by-Step Instructions

### 1. Connect Your iPhone

1. Unlock your iPhone
2. Connect iPhone to Mac using USB cable
3. On iPhone, if prompted: **"Trust This Computer?"** → Tap **Trust**
4. Enter your iPhone passcode if asked

### 2. Configure Your iPhone for Development

1. On iPhone: **Settings** → **General** → **VPN & Device Management**
2. If you see your Apple ID, tap it and tap **Trust**
3. If you don't see it yet, continue to next step (will appear after first build)

### 3. Set Up Signing in Xcode

1. Open your project in Xcode:
   - Double-click `AIHackathon.xcodeproj` in Finder, OR
   - Open Xcode → File → Open → Select the project

2. Select the project in the left sidebar (top item: "AIHackathon")

3. Select the **AIHackathon** target (under "TARGETS")

4. Click the **Signing & Capabilities** tab

5. Check **"Automatically manage signing"**

6. Select your **Team**:
   - If you have a paid Apple Developer account: Select your team
   - If you have a free account: Select your personal Apple ID
   - If no team appears: Click "Add Account..." and sign in with your Apple ID

7. Xcode will automatically:
   - Generate a provisioning profile
   - Set the Bundle Identifier (should be `com.hernan.AIHackathon`)

### 4. Select Your iPhone as the Build Destination

1. At the top of Xcode, next to the Play/Stop buttons, you'll see a device selector
2. Click the device dropdown (may say "Any iOS Device" or a simulator name)
3. Select your iPhone from the list (it should appear under "iOS Device")
   - Example: "Jose's iPhone" or "iPhone 15 Pro"

### 5. Build and Run

**Option A: Using the Play Button**
1. Click the **▶️ Play button** in the top-left of Xcode (or press `Cmd + R`)
2. Xcode will:
   - Build the app
   - Install it on your iPhone
   - Launch it automatically

**Option B: Using Menu**
1. Product → Run (or `Cmd + R`)

### 6. Trust the Developer on iPhone (First Time Only)

When the app launches for the first time, you may see:

**"Untrusted Developer"** error:
1. On iPhone: **Settings** → **General** → **VPN & Device Management**
2. Tap your Apple ID/Developer name
3. Tap **Trust "[Your Name]"**
4. Tap **Trust** in the popup
5. Go back to the home screen and tap the app icon again

### 7. Verify It's Running

- The app should launch on your iPhone
- You should see your app's interface
- Xcode console will show any logs/errors

## Troubleshooting

### "No devices found" or iPhone doesn't appear

**Solutions:**
1. Make sure iPhone is unlocked
2. Disconnect and reconnect the USB cable
3. Try a different USB port/cable
4. Restart Xcode
5. On iPhone: Settings → General → Reset → Reset Location & Privacy (last resort)

### "Failed to code sign" or Signing Errors

**Solutions:**
1. In Xcode → Signing & Capabilities:
   - Uncheck "Automatically manage signing"
   - Check it again
   - Select your team again
2. Clean build folder: Product → Clean Build Folder (`Cmd + Shift + K`)
3. Delete derived data:
   - Xcode → Settings → Locations
   - Click arrow next to Derived Data path
   - Delete the folder for your project
   - Rebuild

### "Could not launch [App Name]"

**Solutions:**
1. Make sure you trusted the developer (Step 6 above)
2. Delete the app from iPhone and rebuild
3. Check iPhone storage (make sure you have space)

### "This app cannot be run because its integrity could not be verified"

**Solution:**
- This means you need to trust the developer (see Step 6)

### Build Errors

**Common fixes:**
1. **Clean Build**: Product → Clean Build Folder (`Cmd + Shift + K`)
2. **Update Dependencies**: File → Packages → Update to Latest Versions
3. **Check iOS Deployment Target**:
   - Select project → Target → General
   - Set "iOS Deployment Target" to match your iPhone's iOS version or lower

### App Crashes Immediately

1. Check Xcode console for error messages
2. Make sure all required permissions are granted:
   - Calendar access
   - HealthKit access
   - Screen Time access
3. Check that `GoogleService-Info.plist` is included in the project

## Wireless Debugging (Optional - iOS 11+)

After first successful USB connection, you can enable wireless debugging:

1. Keep iPhone connected via USB
2. In Xcode: Window → Devices and Simulators
3. Select your iPhone
4. Check **"Connect via network"**
5. Disconnect USB cable
6. Your iPhone will now appear in device list even when not connected

**Note:** iPhone and Mac must be on the same Wi-Fi network

## Quick Checklist

- [ ] iPhone connected via USB
- [ ] iPhone unlocked and trusted computer
- [ ] Xcode project opened
- [ ] Signing configured with your Apple ID/Team
- [ ] iPhone selected as build destination
- [ ] Build and run (Cmd + R)
- [ ] Trusted developer on iPhone (if prompted)

## Tips

- **Keep iPhone unlocked** during build/install
- **Keep USB connected** during first build (wireless can be enabled later)
- **Check Xcode console** for detailed error messages
- **First build takes longer** - be patient!
- **Subsequent builds are faster** - Xcode caches dependencies

## What Happens After Installation

Once installed:
- App stays on your iPhone
- You can disconnect the USB cable
- App runs independently
- To update: Just build and run again from Xcode (will replace old version)

---

**Need Help?** Check Xcode console for specific error messages - they usually tell you exactly what's wrong!


