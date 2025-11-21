# How to Open and Work with This Project in Xcode

## Quick Start - Open the Project

### Method 1: Double-Click (Easiest)
1. Open **Finder**
2. Navigate to: `/Users/josezapata/Desktop/FALL-2025_HACK-A-THON/AIHackathon/`
3. Double-click **`AIHackathon.xcodeproj`**
4. Xcode will open with your project! 🎉

### Method 2: From Xcode
1. Open **Xcode**
2. Go to **File** → **Open** (or press `Cmd + O`)
3. Navigate to the project folder
4. Select **`AIHackathon.xcodeproj`**
5. Click **Open**

### Method 3: Drag and Drop
1. Open **Xcode**
2. Drag the **`AIHackathon.xcodeproj`** file into Xcode
3. Drop it in the Xcode window

---

## Verify Your Files Are in Xcode

After opening, check that all files are visible:

1. Look at the **left sidebar** (Project Navigator) - you should see folders like:
   - 📁 App
   - 📁 Auth
   - 📁 Chat
   - 📁 Components
   - 📁 Dashboard
   - 📁 Events
   - 📁 Matcher
   - 📁 Models
   - 📁 Onboarding
   - 📁 Services
   - 📁 Utils

2. If files are **missing** or showing in **red** (missing files), see "Troubleshooting" below.

---

## First Time Setup in Xcode

### 1. Check Project Settings
1. Click the **blue project icon** at the top of the left sidebar (AIHackathon)
2. Select the **AIHackathon** target (under "TARGETS")
3. Go to **General** tab:
   - **Display Name**: AIHackathon (or your preferred name)
   - **Bundle Identifier**: Should be `com.hernan.AIHackathon`
   - **Deployment Target**: iOS 15.0 or later

### 2. Configure Signing
1. Still in the target settings, click **Signing & Capabilities** tab
2. Check **"Automatically manage signing"**
3. Select your **Team** (your Apple ID)
   - If you don't see your team: Click "Add Account..." and sign in

### 3. Verify Dependencies
1. Go to **File** → **Packages** → **Resolve Package Versions**
   - This ensures Firebase packages are downloaded
2. Wait for packages to resolve (check progress in top bar)

### 4. Build the Project
1. Select a **simulator** or **your iPhone** from the device dropdown (top bar)
2. Press **Cmd + B** to build, or click the **Play button** (▶️)
3. First build may take a few minutes (downloading dependencies)

---

## Understanding Xcode Interface

### Left Sidebar (Project Navigator)
- Shows all your files organized in folders
- Click files to open them in the editor
- Right-click folders to add new files

### Center Area (Editor)
- Shows the code for the file you selected
- You can edit code here
- Multiple files can be open in tabs

### Right Sidebar (Inspector)
- Shows file properties, attributes, etc.
- Can be hidden/shown with `Cmd + Option + 0`

### Top Bar
- **Device Selector**: Choose simulator or your iPhone
- **Play Button (▶️)**: Build and run
- **Stop Button (⏹)**: Stop running app
- **Scheme Selector**: Usually just "AIHackathon"

---

## Working with Files

### Opening Files
- Click any `.swift` file in the left sidebar to open it
- Double-click to open in a new window
- Right-click → "Open in Assistant Editor" to see side-by-side

### Editing Files
- Just click in the editor and start typing
- Xcode has autocomplete - press `Esc` to see suggestions
- Save with `Cmd + S` (auto-saves usually)

### Adding New Files
1. Right-click a folder in the left sidebar
2. Select **"New File..."**
3. Choose template (Swift File, SwiftUI View, etc.)
4. Name it and save
5. Make sure it's added to the target (check the checkbox)

### Finding Files
- Press `Cmd + Shift + O` (Quick Open)
- Type file name to jump to it instantly

---

## Building and Running

### Build Only (Check for Errors)
- Press **Cmd + B**
- Check bottom panel for errors (red) or warnings (yellow)

### Build and Run
- Press **Cmd + R** or click **Play button (▶️)**
- App will build, install, and launch

### Stop Running App
- Press **Cmd + .** (period) or click **Stop button (⏹)**

### Clean Build Folder
- **Product** → **Clean Build Folder** (or `Cmd + Shift + K`)
- Use this if you get weird build errors

---

## Troubleshooting

### Files Showing in Red (Missing Files)

**If files appear red in the sidebar:**

1. **Check if files exist in Finder**
   - Go to the project folder in Finder
   - Verify the files are actually there

2. **Re-add missing files:**
   - Right-click the red file in Xcode
   - Select **"Delete"** → **"Remove Reference"** (don't move to trash)
   - Right-click the folder where it should be
   - Select **"Add Files to AIHackathon..."**
   - Navigate to the file and select it
   - Make sure **"Copy items if needed"** is checked (if file is outside project)
   - Make sure **"Add to targets: AIHackathon"** is checked
   - Click **Add**

### Build Errors

**"No such module 'FirebaseAuth'" or similar:**
1. Go to **File** → **Packages** → **Resolve Package Versions**
2. Wait for packages to download
3. Try building again

**"GoogleService-Info.plist not found":**
1. Make sure `App/GoogleService-Info.plist` exists
2. In Xcode, right-click the file → **"Show in Finder"**
3. If missing, you need to download it from Firebase Console

**Signing Errors:**
1. Go to **Signing & Capabilities** tab
2. Uncheck and recheck **"Automatically manage signing"**
3. Select your team again

### Project Won't Open

**"The project is damaged":**
1. Close Xcode
2. Right-click `AIHackathon.xcodeproj` → **Show Package Contents**
3. Delete `xcuserdata` folder (if present)
4. Try opening again

**"Cannot open because it's from an unidentified developer":**
1. Right-click the `.xcodeproj` file
2. Select **Open**
3. Click **Open** in the dialog (this only needs to be done once)

---

## Useful Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Build | `Cmd + B` |
| Build & Run | `Cmd + R` |
| Stop | `Cmd + .` |
| Clean Build | `Cmd + Shift + K` |
| Quick Open File | `Cmd + Shift + O` |
| Find in Project | `Cmd + Shift + F` |
| Show/Hide Navigator | `Cmd + 0` |
| Show/Hide Debug Area | `Cmd + Shift + Y` |
| Auto-format Code | `Ctrl + I` |
| Comment/Uncomment | `Cmd + /` |

---

## Project Structure in Xcode

Your project should look like this in the sidebar:

```
AIHackathon
├── 📁 App
│   ├── AIHackathonApp.swift
│   ├── AppRootView.swift
│   ├── AppState.swift
│   └── GoogleService-Info.plist
├── 📁 Auth
│   ├── LoginView.swift
│   └── SignupView.swift
├── 📁 Chat
│   └── VirtualAssistantView.swift
├── 📁 Components
│   ├── BottomTabBar.swift
│   ├── EventCard.swift
│   ├── MatchRow.swift
│   └── MetricCard.swift
├── 📁 Dashboard
│   └── HomeDashboardView.swift
├── 📁 Events
│   ├── CreateEventView.swift
│   └── EventCalendarView.swift
├── 📁 Matcher
│   ├── MatchProfileView.swift
│   └── StudentMatcherView.swift
├── 📁 Models
│   ├── ChatMessage.swift
│   ├── Event.swift
│   ├── Match.swift
│   └── UserProfile.swift
├── 📁 Onboarding
│   ├── OnboardingFlowView.swift
│   ├── PermissionRequestView.swift
│   └── PreferenceSetupView.swift
├── 📁 Services
│   ├── AuthService.swift
│   ├── CalendarService.swift
│   ├── FirebaseService.swift
│   ├── GeminiService.swift
│   ├── HealthKitService.swift
│   └── ScreenTimeService.swift
└── 📁 Utils
    ├── DateHelpers.swift
    └── MockData.swift
```

---

## Next Steps

1. ✅ Open the project in Xcode
2. ✅ Verify all files are present
3. ✅ Configure signing
4. ✅ Build the project (`Cmd + B`)
5. ✅ Run on simulator or iPhone (`Cmd + R`)

**You're all set!** Your code is already in the project - just open it in Xcode and start building! 🚀


