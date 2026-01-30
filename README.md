# Penance

Track your pushups and "spend" them on Instagram and X screen time.

## Features

- **Tap to Add Pushups**: Tap anywhere on the increment screen to add 5 pushups (= 1 minute)
- **Balance Tracking**: 5 pushups = 1 minute of screen time
- **Color Feedback**: Green background when positive, red when negative
- **Push Notifications**: "Time's up loser!" when you go negative
- **Lock Screen Widget**: Circular accessory widget showing your balance
- **History Tracking**: View your stats by day/week/year

## Setup Instructions

### 1. Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Select "App" template
4. Configure project:
   - Product Name: **Penance**
   - Team: Select your team
   - Organization Identifier: **com.yourname.penance** (or your preferred identifier)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Save to the existing `Penance` folder

### 2. Add Widget Extension

1. File → New → Target
2. Select "Widget Extension"
3. Configure:
   - Product Name: **PenanceWidget**
   - Include Configuration Intent: **No**
4. Click Finish

### 3. Add Files to Targets

**Main App Target (Penance):**
- Drag all files from `Penance/App`, `Penance/Models`, `Penance/Views`, `Penance/Services` into the Xcode project under the Penance target

**Widget Target (PenanceWidget):**
- Add `PenanceWidget/PenanceWidget.swift`
- Add `PenanceWidget/PersistenceService.swift`

### 4. Configure App Groups

1. Select your project in Xcode
2. Select **Penance** target → Signing & Capabilities
3. Click "+ Capability" → App Groups
4. Add group: **group.com.penance.app**
5. Select **PenanceWidget** target → Signing & Capabilities
6. Click "+ Capability" → App Groups
7. Add the same group: **group.com.penance.app**

### 5. Add Capabilities

**Penance target:**
1. Signing & Capabilities → "+ Capability"
2. Add **Family Controls**
3. This allows Screen Time API access

### 6. Update Info.plist

The `Info.plist` is already included with the required permission description:
- `NSFamilyControlsUsageDescription`: Explains why Screen Time access is needed

### 7. Build and Run

1. Select your iPhone as the destination (Simulator won't work for Screen Time API)
2. Build and run the app
3. Grant permissions when prompted:
   - Screen Time access
   - Notifications

### 8. Add Widget to Lock Screen

1. Long-press on lock screen
2. Tap "Customize"
3. Select widgets area
4. Find "Penance Balance"
5. Add the circular widget

## How It Works

### Balance System
- **5 pushups = 1 minute** of screen time
- Tap anywhere on increment screen to add 5 pushups
- Screen time on Instagram/X decreases your balance by 1 minute per minute used

### Screens

**Increment Page:**
- Tap to add pushups
- See current balance in minutes
- Background color: green (positive) or red (negative)

**History Page:**
- Current balance
- Total pushups completed
- Total screen time used
- Days tracked since start

### Notifications
- When your balance hits 0 while using social media, you'll get: **"Time's up loser!"**
- Can go negative (debt system)

## Technical Notes

### Screen Time API
The app uses Apple's Screen Time API (`FamilyControls` and `DeviceActivity` frameworks) to monitor Instagram and X usage. This requires:
- iOS 15+
- Physical device (not available in Simulator)
- User authorization
- Family Controls capability

### Data Storage
All data is stored locally using:
- **UserDefaults** with App Groups for sharing between app and widget
- **No cloud storage** - everything stays on your device
- Tracks from first launch date automatically

### Real-Time Monitoring
The app implements screen time monitoring through:
1. Timer-based checks (every 60 seconds)
2. DeviceActivity framework hooks
3. Background task support when app is not active

## Development

### Testing Without Screen Time
If you need to test without actual screen time tracking:
```swift
// In ScreenTimeMonitor.swift
ScreenTimeMonitor.shared.simulateScreenTime(minutes: 5)
```

### Resetting Data
To reset all data:
```swift
PersistenceService.shared.reset()
```

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Physical iPhone (for Screen Time API)
- Developer account with App Groups capability

## Future Enhancements

- [ ] Daily goals and streaks
- [ ] Export history data
- [ ] Customizable pushup increments
- [ ] More social media apps
- [ ] Charts and graphs
- [ ] Achievements/badges
