# Penance - Complete Setup Guide

This guide will walk you through setting up the Penance app in Xcode.

## Prerequisites

- macOS with Xcode 15.0 or later
- Apple Developer account (free or paid)
- Physical iPhone running iOS 15.0 or later
- Basic familiarity with Xcode

## Step-by-Step Setup

### 1. Create New Xcode Project

1. Open Xcode
2. Select **File → New → Project**
3. Choose **iOS → App**
4. Click **Next**
5. Configure the project:
   - **Product Name:** `Penance`
   - **Team:** Select your Apple Developer team
   - **Organization Identifier:** `com.yourname` (use your own)
   - **Bundle Identifier:** Will auto-populate as `com.yourname.Penance`
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None
   - **Include Tests:** Optional
6. Click **Next**
7. **IMPORTANT:** Save the project to `/Users/attison/Penance` (the existing folder)
8. When prompted about existing files, choose **Merge** or **Replace** as needed

### 2. Add Files to Main Target

1. In Xcode's Project Navigator (left sidebar), right-click on the **Penance** folder (blue icon)
2. Select **Add Files to "Penance"...**
3. Navigate to the project folder and add these directories:
   - `Penance/App/`
   - `Penance/Models/`
   - `Penance/Services/`
   - `Penance/Views/`
4. Make sure **"Create groups"** is selected
5. Make sure **"Add to targets: Penance"** is checked
6. Click **Add**

### 3. Add Widget Extension Target

1. Select **File → New → Target**
2. Choose **iOS → Widget Extension**
3. Click **Next**
4. Configure the widget:
   - **Product Name:** `PenanceWidget`
   - **Include Configuration Intent:** ❌ Uncheck this
5. Click **Finish**
6. When asked to activate scheme, click **Activate**

### 4. Add Files to Widget Target

1. In Project Navigator, right-click on **PenanceWidget** folder
2. Select **Add Files to "PenanceWidget"...**
3. Navigate to `PenanceWidget/` folder and add:
   - `PenanceWidget.swift`
   - `PersistenceService.swift`
4. Make sure **"Add to targets: PenanceWidget"** is checked
5. Click **Add**

### 5. Add Device Activity Monitor Extension Target

1. Select **File → New → Target**
2. Choose **iOS → App Extension**
3. Scroll down and select **Device Activity Monitor Extension**
4. Click **Next**
5. Configure:
   - **Product Name:** `DeviceActivityMonitorExtension`
6. Click **Finish**
7. Click **Activate** when prompted

### 6. Add Files to Device Activity Monitor Target

1. In Project Navigator, right-click on **DeviceActivityMonitorExtension** folder
2. Select **Add Files to "DeviceActivityMonitorExtension"...**
3. Navigate to `DeviceActivityMonitorExtension/` folder and add:
   - `DeviceActivityMonitorExtension.swift`
4. Make sure target is checked
5. Click **Add**

### 7. Configure App Groups

App Groups allow data sharing between the main app, widget, and extension.

**For Penance (Main App):**
1. Select your project in Project Navigator (top blue icon)
2. Select **Penance** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Double-click **App Groups**
6. Click the **+** button under App Groups
7. Enter: `group.com.penance.app`
8. Click **OK**
9. Make sure the checkbox next to the group is **checked**

**For PenanceWidget:**
1. Select **PenanceWidget** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Double-click **App Groups**
5. Check the box next to `group.com.penance.app` (should already exist)

**For DeviceActivityMonitorExtension:**
1. Select **DeviceActivityMonitorExtension** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Double-click **App Groups**
5. Check the box next to `group.com.penance.app`

### 8. Add Family Controls Capability

**For Penance (Main App):**
1. Select **Penance** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Double-click **Family Controls**
5. The capability will be added (no configuration needed)

### 9. Configure Bundle Identifiers

Make sure all targets have unique bundle identifiers:

1. Select **Penance** target → **General** tab
   - Bundle Identifier: `com.yourname.Penance`

2. Select **PenanceWidget** target → **General** tab
   - Bundle Identifier: `com.yourname.Penance.PenanceWidget`

3. Select **DeviceActivityMonitorExtension** target → **General** tab
   - Bundle Identifier: `com.yourname.Penance.DeviceActivityMonitorExtension`

### 10. Update Deployment Target

Make sure all targets support iOS 15.0+:

1. Select each target (**Penance**, **PenanceWidget**, **DeviceActivityMonitorExtension**)
2. Go to **General** tab
3. Set **Minimum Deployments → iOS** to **15.0** or higher

### 11. Configure Info.plist

The `Info.plist` file should already be in place with the required permission:

- `NSFamilyControlsUsageDescription`: "Penance needs access to Screen Time to track your Instagram and X usage and deduct from your balance."

If you need to modify it:
1. Select **Penance** target
2. Go to **Info** tab
3. Find or add **Privacy - Family Controls Usage Description**
4. Set the value to the description above

### 12. Build the Project

1. Connect your physical iPhone (Screen Time API doesn't work in Simulator)
2. Select your iPhone as the build destination
3. Select the **Penance** scheme (top left, next to Play/Stop buttons)
4. Click **Play** button or press **Cmd+R**
5. Wait for build to complete
6. Xcode may ask for code signing:
   - Click **Enable Automatic Signing**
   - Select your team
   - Click **Try Again**

### 13. Grant Permissions

When the app first launches on your iPhone:

1. **Screen Time Permission:**
   - Tap **Allow** when prompted for Screen Time access
   - Follow system prompts to authorize

2. **Notification Permission:**
   - Tap **Allow** when prompted for notifications

### 14. Add Widget to Lock Screen

1. Lock your iPhone
2. Long-press on the lock screen
3. Tap **Customize**
4. Tap on the widgets area (above or below the time)
5. Scroll to find **Penance Balance**
6. Tap to add it
7. Tap **Done**

## Verification

Test that everything works:

1. **Test Counter:**
   - Open app
   - Tap anywhere on green screen
   - Balance should increase by 1 minute
   - Background should be green

2. **Test Negative Balance:**
   - In Xcode, find `ScreenTimeMonitor.swift`
   - In the app, swipe to History page
   - Uncomment the simulation line in `checkUsage()` method to test
   - Or manually call: `ScreenTimeMonitor.shared.simulateScreenTime(minutes: 10)`

3. **Test Widget:**
   - Add pushups in the app
   - Lock your iPhone
   - Check that lock screen widget updates (may take up to 5 minutes)

4. **Test Notification:**
   - Manually trigger negative balance
   - You should see: "Time's up loser!"

## Troubleshooting

### "Failed to register bundle identifier"
- Make sure bundle IDs are unique
- Check that you're signed in with your Apple ID in Xcode (Preferences → Accounts)

### "No provisioning profile found"
- Select **Automatically manage signing** in each target's Signing & Capabilities
- Select your team from the dropdown

### Screen Time authorization fails
- Make sure you're on a physical device (not Simulator)
- Check that Family Controls capability is added
- Try revoking authorization in Settings → Screen Time → Family → [Your Name] → Remove Access, then re-authorize

### Widget doesn't appear
- Make sure App Groups are configured identically in all three targets
- Check that widget target's deployment target is iOS 15.0+
- Rebuild and reinstall the app

### Build errors about missing files
- Make sure all Swift files are added to their correct targets
- Check File Inspector (right sidebar) to see which targets each file belongs to

### "FamilyControls" not found
- Make sure deployment target is iOS 15.0+
- Family Controls capability must be added to main target

## Testing Screen Time Tracking

Since Screen Time API has restrictions, here are testing strategies:

### Option 1: Simulator (Limited)
You can test UI and logic, but NOT Screen Time features.

### Option 2: Physical Device with Simulation
Add this to test:
```swift
// In ScreenTimeMonitor.swift, add a public method:
func testDeduct() {
    CounterManager.shared.deductScreenTime(minutes: 1)
}
```

Call it from a button in the UI for testing.

### Option 3: Actual Usage
1. Grant all permissions
2. Add pushups (e.g., 50 pushups = 10 minutes)
3. Use Instagram or X for a few minutes
4. The counter should automatically decrease

## Next Steps

- Customize the app for your preferences
- Test thoroughly on your device
- Consider adding more features from PROJECT_OVERVIEW.md

## Need Help?

- Check the README.md for feature documentation
- Check PROJECT_OVERVIEW.md for technical details
- Review Apple's documentation on Screen Time API
- Check Xcode's Issue Navigator for specific errors

Happy tracking!
